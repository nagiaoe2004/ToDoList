import 'package:todo_list/domain/models/app_user.dart';

/// Đọc / cập nhật hồ sơ; tìm user theo email (thêm vào nhóm).
abstract class UserRepository {
  Future<AppUser?> getUserById(String id);

  Future<AppUser> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
  });

  Future<AppUser?> findUserByEmail(String email);
}
