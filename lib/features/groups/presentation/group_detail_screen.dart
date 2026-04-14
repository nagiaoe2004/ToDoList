import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/domain/models/app_user.dart';
import 'package:todo_list/domain/models/task_item.dart';
import 'package:todo_list/widgets/task_tile.dart';
import 'package:todo_list/shared/presentation/helio_surface.dart';

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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    final AppController app = context.read<AppController>();
    setState(() => _loading = true);
    final List<AppUser> m = await app.loadGroupMembers(widget.groupId);
    final List<TaskItem> t = await app.loadGroupTasks(widget.groupId);
    if (!mounted) return;
    setState(() {
      _members = m;
      _tasks = t;
      _loading = false;
    });
  }

  Future<void> _addMember(AppController app) async {
    final TextEditingController email = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Thêm thành viên'),
          content: TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email người dùng',
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
                if (!context.mounted) return;
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err)),
                  );
                  return;
                }
                Navigator.pop(context);
                await _reload();
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addTask(AppController app) async {
    final TextEditingController title = TextEditingController();
    final TextEditingController description = TextEditingController();
    DateTime due = DateTime.now();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text('Việc trong nhóm'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: title,
                      decoration: const InputDecoration(hintText: 'Tiêu đề'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: description,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Mô tả'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        const Text('Hạn'),
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
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                      title: title.text,
                      description: description.text,
                      dueDate: due,
                    );
                    if (!context.mounted) return;
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err)),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    await _reload();
                  },
                  child: const Text('Đăng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMembersRow(BuildContext context, AppController app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Thành viên',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _addMember(app),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Thêm'),
            ),
          ],
        ),
        SizedBox(
          height: 104,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _members.length,
                  separatorBuilder: (BuildContext _, int __) =>
                      const SizedBox(width: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final AppUser u = _members[index];
                    return Container(
                      width: 180,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            u.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            u.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Text(
                            u.phone,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTasksSection(BuildContext context, AppController app) {
    return Expanded(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có việc. Thêm việc để cả nhóm cùng tick.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                )
              : ListView.separated(
                  itemCount: _tasks.length,
                  separatorBuilder: (BuildContext _, int __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final TaskItem t = _tasks[index];
                    return TaskTile(
                      item: t,
                      onChanged: (bool v) async {
                        final bool? confirm = await showDialog<bool>(
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
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Không'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Xác nhận'),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) return;
                        await app.setGroupTaskDone(
                          groupId: widget.groupId,
                          taskId: t.id,
                          isDone: v,
                        );
                        await _reload();
                      },
                      onDelete: () async {
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Xác nhận xoá công việc'),
                            content: const Text(
                              'Bạn có chắc chắn muốn xoá task công việc này không?',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Không'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Có'),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) return;
                        await app.deleteGroupTask(
                          groupId: widget.groupId,
                          taskId: t.id,
                        );
                        await _reload();
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildInfoPanel(BuildContext context, AppController app) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Thông tin nhóm', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _infoTile(context, Icons.badge_rounded, 'Nhóm', widget.groupName),
          const SizedBox(height: 8),
          _infoTile(
            context,
            Icons.work_outline_rounded,
            'Công việc chính',
            widget.groupWorkDescription,
          ),
          if (widget.groupCompanyName != null && widget.groupCompanyName!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            _infoTile(
              context,
              Icons.apartment_rounded,
              'Công ty',
              widget.groupCompanyName!,
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
            Icons.task_alt_rounded,
            'Công việc',
            '${_tasks.length} task',
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _addTask(app),
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('Thêm việc nhóm'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: Theme.of(context).textTheme.bodyMedium,
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
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTask(app),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Việc nhóm'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: HelioGradientHero(
                      title: widget.groupName,
                      subtitle:
                          '${widget.groupWorkDescription} · ${_members.length} thành viên · ${_tasks.length} việc',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLow,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _buildMembersRow(context, app),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Công việc nhóm',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildTasksSection(context, app),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 330,
                            child: _buildInfoPanel(context, app),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildMembersRow(context, app),
                          const SizedBox(height: 10),
                          Text(
                            'Công việc nhóm',
                            style: Theme.of(context).textTheme.titleMedium,
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
}
