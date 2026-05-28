import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:todo_list/data/firebase_rtdb.dart';
import 'package:todo_list/domain/models/app_user.dart';
import 'package:todo_list/domain/repositories/user_repository.dart';

String emailIndexKey(String email) =>
    base64Url.encode(utf8.encode(email.trim().toLowerCase())).replaceAll('=', '');

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository({FirebaseDatabase? database})
      : _db = database ?? firebaseRtdb();

  final FirebaseDatabase _db;

  DatabaseReference get _users => _db.ref('users');

  DatabaseReference get _userEmails => _db.ref('userEmails');

  Future<void> _setEmailIndex(String email, String uid) async {
    await _userEmails.child(emailIndexKey(email)).set(uid);
  }

  @override
  Future<AppUser?> getUserById(String id) async {
    final DataSnapshot doc = await _users.child(id).get();
    if (!doc.exists || doc.value == null) {
      final User? authUser = FirebaseAuth.instance.currentUser;
      if (authUser != null && authUser.uid == id) {
        final String email = authUser.email ?? '';
        final AppUser fallback = AppUser(
          id: id,
          name: email.isEmpty ? 'Người dùng mới' : email.split('@').first,
          email: email,
          phone: '',
        );
        await _users.child(id).update(<String, dynamic>{
          'name': fallback.name,
          'email': fallback.email,
          'phone': fallback.phone,
          'createdAt': ServerValue.timestamp,
        });
        if (email.isNotEmpty) {
          await _setEmailIndex(fallback.email, id);
        }
        return fallback;
      }
      return null;
    }
    final Object? raw = doc.value;
    if (raw is! Map) return null;
    return _fromMap(
      doc.key ?? id,
      raw.map(
        (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
      ),
    );
  }

  @override
  Future<AppUser> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    final String trimmedEmail = email.trim().toLowerCase();
    final DataSnapshot existing = await _users.child(userId).get();
    String? oldEmail;
    if (existing.exists && existing.value is Map) {
      final Map<dynamic, dynamic> m =
          Map<dynamic, dynamic>.from(existing.value! as Map);
      oldEmail = m['email']?.toString();
    }
    await _users.child(userId).update(<String, dynamic>{
      'name': name.trim(),
      'email': trimmedEmail,
      'phone': phone.trim(),
      'updatedAt': ServerValue.timestamp,
    });
    if (oldEmail != null &&
        oldEmail.trim().toLowerCase() != trimmedEmail) {
      await _userEmails.child(emailIndexKey(oldEmail)).remove();
    }
    await _setEmailIndex(trimmedEmail, userId);
    final AppUser? updated = await getUserById(userId);
    if (updated == null) {
      throw StateError('User not found');
    }
    return updated;
  }

  @override
  Future<AppUser?> findUserByEmail(String email) async {
    final String normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    final DataSnapshot idx =
        await _userEmails.child(emailIndexKey(normalized)).get();
    if (idx.exists && idx.value != null) {
      final String uid = idx.value.toString();
      final AppUser? fromIndex = await getUserById(uid);
      if (fromIndex != null) {
        return fromIndex;
      }
    }

    // Fallback cho dữ liệu cũ chưa có node userEmails.
    final DataSnapshot usersByEmail = await _users
        .orderByChild('email')
        .equalTo(normalized)
        .limitToFirst(1)
        .get();
    if (!usersByEmail.exists || usersByEmail.value == null) return null;
    final Object? raw = usersByEmail.value;
    if (raw is! Map) return null;
    if (raw.entries.isEmpty) return null;
    final MapEntry<dynamic, dynamic> first = raw.entries.first;
    final Object? value = first.value;
    if (value is! Map) return null;
    final String uid = first.key.toString();
    final AppUser user = _fromMap(
      uid,
      value.map(
        (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
      ),
    );
    await _setEmailIndex(normalized, uid);
    return user;
  }

  AppUser _fromMap(String id, Map<String, dynamic> map) {
    final String name = map['name']?.toString().trim() ?? '';
    final String email = map['email']?.toString().trim() ?? '';
    final String phone = map['phone']?.toString().trim() ?? '';
    return AppUser(
      id: id,
      name: name.isEmpty ? 'Chưa cập nhật' : name,
      email: email,
      phone: phone,
    );
  }
}
