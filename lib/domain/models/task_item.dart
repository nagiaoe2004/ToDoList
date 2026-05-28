/// Một công việc; [groupId] null = việc cá nhân của [createdByUserId].
class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdByUserId,
    this.groupId,
    this.assignedToUserId,
    this.isDone = false,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String createdByUserId;
  final String? groupId;
  final String? assignedToUserId;
  final bool isDone;
  final DateTime? updatedAt;

  bool get isPersonal => groupId == null;

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? createdByUserId,
    String? groupId,
    String? assignedToUserId,
    bool? isDone,
    DateTime? updatedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      groupId: groupId ?? this.groupId,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      isDone: isDone ?? this.isDone,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
