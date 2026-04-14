import 'package:todo_list/data/in_memory_store.dart';
import 'package:todo_list/domain/models/group.dart';
import 'package:todo_list/domain/models/task_item.dart';
import 'package:todo_list/domain/repositories/task_repository.dart';

/// Mock: việc cá nhân / nhóm; kiểm tra quyền thành viên nhóm.
class MockTaskRepository implements TaskRepository {
  MockTaskRepository(this._store);

  final InMemoryStore _store;

  bool _isGroupMember(String groupId, String userId) {
    final int gi = _store.groups.indexWhere((Group g) => g.id == groupId);
    if (gi == -1) return false;
    return _store.groups[gi].memberUserIds.contains(userId);
  }

  @override
  Future<List<TaskItem>> listPersonalForUser(String userId) async {
    return _store.tasks
        .where(
          (TaskItem t) => t.groupId == null && t.createdByUserId == userId,
        )
        .toList();
  }

  @override
  Future<List<TaskItem>> listForGroup({
    required String groupId,
    required String userId,
  }) async {
    if (!_isGroupMember(groupId, userId)) return <TaskItem>[];
    return _store.tasks
        .where((TaskItem t) => t.groupId == groupId)
        .toList();
  }

  @override
  Future<TaskItem> addPersonalTask({
    required String userId,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    final TaskItem t = TaskItem(
      id: _store.nextTaskId(),
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      createdByUserId: userId,
    );
    _store.tasks.insert(0, t);
    return t;
  }

  @override
  Future<TaskItem> addGroupTask({
    required String groupId,
    required String userId,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    if (!_isGroupMember(groupId, userId)) {
      throw StateError('Not a group member');
    }
    final TaskItem t = TaskItem(
      id: _store.nextTaskId(),
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      createdByUserId: userId,
      groupId: groupId,
    );
    _store.tasks.insert(0, t);
    return t;
  }

  @override
  Future<void> setTaskDone({
    required String taskId,
    required bool isDone,
    required String userId,
  }) async {
    final int ti = _store.tasks.indexWhere((TaskItem t) => t.id == taskId);
    if (ti == -1) return;
    final TaskItem t = _store.tasks[ti];
    if (t.groupId != null) {
      if (!_isGroupMember(t.groupId!, userId)) return;
    } else if (t.createdByUserId != userId) {
      return;
    }
    _store.tasks[ti] = t.copyWith(isDone: isDone);
  }

  @override
  Future<void> deleteTask({
    required String taskId,
    required String userId,
  }) async {
    final int ti = _store.tasks.indexWhere((TaskItem t) => t.id == taskId);
    if (ti == -1) return;
    final TaskItem t = _store.tasks[ti];
    if (t.groupId != null) {
      if (!_isGroupMember(t.groupId!, userId)) return;
    } else if (t.createdByUserId != userId) {
      return;
    }
    _store.tasks.removeAt(ti);
  }
}
