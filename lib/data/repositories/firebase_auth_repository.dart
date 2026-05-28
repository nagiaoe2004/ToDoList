import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:todo_list/data/firebase_rtdb.dart';
import 'package:todo_list/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseDatabase? database,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = database ?? firebaseRtdb();

  final FirebaseAuth _auth;
  final FirebaseDatabase _db;

  static String _emailKey(String email) {
    final String normalized = email.trim().toLowerCase();
    return base64Url.encode(utf8.encode(normalized)).replaceAll('=', '');
  }

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<SignInFailure?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      unawaited(
        _db.ref('login_history').push().set(<String, dynamic>{
          'uid': cred.user?.uid,
          'email': email.trim().toLowerCase(),
          'time': ServerValue.timestamp,
          'platform': 'app',
        }),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('Firebase signIn error: ${e.code} - ${e.message}');
      if (e.code == 'network-request-failed' || e.code == 'internal-error') {
        return SignInFailure.networkUnavailable;
      }
      if (e.code == 'too-many-requests') {
        return SignInFailure.tooManyRequests;
      }
      return SignInFailure.invalidCredentials;
    }
  }

  @override
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final String uid = cred.user!.uid;
      final String em = email.trim().toLowerCase();
      await _db.ref().update(<String, dynamic>{
        'users/$uid/name': name.trim(),
        'users/$uid/email': em,
        'users/$uid/phone': phone.trim(),
        'users/$uid/createdAt': ServerValue.timestamp,
        'userEmails/${_emailKey(email)}': uid,
      });
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email đã được sử dụng.';
      }
      if (e.code == 'weak-password') {
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      }
      if (e.code == 'operation-not-allowed') {
        return 'Firebase chưa bật Email/Password trong Authentication.';
      }
      if (e.code == 'invalid-email') {
        return 'Email không hợp lệ.';
      }
      return 'Đăng ký thất bại (${e.code}). ${e.message ?? 'Vui lòng thử lại.'}';
    } on FirebaseException catch (e) {
      return 'Tạo tài khoản thành công nhưng lưu hồ sơ thất bại (${e.code}). Kiểm tra quyền Realtime Database.';
    } catch (_) {
      return 'Đăng ký thất bại do lỗi hệ thống.';
    }
  }

  @override
  Future<String?> reauthenticate({
    required String email,
    required String password,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) return 'Bạn chưa đăng nhập.';
    try {
      final AuthCredential cred = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      await user.reauthenticateWithCredential(cred);
      return null;
    } on FirebaseAuthException {
      return 'Xác thực mật khẩu thất bại.';
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
