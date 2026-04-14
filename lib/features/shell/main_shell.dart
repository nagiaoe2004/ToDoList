import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/core/theme/app_colors.dart';
import 'package:todo_list/features/admin/presentation/admin_screen.dart';
import 'package:todo_list/features/groups/presentation/groups_screen.dart';
import 'package:todo_list/features/profile/presentation/profile_screen.dart';
import 'package:todo_list/features/settings/presentation/settings_screen.dart';
import 'package:todo_list/features/tasks/presentation/tasks_screen.dart';

/// Vỏ chính sau đăng nhập: 3 tab, không chứa nghiệp vụ.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final bool showDashboard = context.watch<AppController>().isAdminSession;
    final List<Widget> pages = <Widget>[
      const TasksScreen(),
      const GroupsScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
      if (showDashboard) const AdminScreen(),
    ];
    final List<NavigationDestination> navItems = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.checklist_rounded),
        label: 'Công việc',
      ),
      const NavigationDestination(
        icon: Icon(Icons.groups_rounded),
        label: 'Nhóm',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_rounded),
        label: 'Tôi',
      ),
      const NavigationDestination(
        icon: Icon(Icons.settings_rounded),
        label: 'Cài đặt',
      ),
      if (showDashboard)
        const NavigationDestination(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
    ];
    if (_index >= pages.length) {
      _index = 0;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 64,
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.accent.withValues(alpha: 0.15),
        selectedIndex: _index,
        onDestinationSelected: (int i) => setState(() => _index = i),
        destinations: navItems,
      ),
    );
  }
}
