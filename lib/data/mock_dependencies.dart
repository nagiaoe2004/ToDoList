import 'package:todo_list/data/in_memory_store.dart';
import 'package:todo_list/data/repositories/mock_auth_repository.dart';
import 'package:todo_list/data/repositories/mock_group_repository.dart';
import 'package:todo_list/data/repositories/mock_task_repository.dart';
import 'package:todo_list/data/repositories/mock_user_repository.dart';
import 'package:todo_list/domain/repositories/auth_repository.dart';
import 'package:todo_list/domain/repositories/group_repository.dart';
import 'package:todo_list/domain/repositories/task_repository.dart';
import 'package:todo_list/domain/repositories/user_repository.dart';

/// Gom mock repository + store để [main] inject vào [AppController].
class MockDependencies {
  MockDependencies({
    required this.store,
    required this.auth,
    required this.users,
    required this.groups,
    required this.tasks,
  });

  final InMemoryStore store;
  final AuthRepository auth;
  final UserRepository users;
  final GroupRepository groups;
  final TaskRepository tasks;

  static MockDependencies create() {
    final InMemoryStore store = InMemoryStore.seeded();
    final MockUserRepository users = MockUserRepository(store);
    final MockAuthRepository auth = MockAuthRepository(store);
    final MockGroupRepository groups = MockGroupRepository(store, users);
    final MockTaskRepository tasks = MockTaskRepository(store);
    return MockDependencies(
      store: store,
      auth: auth,
      users: users,
      groups: groups,
      tasks: tasks,
    );
  }
}
