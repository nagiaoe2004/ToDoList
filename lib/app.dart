import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/core/theme/app_theme.dart';
import 'package:todo_list/features/auth/presentation/login_screen.dart';
import 'package:todo_list/features/shell/main_shell.dart';

/// Root [MaterialApp]: routing theo trạng thái đăng nhập ([AppController]).
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController app = context.watch<AppController>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Helio Todo',
      theme: buildIosCleanTheme(
        isDarkMode: app.isDarkMode,
        fontScale: app.fontScale,
      ),
      home: Consumer<AppController>(
        builder: (BuildContext context, AppController app, _) {
          if (!app.isAuthenticated) {
            return const LoginScreen();
          }
          return const MainShell();
        },
      ),
    );
  }
}
