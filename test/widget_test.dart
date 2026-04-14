import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/app.dart';
import 'package:todo_list/application/app_controller.dart';
import 'package:todo_list/data/mock_dependencies.dart';

void main() {
  testWidgets('Hiển thị màn đăng nhập với header Helio', (
    WidgetTester tester,
  ) async {
    final MockDependencies deps = MockDependencies.create();
    await tester.pumpWidget(
      ChangeNotifierProvider<AppController>(
        create: (_) => AppController(
          auth: deps.auth,
          users: deps.users,
          groups: deps.groups,
          tasks: deps.tasks,
        ),
        child: const TodoApp(),
      ),
    );

    expect(find.text('Helio Todo'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
