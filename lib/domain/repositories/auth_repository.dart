/// Lỗi đăng nhập (mock/API).
enum SignInFailure {
  invalidCredentials,
  networkUnavailable,
  tooManyRequests,
}

/// Đăng nhập / đăng xuất; phiên hiện tại qua [currentUserId].
abstract class AuthRepository {
  String? get currentUserId;

  Future<SignInFailure?> signIn({
    required String email,
    required String password,
  });

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  });

  Future<String?> reauthenticate({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
