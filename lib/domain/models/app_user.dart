/// Người dùng ứng dụng (hồ sơ hiển thị ở tab Tôi).
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String phone;

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
