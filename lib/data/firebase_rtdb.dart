import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:todo_list/core/config/firebase/firebase_options.dart';

/// Realtime Database — instance mặc định của project
/// [todolist-92e3c / todolist-92e3c-default-rtdb](https://console.firebase.google.com/project/todolist-92e3c/database/todolist-92e3c-default-rtdb/data/~2F).
///
/// URL lấy từ [AppFirebaseOptions.currentPlatform.databaseURL].
FirebaseDatabase firebaseRtdb() {
  final FirebaseApp app = Firebase.app();
  final String? url = AppFirebaseOptions.currentPlatform.databaseURL;
  if (url != null && url.isNotEmpty) {
    return FirebaseDatabase.instanceFor(app: app, databaseURL: url);
  }
  return FirebaseDatabase.instance;
}
