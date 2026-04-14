class TodoTask {
  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  TodoTask({
    required this.id,
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });

  // Chuyển đổi từ Map (Firebase) sang Object
  factory TodoTask.fromMap(String id, Map<dynamic, dynamic> map) {
    return TodoTask(
      id: id,
      title: map['title'] ?? '',
      isDone: map['isDone'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  // Chuyển đổi từ Object sang Map để đẩy lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
