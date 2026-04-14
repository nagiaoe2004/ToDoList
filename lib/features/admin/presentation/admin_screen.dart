import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/domain/models/app_user.dart';
import 'package:todo_list/shared/presentation/helio_surface.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (BuildContext context, AppController app, _) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: app.isAdminSession
                  ? _buildDashboard(app)
                  : _buildNotAllowed(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotAllowed(BuildContext context) {
    return ListView(
      children: <Widget>[
        const HelioGradientHero(
          title: 'Dashboard quản lý',
          subtitle: 'Chỉ tài khoản admin được phép truy cập',
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: const Text('Không có quyền truy cập'),
            subtitle: const Text(
              'Vui lòng đăng nhập đúng tài khoản admin@gmail.com với mật khẩu admin123 để mở Dashboard.',
            ),
            isThreeLine: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard(AppController app) {
    return FutureBuilder<List<Object>>(
      future: Future.wait<Object>(<Future<Object>>[
        app.loadAllUsersForAdmin(),
        app.loadLoginHistoryForAdmin(),
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<Object>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải dữ liệu admin: ${snapshot.error}'));
        }
        final List<AppUser> users = snapshot.data![0] as List<AppUser>;
        final List<String> history = snapshot.data![1] as List<String>;
        return ListView(
          children: <Widget>[
            HelioGradientHero(
              title: 'Dashboard quản lý',
              subtitle: '${users.length} người dùng',
            ),
            const SizedBox(height: 14),
            Card(
              child: const ListTile(
                leading: Icon(Icons.admin_panel_settings_rounded),
                title: Text('Tài khoản đăng nhập'),
                subtitle: Text('admin@gmail.com'),
              ),
            ),
            Card(
              child: const ListTile(
                leading: Icon(Icons.password_rounded),
                title: Text('Mật khẩu'),
                subtitle: Text('******** (được ẩn để bảo mật)'),
              ),
            ),
            const SizedBox(height: 10),
            Text('Người dùng', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...users.map(
              (AppUser u) => Card(
                child: ListTile(
                  title: Text(u.name),
                  subtitle: Text('${u.email}\n${u.phone}'),
                  isThreeLine: true,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Lịch sử đăng nhập',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...history.map(
              (String row) => Card(
                child: ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: Text(row),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
