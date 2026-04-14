import 'package:firebase_database/firebase_database.dart';
import 'package:todo_list/data/firebase_rtdb.dart';
import 'package:todo_list/models/todo_task.dart';

class DatabaseService {
  DatabaseReference get _tasks => firebaseRtdb().ref('tasks');

  // Lấy danh sách Task theo thời gian thực (Stream)
  Stream<List<TodoTask>> getTasksStream() {
    return _tasks.onValue.map((DatabaseEvent event) {
      final Object? raw = event.snapshot.value;
      if (raw == null) return <TodoTask>[];
      if (raw is! Map) return <TodoTask>[];

      final Map<dynamic, dynamic> data = raw;
      final List<TodoTask> list = <TodoTask>[];
      for (final MapEntry<dynamic, dynamic> entry in data.entries) {
        final Object? v = entry.value;
        if (v is! Map) continue;
        list.add(
          TodoTask.fromMap(
            entry.key.toString(),
            Map<dynamic, dynamic>.from(v),
          ),
        );
      }
      list.sort((TodoTask a, TodoTask b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // Thêm một Task mới
  Future<void> addTask(String title) async {
    final DatabaseReference newTaskRef = _tasks.push();
    final TodoTask task = TodoTask(
      id: newTaskRef.key!,
      title: title,
      createdAt: DateTime.now(),
    );
    await newTaskRef.set(task.toMap());
  }

  // Cập nhật trạng thái hoàn thành
  Future<void> toggleTaskStatus(String id, bool currentStatus) async {
    await _tasks.child(id).update(<String, dynamic>{
      'isDone': !currentStatus,
    });
  }

  // Xóa một Task
  Future<void> deleteTask(String id) async {
    await _tasks.child(id).remove();
  }
}
