import 'package:firebase_database/firebase_database.dart';
import 'package:todo_list/data/firebase_rtdb.dart';
import 'package:todo_list/data/repositories/firebase_auth_repository.dart';
import 'package:todo_list/data/repositories/firebase_group_repository.dart';
import 'package:todo_list/data/repositories/firebase_task_repository.dart';
import 'package:todo_list/data/repositories/firebase_user_repository.dart';
import 'package:todo_list/domain/repositories/auth_repository.dart';
import 'package:todo_list/domain/repositories/group_repository.dart';
import 'package:todo_list/domain/repositories/task_repository.dart';
import 'package:todo_list/domain/repositories/user_repository.dart';

class FirebaseDependencies {
  FirebaseDependencies({
    required this.database,
    required this.auth,
    required this.users,
    required this.groups,
    required this.tasks,
  });

  /// Cùng một instance Realtime Database với URL trong [firebase_options.dart].
  final FirebaseDatabase database;
  final AuthRepository auth;
  final UserRepository users;
  final GroupRepository groups;
  final TaskRepository tasks;

  static FirebaseDependencies create() {
    final FirebaseDatabase db = firebaseRtdb();
    final FirebaseUserRepository users = FirebaseUserRepository(database: db);
    return FirebaseDependencies(
      database: db,
      auth: FirebaseAuthRepository(database: db),
      users: users,
      groups: FirebaseGroupRepository(users: users, database: db),
      tasks: FirebaseTaskRepository(database: db),
    );
  }
}
