import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/shared/presentation/helio_surface.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (BuildContext context, AppController app, _) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: ListView(
                children: <Widget>[
                  const HelioGradientHero(
                    title: 'Cài đặt',
                    subtitle: 'Tùy chỉnh giao diện và trải nghiệm sử dụng',
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    value: app.isDarkMode,
                    onChanged: app.setDarkMode,
                    title: const Text('Chế độ tối'),
                  ),
                  const SizedBox(height: 8),
                  Text('Cỡ chữ', style: Theme.of(context).textTheme.titleMedium),
                  Slider(
                    value: app.fontScale,
                    min: 0.9,
                    max: 1.3,
                    divisions: 4,
                    label: app.fontScale.toStringAsFixed(2),
                    onChanged: app.setFontScale,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: app.fontFamily,
                    decoration: const InputDecoration(
                      labelText: 'Loại phông chữ',
                    ),
                    items: const <String>['Mặc định', 'Serif', 'Monospace']
                        .map(
                          (String e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) {
                      if (v != null) app.setFontFamily(v);
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Giới thiệu sản phẩm:\nHelio Todo là nền tảng quản lý công việc cá nhân và nhóm, hỗ trợ đồng bộ dữ liệu trên Firebase với giao diện tối ưu cho cả điện thoại và trình duyệt web.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => app.signOut(),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Đăng xuất'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
