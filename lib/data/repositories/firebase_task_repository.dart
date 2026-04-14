import 'package:firebase_database/firebase_database.dart';
import 'package:todo_list/data/firebase_rtdb.dart';
import 'package:todo_list/domain/models/task_item.dart';
import 'package:todo_list/domain/repositories/task_repository.dart';

class FirebaseTaskRepository implements TaskRepository {
  FirebaseTaskRepository({FirebaseDatabase? database})
      : _db = database ?? firebaseRtdb();

  final FirebaseDatabase _db;

  DatabaseReference get _tasks => _db.ref('tasks');

  static Map<String, dynamic> _stringKeyMap(Object? raw) {
    if (raw is! Map) return <String, dynamic>{};
    return raw.map(
      (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
    );
  }

  Future<List<TaskItem>> _tasksFromQuery(Query query) async {
    final DataSnapshot snap = await query.get();
    final List<TaskItem> items = <TaskItem>[];
    if (!snap.exists || snap.value == null) return items;
    final Object? raw = snap.value;
    if (raw is! Map) return items;
    for (final MapEntry<dynamic, dynamic> e in raw.entries) {
      final Object? v = e.value;
      if (v is! Map) continue;
      items.add(
        _fromMap(
          e.key.toString(),
          _stringKeyMap(v),
        ),
      );
    }
    items.sort((TaskItem a, TaskItem b) => a.dueDate.compareTo(b.dueDate));
    return items;
  }

  @override
  Future<List<TaskItem>> listPersonalForUser(String userId) async {
    final Query query =
        _tasks.orderByChild('createdByUserId').equalTo(userId);
    final List<TaskItem> all = await _tasksFromQuery(query);
    return all.where((TaskItem t) => t.groupId == null).toList();
  }

  @override
  Future<List<TaskItem>> listForGroup({
    required String groupId,
    required String userId,
  }) async {
    final Query query = _tasks.orderByChild('groupId').equalTo(groupId);
    return _tasksFromQuery(query);
  }

  @override
  Future<TaskItem> addPersonalTask({
    required String userId,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    final DatabaseReference newRef = _tasks.push();
    final String id = newRef.key!;
    final TaskItem item = TaskItem(
      id: id,
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      createdByUserId: userId,
    );
    await newRef.set(_toMap(item));
    return item;
  }

  @override
  Future<TaskItem> addGroupTask({
    required String groupId,
    required String userId,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    final DatabaseReference newRef = _tasks.push();
    final String id = newRef.key!;
    final TaskItem item = TaskItem(
      id: id,
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      createdByUserId: userId,
      groupId: groupId,
    );
    await newRef.set(_toMap(item));
    return item;
  }

  @override
  Future<void> setTaskDone({
    required String taskId,
    required bool isDone,
    required String userId,
  }) async {
    await _tasks.child(taskId).update(<String, dynamic>{
      'isDone': isDone,
      'updatedAt': ServerValue.timestamp,
    });
  }

  @override
  Future<void> deleteTask({
    required String taskId,
    required String userId,
  }) async {
    await _tasks.child(taskId).remove();
  }

  TaskItem _fromMap(String id, Map<String, dynamic> map) {
    return TaskItem(
      id: id,
      title: (map['title'] as String?) ?? 'Công việc',
      description: (map['description'] as String?) ?? '',
      dueDate: _parseMillis(map['dueDate']),
      createdByUserId: (map['createdByUserId'] as String?) ?? '',
      groupId: _optionalString(map['groupId']),
      isDone: (map['isDone'] as bool?) ?? false,
    );
  }

  static String? _optionalString(Object? value) {
    if (value == null) return null;
    final String s = value.toString();
    return s.isEmpty ? null : s;
  }

  static DateTime _parseMillis(Object? value) {
    if (value == null) return DateTime.now();
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return DateTime.now();
  }

  Map<String, dynamic> _toMap(TaskItem item) {
    final Map<String, dynamic> map = <String, dynamic>{
      'title': item.title,
      'description': item.description,
      'dueDate': item.dueDate.millisecondsSinceEpoch,
      'createdByUserId': item.createdByUserId,
      'isDone': item.isDone,
      'updatedAt': ServerValue.timestamp,
    };
    if (item.groupId != null) {
      map['groupId'] = item.groupId;
    }
    return map;
  }
}
