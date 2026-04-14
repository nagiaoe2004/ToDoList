import 'package:todo_list/domain/models/task_item.dart';

/// Công việc cá nhân và công việc trong nhóm (CRUD + tick xong).
abstract class TaskRepository {
  Future<List<TaskItem>> listPersonalForUser(String userId);

  Future<List<TaskItem>> listForGroup({
    required String groupId,
    required String userId,
  });

  Future<TaskItem> addPersonalTask({
    required String userId,
    required String title,
    required String description,
    required DateTime dueDate,
  });

  Future<TaskItem> addGroupTask({
    required String groupId,
    required String userId,
    required String title,
    required String description,
    required DateTime dueDate,
  });

  Future<void> setTaskDone({
    required String taskId,
    required bool isDone,
    required String userId,
  });

  Future<void> deleteTask({
    required String taskId,
    required String userId,
  });
}
