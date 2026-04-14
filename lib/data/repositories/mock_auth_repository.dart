import 'package:todo_list/data/in_memory_store.dart';
import 'package:todo_list/domain/models/app_user.dart';
import 'package:todo_list/domain/repositories/auth_repository.dart';

/// Mock: đăng nhập theo email có trong [InMemoryStore], gán [currentUserId].
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._store);

  final InMemoryStore _store;

  @override
  String? get currentUserId => _store.currentUserId;

  @override
  Future<SignInFailure?> signIn({
    required String email,
    required String password,
  }) async {
    final String normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || password.isEmpty) {
      return SignInFailure.invalidCredentials;
    }
    for (final AppUser user in _store.users) {
      if (user.email.toLowerCase() == normalized) {
        _store.currentUserId = user.id;
        return null;
      }
    }
    return SignInFailure.invalidCredentials;
  }

  @override
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    return 'Chế độ mock không hỗ trợ đăng ký.';
  }

  @override
  Future<String?> reauthenticate({
    required String email,
    required String password,
  }) async {
    final String normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || password.isEmpty) {
      return 'Thông tin xác thực không hợp lệ.';
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    _store.currentUserId = null;
  }
}
