import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/domain/models/app_user.dart';
import 'package:todo_list/core/theme/app_colors.dart';
import 'package:todo_list/shared/presentation/helio_surface.dart';

/// Tab Tôi: sửa hồ sơ và đăng xuất qua [AppController].
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _hydrated = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Gán text controller từ hồ sơ một lần khi đã có [AppController.profile].
  void _hydrateFrom(AppController app) {
    final p = app.profile;
    if (p == null || _hydrated) return;
    _name.text = p.name;
    _email.text = p.email;
    _phone.text = p.phone;
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) {
    final AppController app = context.watch<AppController>();
    _hydrateFrom(app);

    final p = app.profile;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              HelioGradientHero(
                title: 'Tài khoản',
                subtitle: p == null ? 'Đang tải...' : p.email,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: p == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text(
                                'Không tải được thông tin hồ sơ.',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: () => app.bootstrapAfterLogin(),
                                child: const Text('Thử tải lại'),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Thông tin',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _name,
                              decoration: const InputDecoration(
                                hintText: 'Họ tên',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _email,
                              enabled: false,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Số điện thoại',
                                prefixIcon: Icon(Icons.phone_iphone_rounded),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _password,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Nhập mật khẩu để xác thực thay đổi',
                                prefixIcon: Icon(Icons.verified_user_outlined),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 50,
                              child: FilledButton(
                                onPressed: () async {
                                  final String? err = await app.updateProfile(
                                    name: _name.text,
                                    phone: _phone.text,
                                    currentPassword: _password.text,
                                  );
                                  if (!context.mounted) return;
                                  final AppUser? p = app.profile;
                                  if (err == null && p != null) {
                                    _name.text = p.name;
                                    _email.text = p.email;
                                    _phone.text = p.phone;
                                    _password.clear();
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(err ?? 'Đã lưu thông tin'),
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Lưu',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () => app.signOut(),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Đăng xuất'),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
