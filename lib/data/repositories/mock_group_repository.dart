import 'dart:async';

import 'package:todo_list/data/in_memory_store.dart';
import 'package:todo_list/domain/models/app_user.dart';
import 'package:todo_list/domain/models/group.dart';
import 'package:todo_list/domain/repositories/group_repository.dart';
import 'package:todo_list/domain/repositories/user_repository.dart';

/// Mock: quản lý nhóm và thành viên trong store.
class MockGroupRepository implements GroupRepository {
  MockGroupRepository(this._store, this._users);

  final InMemoryStore _store;
  final UserRepository _users;
  int _groupSeq = 10;
  final StreamController<int> _changes = StreamController<int>.broadcast();

  void _emitChange() {
    if (!_changes.isClosed) {
      _changes.add(DateTime.now().millisecondsSinceEpoch);
    }
  }

  @override
  Future<List<Group>> listGroupsForUser(String userId) async {
    return _store.groups
        .where((Group g) => g.memberUserIds.contains(userId))
        .toList();
  }

  @override
  Stream<List<Group>> watchGroupsForUser(String userId) {
    return _changes.stream.startWith(0).asyncMap(
      (_) => listGroupsForUser(userId),
    );
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
    if (trimmed.isEmpty) {
      throw ArgumentError('Group name required');
    }
    if (work.isEmpty) {
      throw ArgumentError('Work description required');
    }
    final Group g = Group(
      id: 'g-${_groupSeq++}',
      name: trimmed,
      workDescription: work,
      companyName: (company == null || company.isEmpty) ? null : company,
      leaderUserId: userId,
      memberUserIds: <String>[userId],
    );
    _store.groups.add(g);
    _emitChange();
    return g;
  }

  @override
  Future<void> addMemberByEmail({
    required String groupId,
    required String actorUserId,
    required String memberEmail,
  }) async {
    final int gi = _store.groups.indexWhere((Group g) => g.id == groupId);
    if (gi == -1) throw StateError('Group not found');
    final Group g = _store.groups[gi];
    if (!g.memberUserIds.contains(actorUserId)) {
      throw StateError('Not a member');
    }
    final AppUser? target = await _users.findUserByEmail(memberEmail);
    if (target == null) {
      throw StateError('User not found for email');
    }
    if (target.id == actorUserId) {
      throw StateError('Already in group');
    }
    if (g.memberUserIds.contains(target.id)) {
      return;
    }
    final List<String> next = List<String>.from(g.memberUserIds)..add(target.id);
    _store.groups[gi] = g.copyWith(memberUserIds: next);
    _emitChange();
  }

  @override
  Future<List<AppUser>> listMembers(String groupId) async {
    final int gi = _store.groups.indexWhere((Group g) => g.id == groupId);
    if (gi == -1) return <AppUser>[];
    final Group g = _store.groups[gi];
    final List<AppUser> out = <AppUser>[];
    for (final String id in g.memberUserIds) {
      final AppUser? u = await _users.getUserById(id);
      if (u != null) out.add(u);
    }
    return out;
  }

  @override
  Stream<List<AppUser>> watchMembers(String groupId) {
    return _changes.stream.startWith(0).asyncMap((_) => listMembers(groupId));
  }

  @override
  Future<Group?> getGroupById(String groupId) async {
    final int gi = _store.groups.indexWhere((Group g) => g.id == groupId);
    if (gi == -1) return null;
    return _store.groups[gi];
  }

  @override
  Stream<Group?> watchGroupById(String groupId) {
    return _changes.stream.startWith(0).asyncMap((_) => getGroupById(groupId));
  }
}

extension on Stream<int> {
  Stream<int> startWith(int initialValue) async* {
    yield initialValue;
    yield* this;
  }
}
