import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:todo_list/application/app_errors.dart';
import 'package:todo_list/domain/models/app_user.dart';
import 'package:todo_list/domain/models/group.dart';
import 'package:todo_list/domain/models/task_item.dart';
import 'package:todo_list/domain/repositories/auth_repository.dart'
    show AuthRepository, SignInFailure;
import 'package:todo_list/domain/repositories/group_repository.dart';
import 'package:todo_list/domain/repositories/task_repository.dart';
import 'package:todo_list/domain/repositories/user_repository.dart';

/// Điều phối repository, giữ trạng thái cho UI, thông báo [notifyListeners].
/// Không import widget Flutter (chỉ dùng [ChangeNotifier]).
class AppController extends ChangeNotifier {
  static const String assignAllMembersKey = '__all_members__';

  AppController({
    required AuthRepository auth,
    required UserRepository users,
    required GroupRepository groups,
    required TaskRepository tasks,
    FirebaseDatabase? database,
  })  : _auth = auth,
        _users = users,
        _groups = groups,
        _tasks = tasks,
        _database = database {
    if (_auth.currentUserId != null) {
      Future<void>.microtask(bootstrapAfterLogin);
    }
  }

  final AuthRepository _auth;
  final UserRepository _users;
  final GroupRepository _groups;
  final TaskRepository _tasks;
  /// Null khi test/mock không cần Realtime Database (admin trả về rỗng).
  final FirebaseDatabase? _database;

  AppUser? _profile;
  List<TaskItem> _personalTasks = <TaskItem>[];
  List<Group> _myGroups = <Group>[];
  bool _isDarkMode = false;
  double _fontScale = 1.0;
  String _fontFamily = 'Mặc định';
  bool _isAdminSession = false;
  StreamSubscription<List<Group>>? _groupsSub;

  bool get isAuthenticated => _auth.currentUserId != null;

  AppUser? get profile => _profile;

  List<TaskItem> get personalTasks => List<TaskItem>.unmodifiable(_personalTasks);

  List<Group> get myGroups => List<Group>.unmodifiable(_myGroups);

  String? get currentUserId => _auth.currentUserId;
  bool get isDarkMode => _isDarkMode;
  double get fontScale => _fontScale;
  String get fontFamily => _fontFamily;
  bool get isAdminSession => _isAdminSession;

  Future<void> bootstrapAfterLogin() async {
    final String? id = _auth.currentUserId;
    if (id == null) return;
    final results = await Future.wait<Object?>(<Future<Object?>>[
      _users
          .getUserById(id)
          .timeout(const Duration(seconds: 10), onTimeout: () => null),
      _tasks
          .listPersonalForUser(id)
          .timeout(const Duration(seconds: 10), onTimeout: () => <TaskItem>[]),
      _groups
          .listGroupsForUser(id)
          .timeout(const Duration(seconds: 10), onTimeout: () => <Group>[]),
    ]);
    _profile = results[0] as AppUser?;
    _personalTasks = (results[1] as List<TaskItem>);
    _myGroups = (results[2] as List<Group>);
    _profile ??= _buildFallbackProfileFromAuth(id);
    _groupsSub?.cancel();
    _groupsSub = _groups.watchGroupsForUser(id).listen((List<Group> groups) {
      _myGroups = groups;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> clearSessionState() async {
    await _groupsSub?.cancel();
    _groupsSub = null;
    _profile = null;
    _personalTasks = <TaskItem>[];
    _myGroups = <Group>[];
    notifyListeners();
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final SignInFailure? fail = await _auth.signIn(
        email: email,
        password: password,
      );
      if (fail != null) {
        return switch (fail) {
          SignInFailure.invalidCredentials =>
            'Email hoặc mật khẩu không đúng.',
          SignInFailure.networkUnavailable =>
            'Không kết nối được Firebase. Kiểm tra mạng hoặc thử lại sau.',
          SignInFailure.tooManyRequests =>
            'Đăng nhập quá nhiều lần. Vui lòng đợi vài phút rồi thử lại.',
        };
      }
      _isAdminSession =
          email.trim().toLowerCase() == 'admin@gmail.com' &&
          password == 'admin123';
      await bootstrapAfterLogin();
      return null;
    } on TimeoutException {
      return 'Kết nối dữ liệu quá chậm. Vui lòng thử lại.';
    } catch (e) {
      final String mapped = mapRepositoryErrorToMessage(e);
      if (mapped == 'Đã có lỗi xảy ra. Thử lại sau.') {
        return 'Mời thành viên thất bại: $e';
      }
      return mapped;
    }
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || phone.trim().isEmpty) {
      return 'Vui lòng nhập đủ họ tên, email và số điện thoại.';
    }
    if (password.length < 6) {
      return 'Mật khẩu cần tối thiểu 6 ký tự.';
    }
    try {
      final String? err = await _auth.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      if (err != null) return err;
      _isAdminSession = false;
      await bootstrapAfterLogin();
      return null;
    } on TimeoutException {
      return 'Đăng ký thành công nhưng tải dữ liệu chậm. Hãy mở lại app.';
    } catch (e) {
      return mapRepositoryErrorToMessage(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await clearSessionState();
    _isAdminSession = false;
  }

  Future<void> refreshPersonalTasks() async {
    final String? id = _auth.currentUserId;
    if (id == null) return;
    _personalTasks = await _tasks.listPersonalForUser(id);
    notifyListeners();
  }

  Future<void> refreshGroups() async {
    final String? id = _auth.currentUserId;
    if (id == null) return;
    try {
      _myGroups = await _groups.listGroupsForUser(id);
      notifyListeners();
    } catch (e) {
      throw StateError('Refresh groups failed: $e');
    }
  }

  Future<String?> updateProfile({
    required String name,
    required String phone,
    required String currentPassword,
  }) async {
    final AppUser? currentProfile = _profile;
    if (currentProfile == null) return 'Không tìm thấy hồ sơ người dùng.';
    if (name.trim().isEmpty || phone.trim().isEmpty) {
      return 'Họ tên và số điện thoại không được để trống.';
    }
    final String? id = currentUserId;
    if (id == null) return 'Chưa đăng nhập.';
    final String? authErr = await _auth.reauthenticate(
      email: currentProfile.email,
      password: currentPassword,
    );
    if (authErr != null) return authErr;
    _profile = await _users.updateProfile(
      userId: id,
      name: name,
      email: currentProfile.email,
      phone: phone,
    );
    notifyListeners();
    return null;
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
  }

  Future<void> setFontScale(double value) async {
    _fontScale = value.clamp(0.9, 1.3);
    notifyListeners();
  }

  Future<void> setFontFamily(String value) async {
    _fontFamily = value;
    notifyListeners();
  }

  Future<List<AppUser>> loadAllUsersForAdmin() async {
    final FirebaseDatabase? db = _database;
    if (db == null) return <AppUser>[];
    final DataSnapshot snap = await db.ref('users').get();
    if (!snap.exists || snap.value == null) return <AppUser>[];
    final Object? raw = snap.value;
    if (raw is! Map) return <AppUser>[];
    final List<AppUser> list = <AppUser>[];
    for (final MapEntry<dynamic, dynamic> e in raw.entries) {
      final Object? v = e.value;
      if (v is! Map) continue;
      final Map<String, dynamic> m = v.map(
        (dynamic k, dynamic val) => MapEntry<String, dynamic>(k.toString(), val),
      );
      list.add(
        AppUser(
          id: e.key.toString(),
          name: (m['name'] as String?) ?? 'Chưa cập nhật',
          email: (m['email'] as String?) ?? '',
          phone: (m['phone'] as String?) ?? '',
        ),
      );
    }
    return list;
  }

  Future<List<String>> loadLoginHistoryForAdmin() async {
    final FirebaseDatabase? db = _database;
    if (db == null) return <String>[];
    final DataSnapshot query = await db
        .ref('login_history')
        .orderByChild('time')
        .limitToLast(30)
        .get();
    if (!query.exists || query.value == null) return <String>[];
    final Object? raw = query.value;
    if (raw is! Map) return <String>[];
    final List<MapEntry<dynamic, dynamic>> entries =
        raw.entries.toList();
    entries.sort((MapEntry<dynamic, dynamic> a, MapEntry<dynamic, dynamic> b) {
      final int ta = _loginTimeMillis(a.value);
      final int tb = _loginTimeMillis(b.value);
      return tb.compareTo(ta);
    });
    return entries.map((MapEntry<dynamic, dynamic> e) {
      final Object? v = e.value;
      if (v is! Map) return 'unknown - không rõ thời gian';
      final Map<String, dynamic> data = v.map(
        (dynamic k, dynamic val) => MapEntry<String, dynamic>(k.toString(), val),
      );
      final DateTime? time = _parseLoginTime(data['time']);
      final String email = (data['email'] as String?) ?? 'unknown';
      final String textTime = time == null
          ? 'không rõ thời gian'
          : '${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      return '$email - $textTime';
    }).toList();
  }

  static int _loginTimeMillis(Object? value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return 0;
  }

  static DateTime? _parseLoginTime(Object? value) {
    if (value == null) return null;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  AppUser _buildFallbackProfileFromAuth(String uid) {
    final User? u = FirebaseAuth.instance.currentUser;
    final String email = u?.email ?? '';
    return AppUser(
      id: uid,
      name: email.isEmpty ? 'Người dùng' : email.split('@').first,
      email: email,
      phone: '',
    );
  }

  Future<String?> createGroup({
    required String name,
    required String workDescription,
    String? companyName,
  }) async {
    if (name.trim().isEmpty) {
      return 'Tên nhóm không được để trống.';
    }
    if (workDescription.trim().isEmpty) {
      return 'Vui lòng nhập công việc chính của nhóm.';
    }
    final String? id = _auth.currentUserId;
    if (id == null) return 'Chưa đăng nhập.';
    try {
      await _groups.createGroup(
        userId: id,
        name: name,
        workDescription: workDescription,
        companyName: companyName,
      );
      await refreshGroups();
      return null;
    } catch (e) {
      return mapRepositoryErrorToMessage(e);
    }
  }

  Future<String?> addMemberToGroup({
    required String groupId,
    required String memberEmail,
  }) async {
    final String? id = _auth.currentUserId;
    if (id == null) return 'Chưa đăng nhập.';
    try {
      await _groups.addMemberByEmail(
        groupId: groupId,
        actorUserId: id,
        memberEmail: memberEmail,
      );
      await refreshGroups();
      notifyListeners();
      return null;
    } catch (e) {
      return mapRepositoryErrorToMessage(e);
    }
  }

  Future<List<AppUser>> loadGroupMembers(String groupId) {
    return _groups.listMembers(groupId);
  }

  Stream<List<AppUser>> watchGroupMembers(String groupId) {
    return _groups.watchMembers(groupId);
  }

  Future<Group?> loadGroupById(String groupId) {
    return _groups.getGroupById(groupId);
  }

  Stream<Group?> watchGroupById(String groupId) {
    return _groups.watchGroupById(groupId);
  }

  Future<List<TaskItem>> loadGroupTasks(String groupId) async {
    final String? id = _auth.currentUserId;
    if (id == null) return <TaskItem>[];
    return _tasks.listForGroup(groupId: groupId, userId: id);
  }

  Stream<List<TaskItem>> watchGroupTasks(String groupId) {
    final String? id = _auth.currentUserId;
    if (id == null) return Stream<List<TaskItem>>.value(<TaskItem>[]);
    return _tasks.watchForGroup(groupId: groupId, userId: id);
  }

  Future<String?> addPersonalTask({
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    if (title.trim().isEmpty) {
      return 'Tiêu đề không được để trống.';
    }
    final String? id = _auth.currentUserId;
    if (id == null) return 'Chưa đăng nhập.';
    await _tasks.addPersonalTask(
      userId: id,
      title: title,
      description: description,
      dueDate: dueDate,
    );
    await refreshPersonalTasks();
    return null;
  }

  Future<String?> addGroupTask({
    required String groupId,
    required String assignedToUserId,
    required String title,
    required String description,
    required DateTime dueDate,
  }) async {
    if (title.trim().isEmpty) {
      return 'Tiêu đề không được để trống.';
    }
    final String? id = _auth.currentUserId;
    if (id == null) return 'Chưa đăng nhập.';
    try {
      final Group? group = await _groups.getGroupById(groupId);
      if (group == null) return 'Không tìm thấy nhóm.';
      if (group.leaderUserId != id) {
        return 'Chỉ trưởng nhóm mới có quyền phân công nhiệm vụ.';
      }
      if (assignedToUserId != assignAllMembersKey &&
          !group.memberUserIds.contains(assignedToUserId)) {
        return 'Người được giao không thuộc nhóm.';
      }
      await _tasks.addGroupTask(
        groupId: groupId,
        userId: id,
        assignedToUserId: assignedToUserId,
        title: title,
        description: description,
        dueDate: dueDate,
      );
      notifyListeners();
      return null;
    } catch (e) {
      return mapRepositoryErrorToMessage(e);
    }
  }

  Future<void> setTaskDone(String taskId, bool isDone) async {
    final String? id = _auth.currentUserId;
    if (id == null) return;
    await _tasks.setTaskDone(taskId: taskId, isDone: isDone, userId: id);
    await refreshPersonalTasks();
    notifyListeners();
  }

  Future<void> deletePersonalTask(String taskId) async {
    final String? id = _auth.currentUserId;
    if (id == null) return;
    await _tasks.deleteTask(taskId: taskId, userId: id);
    await refreshPersonalTasks();
  }

  Future<String?> setGroupTaskDone({
    required String groupId,
    required String taskId,
    required bool isDone,
  }) async {
    final String? id = _auth.currentUserId;
    if (id == null) return 'Chưa đăng nhập.';
    final Group? group = await _groups.getGroupById(groupId);
    if (group == null) return 'Không tìm thấy nhóm.';
    final bool isLeader = group.leaderUserId == id;
    final List<TaskItem> tasks = await _tasks.listForGroup(
      groupId: groupId,
      userId: id,
    );
    TaskItem? target;
    for (final TaskItem task in tasks) {
      if (task.id == taskId) {
        target = task;
        break;
      }
    }
    if (target == null) return 'Không tìm thấy nhiệm vụ.';
    if (!isLeader) {
      final bool isAssignedToAll =
          target.assignedToUserId == assignAllMembersKey;
      if (!isAssignedToAll && target.assignedToUserId != id) {
        return 'Nhiệm vụ này không được giao cho bạn.';
      }
      if (!target.isDone && !isDone) {
        return null;
      }
      if (target.isDone && !isDone) {
        return 'Chỉ trưởng nhóm mới có quyền trả về chưa hoàn thành.';
      }
    }
    await _tasks.setTaskDone(taskId: taskId, isDone: isDone, userId: id);
    notifyListeners();
    return null;
  }

  Future<void> deleteGroupTask({
    required String groupId,
    required String taskId,
  }) async {
    final String? id = _auth.currentUserId;
    if (id == null) return;
    await _tasks.deleteTask(taskId: taskId, userId: id);
    notifyListeners();
  }

  @override
  void dispose() {
    _groupsSub?.cancel();
    super.dispose();
  }
}
