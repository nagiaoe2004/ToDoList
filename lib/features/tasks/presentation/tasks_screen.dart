import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/domain/models/task_filter.dart';
import 'package:todo_list/domain/models/task_item.dart';
import 'package:todo_list/widgets/filter_bar.dart';
import 'package:todo_list/widgets/stat_chip.dart';
import 'package:todo_list/shared/presentation/helio_surface.dart';
import 'package:todo_list/widgets/task_tile.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  TaskFilter _selectedFilter = TaskFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Lọc theo chip + ô tìm (chỉ tiêu đề).
  List<TaskItem> _filtered(List<TaskItem> tasks) {
    final String keyword = _searchController.text.trim().toLowerCase();
    return tasks.where((TaskItem t) {
      final bool passFilter = switch (_selectedFilter) {
        TaskFilter.all => true,
        TaskFilter.pending => !t.isDone,
        TaskFilter.completed => t.isDone,
      };
      final bool passKeyword =
          keyword.isEmpty || t.title.toLowerCase().contains(keyword);
      return passFilter && passKeyword;
    }).toList();
  }

  Future<void> _showCreateDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    DateTime due = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: const Text('Tạo công việc mới'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(hintText: 'Tiêu đề'),
                      autofocus: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Mô tả'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
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
                                const Duration(days: 365 * 3),
                              ),
                            );
                            if (picked != null) {
                              setStateDialog(() => due = picked);
                            }
                          },
                          child: Text('${due.day}/${due.month}/${due.year}'),
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
                    final AppController app = context.read<AppController>();
                    final String? err = await app.addPersonalTask(
                      title: titleController.text,
                      description: descController.text,
                      dueDate: due,
                    );
                    if (!context.mounted) return;
                    if (err != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(err)));
                      return;
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 980;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        label: const Text('Việc mới'),
        icon: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Consumer<AppController>(
          builder: (BuildContext context, AppController app, _) {
            final List<TaskItem> tasks = app.personalTasks;
            final int doneCount = tasks.where((TaskItem t) => t.isDone).length;
            final List<TaskItem> visible = _filtered(tasks);
            return isDesktop
                ? _buildDesktop(context, app, tasks, doneCount, visible)
                : _buildMobile(context, app, tasks, doneCount, visible);
          },
        ),
      ),
    );
  }

  Widget _buildMobile(
    BuildContext context,
    AppController app,
    List<TaskItem> tasks,
    int done,
    List<TaskItem> visible,
  ) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HelioGradientHero(
            title: 'Công việc của tôi',
            subtitle: 'Hoàn thành $done/${tasks.length} việc',
            centered: true,
          ),
          const SizedBox(height: 14),
          _buildStats(tasks, done),
          const SizedBox(height: 12),
          FilterBar(
            controller: _searchController,
            selected: _selectedFilter,
            onSearchChanged: (_) => setState(() {}),
            onFilterChanged: (TaskFilter val) =>
                setState(() => _selectedFilter = val),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildTaskList(app, visible)),
        ],
      ),
    );
  }

  Widget _buildDesktop(
    BuildContext context,
    AppController app,
    List<TaskItem> tasks,
    int done,
    List<TaskItem> visible,
  ) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 360,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                HelioGradientHero(
                  title: 'Công việc của tôi',
                  subtitle: null,
                  centered: true,
                ),
                const SizedBox(height: 14),
                _buildStats(tasks, done),
                const SizedBox(height: 14),
                FilterBar(
                  controller: _searchController,
                  selected: _selectedFilter,
                  onSearchChanged: (_) => setState(() {}),
                  onFilterChanged: (TaskFilter val) =>
                      setState(() => _selectedFilter = val),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 16, 16),
            child: _buildTaskList(app, visible),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(List<TaskItem> tasks, int done) {
    return Row(
      children: <Widget>[
        Expanded(
          child: StatChip(
            label: 'Tổng',
            value: '${tasks.length}',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatChip(
            label: 'Xong',
            value: '$done',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatChip(
            label: 'Đang làm',
            value: '${tasks.length - done}',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(AppController app, List<TaskItem> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('Không có công việc trong bộ lọc này.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: tasks.length,
      separatorBuilder: (BuildContext _, int __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final TaskItem task = tasks[index];
        return TaskTile(
          item: task,
          onChanged: (bool value) async {
            final bool? confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(value ? 'Xác nhận hoàn thành' : 'Xác nhận bỏ hoàn thành'),
                content: Text(
                  value
                      ? 'Bạn chắc chắn muốn đánh dấu công việc này đã hoàn thành?'
                      : 'Bạn muốn chuyển công việc này về chưa hoàn thành?',
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
            await app.setTaskDone(task.id, value);
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
            await app.deletePersonalTask(task.id);
          },
        );
      },
    );
  }
}
