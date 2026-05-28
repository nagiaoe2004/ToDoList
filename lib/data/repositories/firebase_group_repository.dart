import 'package:firebase_database/firebase_database.dart';
import 'package:todo_list/data/firebase_rtdb.dart';
import 'package:todo_list/domain/models/app_user.dart';
import 'package:todo_list/domain/models/group.dart';
import 'package:todo_list/domain/repositories/group_repository.dart';
import 'package:todo_list/domain/repositories/user_repository.dart';

class FirebaseGroupRepository implements GroupRepository {
  FirebaseGroupRepository({
    required UserRepository users,
    FirebaseDatabase? database,
  })  : _users = users,
        _db = database ?? firebaseRtdb();

  final UserRepository _users;
  final FirebaseDatabase _db;

  DatabaseReference get _groups => _db.ref('groups');

  DatabaseReference _userGroups(String userId) =>
      _db.ref('userGroups').child(userId);

  static List<String> _memberListFromMap(Map<String, dynamic> map) {
    final Object? raw = map['memberUserIds'];
    if (raw is List) {
      return raw.map((dynamic e) => e.toString()).toList();
    }
    if (raw is Map) {
      return raw.entries
          .where((MapEntry<dynamic, dynamic> e) => e.value == true)
          .map((MapEntry<dynamic, dynamic> e) => e.key.toString())
          .toList();
    }
    return <String>[];
  }

  @override
  Future<List<Group>> listGroupsForUser(String userId) async {
    final DataSnapshot ug = await _userGroups(userId).get();
    if (!ug.exists || ug.value == null) return <Group>[];
    final Object? raw = ug.value;
    if (raw is! Map) return <Group>[];
    final List<Future<Group?>> loaders = <Future<Group?>>[];
    for (final MapEntry<dynamic, dynamic> e in raw.entries) {
      final String gid = e.key.toString();
      loaders.add(_loadGroup(gid));
    }
    final List<Group?> resolved = await Future.wait(loaders);
    return resolved.whereType<Group>().toList();
  }

  @override
  Stream<List<Group>> watchGroupsForUser(String userId) {
    return _userGroups(userId).onValue.asyncMap((DatabaseEvent event) async {
      final Object? raw = event.snapshot.value;
      if (raw is! Map) return <Group>[];
      final List<Future<Group?>> loaders = <Future<Group?>>[];
      for (final MapEntry<dynamic, dynamic> e in raw.entries) {
        final String gid = e.key.toString();
        loaders.add(_loadGroup(gid));
      }
      final List<Group?> resolved = await Future.wait(loaders);
      return resolved.whereType<Group>().toList();
    });
  }

  @override
  Future<Group?> getGroupById(String groupId) {
    return _loadGroup(groupId);
  }

  Future<Group?> _loadGroup(String groupId) async {
    final DataSnapshot s = await _groups.child(groupId).get();
    if (!s.exists || s.value == null) return null;
    final Object? raw = s.value;
    if (raw is! Map) return null;
    final Map<String, dynamic> data = raw.map(
      (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
    );
    return _fromDoc(groupId, data);
  }

  @override
  Future<Group> createGroup({
    required String userId,
    required String name,
    required String workDescription,
    String? companyName,
  }) async {
    final String trimmed = name.trim();
    final String work = workDescription.trim();
    final String? company = companyName?.trim();
    if (trimmed.isEmpty) throw ArgumentError('Group name required');
    if (work.isEmpty) throw ArgumentError('Work description required');
    final DatabaseReference newRef = _groups.push();
    final String id = newRef.key!;
    await newRef.set(<String, dynamic>{
      'name': trimmed,
      'workDescription': work,
      'companyName': (company == null || company.isEmpty) ? null : company,
      'leaderUserId': userId,
      'memberUserIds': <String>[userId],
      'createdAt': ServerValue.timestamp,
    });
    await _userGroups(userId).child(id).set(true);
    return Group(
      id: id,
      name: trimmed,
      workDescription: work,
      companyName: (company == null || company.isEmpty) ? null : company,
      leaderUserId: userId,
      memberUserIds: <String>[userId],
    );
  }

  @override
  Future<void> addMemberByEmail({
    required String groupId,
    required String actorUserId,
    required String memberEmail,
  }) async {
    final DataSnapshot groupSnap = await _groups.child(groupId).get();
    if (!groupSnap.exists || groupSnap.value == null) {
      throw StateError('Group not found');
    }
    final Object? graw = groupSnap.value;
    if (graw is! Map) throw StateError('Group not found');
    final Map<String, dynamic> gdata = graw.map(
      (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
    );
    final Group group = _fromDoc(groupSnap.key ?? groupId, gdata);
    if (!group.memberUserIds.contains(actorUserId)) {
      throw StateError('Not a member');
    }
    final AppUser? target = await _users.findUserByEmail(memberEmail);
    if (target == null) throw StateError('User not found for email');
    if (group.memberUserIds.contains(target.id)) return;
    final List<String> next = List<String>.from(group.memberUserIds)
      ..add(target.id);
    await _groups.child(groupId).update(<String, dynamic>{
      'memberUserIds': next,
    });
    await _userGroups(target.id).child(groupId).set(true);
  }

  @override
  Future<List<AppUser>> listMembers(String groupId) async {
    final DataSnapshot groupSnap = await _groups.child(groupId).get();
    if (!groupSnap.exists || groupSnap.value == null) return <AppUser>[];
    final Object? graw = groupSnap.value;
    if (graw is! Map) return <AppUser>[];
    final Map<String, dynamic> gdata = graw.map(
      (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
    );
    final Group group = _fromDoc(groupSnap.key ?? groupId, gdata);
    final List<AppUser> members = <AppUser>[];
    for (final String uid in group.memberUserIds) {
      final AppUser? user = await _users.getUserById(uid);
      if (user != null) members.add(user);
    }
    return members;
  }

  @override
  Stream<List<AppUser>> watchMembers(String groupId) {
    return _groups.child(groupId).onValue.asyncMap((DatabaseEvent event) async {
      final Object? raw = event.snapshot.value;
      if (raw is! Map) return <AppUser>[];
      final Map<String, dynamic> gdata = raw.map(
        (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
      );
      final Group group = _fromDoc(groupId, gdata);
      final List<AppUser> members = <AppUser>[];
      for (final String uid in group.memberUserIds) {
        final AppUser? user = await _users.getUserById(uid);
        if (user != null) members.add(user);
      }
      return members;
    });
  }

  @override
  Stream<Group?> watchGroupById(String groupId) {
    return _groups.child(groupId).onValue.map((DatabaseEvent event) {
      final Object? raw = event.snapshot.value;
      if (raw is! Map) return null;
      final Map<String, dynamic> data = raw.map(
        (dynamic k, dynamic v) => MapEntry<String, dynamic>(k.toString(), v),
      );
      return _fromDoc(groupId, data);
    });
  }

  Group _fromDoc(String id, Map<String, dynamic> map) {
    final String name = map['name']?.toString().trim() ?? '';
    final String work = map['workDescription']?.toString().trim() ?? '';
    final String companyRaw = map['companyName']?.toString().trim() ?? '';
    final List<String> members = _memberListFromMap(map);
    final String leader = map['leaderUserId']?.toString().trim() ??
        (members.isEmpty ? '' : members.first);
    return Group(
      id: id,
      name: name.isEmpty ? 'Nhóm' : name,
      workDescription: work.isEmpty ? 'Chưa mô tả công việc' : work,
      companyName: companyRaw.isEmpty ? null : companyRaw,
      leaderUserId: leader,
      memberUserIds: members,
    );
  }
}
