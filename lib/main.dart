import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/app.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/core/config/firebase/firebase_options.dart';
import 'package:todo_list/data/firebase_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: AppFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    // Android đôi lúc đã có app mặc định từ native layer.
    if (e.code != 'duplicate-app') rethrow;
    Firebase.app();
  }
  final FirebaseDependencies deps = FirebaseDependencies.create();
  runApp(
    ChangeNotifierProvider<AppController>(
      create: (_) => AppController(
        auth: deps.auth,
        users: deps.users,
        groups: deps.groups,
        tasks: deps.tasks,
        database: deps.database,
      ),
      child: const TodoApp(),
    ),
  );
}
