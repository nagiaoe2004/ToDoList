import 'package:todo_list/data/in_memory_store.dart';
import 'package:todo_list/domain/models/app_user.dart';
import 'package:todo_list/domain/repositories/user_repository.dart';

/// Mock: đọc/ghi danh sách user trong store.
class MockUserRepository implements UserRepository {
  MockUserRepository(this._store);

  final InMemoryStore _store;

  @override
  Future<AppUser?> getUserById(String id) async {
    try {
      return _store.users.firstWhere((AppUser u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    final int idx = _store.users.indexWhere((AppUser u) => u.id == userId);
    if (idx == -1) {
      throw StateError('User not found');
    }
    final AppUser next = _store.users[idx].copyWith(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
    );
    _store.users[idx] = next;
    return next;
  }

  @override
  Future<AppUser?> findUserByEmail(String email) async {
    final String n = email.trim().toLowerCase();
    for (final AppUser u in _store.users) {
      if (u.email.toLowerCase() == n) return u;
    }
    return null;
  }
}
