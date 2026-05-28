import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/domain/models/app_user.dart';
import 'package:todo_list/domain/models/group.dart';
import 'package:todo_list/domain/models/task_item.dart';
import 'package:todo_list/shared/presentation/helio_surface.dart';
import 'package:todo_list/widgets/task_tile.dart';

/// Chi tiết nhóm: thành viên + việc nhóm; dữ liệu qua [AppController], chỉ cache UI.
class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupWorkDescription,
    this.groupCompanyName,
  });

  final String groupId;
  final String groupName;
  final String groupWorkDescription;
  final String? groupCompanyName;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  List<AppUser> _members = <AppUser>[];
  List<TaskItem> _tasks = <TaskItem>[];
  Group? _group;
  bool _loading = true;
  StreamSubscription<Group?>? _groupSub;
  StreamSubscription<List<AppUser>>? _membersSub;
  StreamSubscription<List<TaskItem>>? _tasksSub;

  /// 0 = tất cả, 1 = đang làm, 2 = hoàn thành
  int _taskFilterIndex = 0;

  List<TaskItem> get _filteredTasks {
    switch (_taskFilterIndex) {
      case 1:
        return _tasks.where((TaskItem t) => !t.isDone).toList();
      case 2:
        return _tasks.where((TaskItem t) => t.isDone).toList();
      default:
        return _tasks;
    }
  }

  int get _pendingCount => _tasks.where((TaskItem t) => !t.isDone).length;
  int get _doneCount => _tasks.where((TaskItem t) => t.isDone).length;
  bool _isLeader(AppController app) =>
      (_group?.leaderUserId ?? '') == (app.currentUserId ?? '');

  String _memberNameById(String? id) {
    if (id == null || id.isEmpty) return 'Chưa phân công';
    if (id == AppController.assignAllMembersKey) return 'Tất cả thành viên';
    for (final AppUser u in _members) {
      if (u.id == id) return u.name;
    }
    return id;
  }

  String _timeText(DateTime? value) {
    if (value == null) return 'chưa cập nhật';
    return '${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindRealtime());
  }

  Future<void> _bindRealtime() async {
    final AppController app = context.read<AppController>();
    _groupSub?.cancel();
    _membersSub?.cancel();
    _tasksSub?.cancel();
    int ready = 0;
    void markReady() {
      ready += 1;
      if (ready >= 3 && mounted) {
        setState(() => _loading = false);
      }
    }

    _groupSub = app.watchGroupById(widget.groupId).listen((Group? g) {
      if (!mounted) return;
      setState(() => _group = g);
      markReady();
    });
    _membersSub = app.watchGroupMembers(widget.groupId).listen((List<AppUser> m) {
      if (!mounted) return;
      setState(() => _members = m);
      markReady();
    });
    _tasksSub = app.watchGroupTasks(widget.groupId).listen((List<TaskItem> t) {
      if (!mounted) return;
      setState(() => _tasks = t);
      markReady();
    });
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() => _loading = true);
    await context.read<AppController>().refreshGroups();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _addMember(AppController app) async {
    final TextEditingController email = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: <Widget>[
              Icon(Icons.person_add_alt_1_rounded),
              SizedBox(width: 10),
              Text('Thêm thành viên'),
            ],
          ),
          content: TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'email@example.com',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: () async {
                final String? err = await app.addMemberToGroup(
                  groupId: widget.groupId,
                  memberEmail: email.text,
                );
                if (!context.mounted) {
                  return;
                }
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err)),
                  );
                  return;
                }
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addTask(AppController app) async {
    if (!_isLeader(app)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chỉ trưởng nhóm mới có quyền phân công nhiệm vụ.'),
          ),
        );
      }
      return;
    }
    if (_members.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nhóm chưa có thành viên để giao việc.')),
        );
      }
      return;
    }
    final TextEditingController title = TextEditingController();
    final TextEditingController description = TextEditingController();
    DateTime due = DateTime.now();
    String assignedToUserId = AppController.assignAllMembersKey;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: <Widget>[
                  Icon(Icons.add_task_rounded),
                  SizedBox(width: 10),
                  Text('Giao việc trong nhóm'),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: title,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Tiêu đề',
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: description,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: assignedToUserId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Giao cho thành viên',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        items: <DropdownMenuItem<String>>[
                          const DropdownMenuItem<String>(
                            value: AppController.assignAllMembersKey,
                            child: Text('Tất cả thành viên'),
                          ),
                          ..._members.map(
                            (AppUser u) => DropdownMenuItem<String>(
                              value: u.id,
                              child: Text(
                                '${u.name} (${u.email})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        selectedItemBuilder: (BuildContext context) {
                          return <Widget>[
                            const Text(
                              'Tất cả thành viên',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            ..._members.map(
                              (AppUser u) => Text(
                                u.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ];
                        },
                        onChanged: (String? value) {
                          if (value == null) return;
                          setStateDialog(() => assignedToUserId = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.event_rounded, size: 20),
                          const SizedBox(width: 8),
                          const Text('Hạn hoàn thành'),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: due,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 365),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 2),
                                ),
                              );
                              if (picked != null) {
                                setStateDialog(() => due = picked);
                              }
                            },
                            child: Text(
                              '${due.day}/${due.month}/${due.year}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Huỷ'),
                ),
                FilledButton(
                  onPressed: () async {
                    final String? err = await app.addGroupTask(
                      groupId: widget.groupId,
                      assignedToUserId: assignedToUserId,
                      title: title.text,
                      description: description.text,
                      dueDate: due,
                    );
                    if (!context.mounted) {
                      return;
                    }
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err)),
                      );
                      return;
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Đăng việc'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMembersRow(BuildContext context, AppController app) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Thành viên',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            if (_isLeader(app))
              TextButton.icon(
                onPressed: () => _addMember(app),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                label: const Text('Mời thêm'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _members.isEmpty
                  ? Center(
                      child: Text(
                        'Chưa có thành viên.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _members.length,
                      separatorBuilder: (BuildContext _, int __) =>
                          const SizedBox(width: 12),
                      itemBuilder: (BuildContext context, int index) {
                        final AppUser u = _members[index];
                        return Container(
                          width: 200,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: scheme.outlineVariant.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                u.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                u.email,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                              if (u.phone.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 6),
                                Text(
                                  u.phone,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _taskFilterBar(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            FilterChip(
              label: Text('Tất cả (${_tasks.length})'),
              selected: _taskFilterIndex == 0,
              onSelected: (_) => setState(() => _taskFilterIndex = 0),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: Text('Đang làm ($_pendingCount)'),
              selected: _taskFilterIndex == 1,
              onSelected: (_) => setState(() => _taskFilterIndex = 1),
              avatar: Icon(
                Icons.radio_button_unchecked,
                size: 16,
                color: scheme.secondary,
              ),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: Text('Đã xong ($_doneCount)'),
              selected: _taskFilterIndex == 2,
              onSelected: (_) => setState(() => _taskFilterIndex = 2),
              avatar: Icon(
                Icons.check_circle_outline,
                size: 16,
                color: scheme.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, AppController app) {
    final List<TaskItem> shown = _filteredTasks;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _taskFilterBar(context),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _reload,
                    child: _tasks.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: <Widget>[
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.15,
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: <Widget>[
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 48,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Chưa có việc nhóm',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Thêm việc để cả nhóm cùng theo dõi và tick hoàn thành.',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : shown.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: <Widget>[
                                  const SizedBox(height: 40),
                                  Center(
                                    child: Text(
                                      'Không có việc trong bộ lọc này.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 24),
                                itemCount: shown.length,
                                separatorBuilder: (BuildContext _, int __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (BuildContext context, int index) {
                                  final TaskItem t = shown[index];
                                  return TaskTile(
                                    item: t,
                                    metaText:
                                        'Giao: ${_memberNameById(t.assignedToUserId)} · Cập nhật: ${_timeText(t.updatedAt)}',
                                    canToggle: _isLeader(app) ||
                                        ((t.assignedToUserId ==
                                                    app.currentUserId ||
                                                t.assignedToUserId ==
                                                    AppController
                                                        .assignAllMembersKey) &&
                                            !t.isDone),
                                    onChanged: (bool v) async {
                                      final bool? confirm =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text(
                                            v
                                                ? 'Xác nhận hoàn thành'
                                                : 'Xác nhận bỏ hoàn thành',
                                          ),
                                          content: Text(
                                            v
                                                ? 'Bạn chắc chắn muốn đánh dấu công việc nhóm này đã hoàn thành?'
                                                : 'Bạn muốn đổi trạng thái công việc này về chưa hoàn thành?',
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Không'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Xác nhận'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm != true) {
                                        return;
                                      }
                                      final String? err =
                                          await app.setGroupTaskDone(
                                        groupId: widget.groupId,
                                        taskId: t.id,
                                        isDone: v,
                                      );
                                      if (!context.mounted || err == null) {
                                        return;
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(err)),
                                      );
                                    },
                                    onDelete: () async {
                                      final bool? confirm =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text(
                                            'Xác nhận xoá công việc',
                                          ),
                                          content: const Text(
                                            'Bạn có chắc chắn muốn xoá task công việc này không?',
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Không'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Có'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm != true) {
                                        return;
                                      }
                                      await app.deleteGroupTask(
                                        groupId: widget.groupId,
                                        taskId: t.id,
                                      );
                                    },
                                    canDelete: _isLeader(app),
                                  );
                                },
                              ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(BuildContext context, AppController app) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Group? group = _group;
    final String groupName = group?.name ?? widget.groupName;
    final String groupWork =
        group?.workDescription ?? widget.groupWorkDescription;
    final String? groupCompany = group?.companyName ?? widget.groupCompanyName;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.info_outline_rounded, color: scheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Tổng quan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoTile(
            context,
            Icons.badge_rounded,
            'Nhóm',
            groupName,
          ),
          const SizedBox(height: 8),
          _infoTile(
            context,
            Icons.work_outline_rounded,
            'Công việc chính',
            groupWork,
          ),
          if (groupCompany != null && groupCompany.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            _infoTile(
              context,
              Icons.apartment_rounded,
              'Dự án',
              groupCompany,
            ),
          ],
          const SizedBox(height: 8),
          _infoTile(
            context,
            Icons.group_outlined,
            'Thành viên',
            '${_members.length} người',
          ),
          const SizedBox(height: 8),
          _infoTile(
            context,
            Icons.verified_user_outlined,
            'Trưởng nhóm',
            _memberNameById(group?.leaderUserId),
          ),
          const SizedBox(height: 8),
          _infoTile(
            context,
            Icons.task_alt_rounded,
            'Việc nhóm',
            '$_pendingCount đang làm · $_doneCount đã xong',
          ),
          const SizedBox(height: 16),
          if (_isLeader(app))
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _addTask(app),
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('Phân công nhiệm vụ'),
              ),
            ),
          if (_isLeader(app)) ...<Widget>[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showTaskHistoryDialog(context),
                icon: const Icon(Icons.history_rounded),
                label: const Text('Lịch sử task'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showTaskHistoryDialog(BuildContext context) {
    final List<TaskItem> sorted = List<TaskItem>.from(_tasks)
      ..sort((TaskItem a, TaskItem b) {
        final DateTime ta = a.updatedAt ?? a.dueDate;
        final DateTime tb = b.updatedAt ?? b.dueDate;
        return tb.compareTo(ta);
      });
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lịch sử task (trưởng nhóm)'),
          content: SizedBox(
            width: 520,
            child: sorted.isEmpty
                ? const Text('Chưa có lịch sử task.')
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: sorted.length,
                    separatorBuilder: (BuildContext _, int __) =>
                        const Divider(height: 16),
                    itemBuilder: (BuildContext _, int index) {
                      final TaskItem t = sorted[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            t.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Giao: ${_memberNameById(t.assignedToUserId)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Trạng thái: ${t.isDone ? 'Đã xong' : 'Đang làm'} · ${_timeText(t.updatedAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    },
                  ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppController app = context.watch<AppController>();
    final bool isDesktop = MediaQuery.of(context).size.width >= 1100;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String title = _group?.name ?? widget.groupName;
    final String subtitleWork =
        _group?.workDescription ?? widget.groupWorkDescription;

    return Scaffold(
      floatingActionButton: isDesktop
          ? null
          : (_isLeader(app)
              ? FloatingActionButton.extended(
                  onPressed: () => _addTask(app),
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Phân công'),
                )
              : null),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: HelioGradientHero(
                      title: title,
                      subtitle:
                          '$subtitleWork · ${_members.length} thành viên · ${_tasks.length} việc',
                    ),
                  ),
                  IconButton(
                    tooltip: 'Làm mới',
                    onPressed: _loading ? null : _reload,
                    icon: _loading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                            ),
                          )
                        : Icon(Icons.refresh_rounded, color: scheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: scheme.outlineVariant.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _buildMembersRow(context, app),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Công việc nhóm',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lọc theo trạng thái, kéo xuống để làm mới',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildTasksSection(context, app),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 340,
                            child: _buildInfoPanel(context, app),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildMembersRow(context, app),
                          const SizedBox(height: 8),
                          Text(
                            'Công việc nhóm',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lọc theo trạng thái · kéo để làm mới',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                          _buildTasksSection(context, app),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _groupSub?.cancel();
    _membersSub?.cancel();
    _tasksSub?.cancel();
    super.dispose();
  }
}
