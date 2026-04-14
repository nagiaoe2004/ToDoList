/// Một công việc; [groupId] null = việc cá nhân của [createdByUserId].
class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdByUserId,
    this.groupId,
    this.isDone = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String createdByUserId;
  final String? groupId;
  final bool isDone;

  bool get isPersonal => groupId == null;

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? createdByUserId,
    String? groupId,
    bool? isDone,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      groupId: groupId ?? this.groupId,
      isDone: isDone ?? this.isDone,
    );
  }
}
