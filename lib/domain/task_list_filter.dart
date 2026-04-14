import 'package:todo_list/domain/models/task_filter.dart';
import 'package:todo_list/domain/models/task_item.dart';

/// Lọc danh sách công việc theo từ khóa và bộ lọc trạng thái.
/// Thuộc tầng domain (quy tắc hiển thị), không phụ thuộc Flutter/widget.
abstract final class TaskListFilter {
  static List<TaskItem> apply(
    List<TaskItem> tasks,
    String searchRaw,
    TaskFilter filter,
  ) {
    final String keyword = searchRaw.trim().toLowerCase();
    return tasks.where((TaskItem item) {
      final bool passFilter = switch (filter) {
        TaskFilter.all => true,
        TaskFilter.pending => !item.isDone,
        TaskFilter.completed => item.isDone,
      };
      final bool passKeyword =
          keyword.isEmpty ||
          item.title.toLowerCase().contains(keyword) ||
          item.description.toLowerCase().contains(keyword);
      return passFilter && passKeyword;
    }).toList();
  }
}
