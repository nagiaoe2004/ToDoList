import 'package:todo_list/domain/models/app_user.dart';
import 'package:todo_list/domain/models/group.dart';
import 'package:todo_list/domain/models/task_item.dart';

/// Nguồn dữ liệu giả trong RAM (giai đoạn mock). Sau này thay bằng API / DB.
class InMemoryStore {
  InMemoryStore({
    required this.users,
    required this.groups,
    required this.tasks,
    this.currentUserId,
  });

  final List<AppUser> users;
  final List<Group> groups;
  final List<TaskItem> tasks;
  String? currentUserId;

  int _taskSeq = 100;

  String nextTaskId() => 't-${_taskSeq++}';

  /// Dữ liệu mẫu: 3 user, 1 nhóm, việc cá nhân + việc nhóm.
  static InMemoryStore seeded() {
    const AppUser u1 = AppUser(
      id: 'u-1',
      name: 'Nguyễn Văn A',
      email: 'demo@example.com',
      phone: '0901234567',
    );
    const AppUser u2 = AppUser(
      id: 'u-2',
      name: 'Trần Thị B',
      email: 'teamb@example.com',
      phone: '0912345678',
    );
    const AppUser u3 = AppUser(
      id: 'u-3',
      name: 'Lê Văn C',
      email: 'partner@example.com',
      phone: '0923456789',
    );

    final List<Group> groups = <Group>[
      const Group(
        id: 'g-1',
        name: 'Nhóm UI / Flutter',
        workDescription: 'Phát triển giao diện và checklist triển khai app',
        companyName: 'ToDo Labs',
        memberUserIds: <String>['u-1', 'u-2'],
      ),
    ];

    final DateTime now = DateTime.now();
    final List<TaskItem> tasks = <TaskItem>[
      TaskItem(
        id: 't-1',
        title: 'Product planning',
        description: 'Draft phase-1 scope and visual states.',
        dueDate: now.add(const Duration(days: 1)),
        createdByUserId: 'u-1',
      ),
      TaskItem(
        id: 't-2',
        title: 'Landing UI review',
        description: 'Validate typography, spacing, and shadows.',
        dueDate: now.add(const Duration(days: 2)),
        createdByUserId: 'u-1',
        isDone: true,
      ),
      TaskItem(
        id: 't-3',
        title: 'Prepare static demo',
        description: 'No backend, only mock and interactions.',
        dueDate: now.add(const Duration(days: 4)),
        createdByUserId: 'u-1',
      ),
      TaskItem(
        id: 't-4',
        title: 'Sync design tokens',
        description: 'Align login + tabs + cards.',
        dueDate: now.add(const Duration(days: 3)),
        createdByUserId: 'u-1',
        groupId: 'g-1',
      ),
      TaskItem(
        id: 't-5',
        title: 'Group: weekly checklist',
        description: 'Shared tasks in nhóm.',
        dueDate: now.add(const Duration(days: 5)),
        createdByUserId: 'u-2',
        groupId: 'g-1',
        isDone: true,
      ),
    ];

    return InMemoryStore(
      users: <AppUser>[u1, u2, u3],
      groups: groups,
      tasks: tasks,
    );
  }
}
