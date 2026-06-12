// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:task_flow/app/app.dart';
import 'package:task_flow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_flow/features/auth/presentation/providers/auth_provider.dart';
import 'package:task_flow/features/settings/presentation/providers/settings_provider.dart';
import 'package:task_flow/features/tasks/data/repositories/mock_task_repository.dart';
import 'package:task_flow/features/tasks/presentation/providers/task_provider.dart';

void main() {
  testWidgets('App boots on login screen', (WidgetTester tester) async {
    final authProvider = AuthProvider(authRepository: const AuthRepositoryImpl());
    final settingsProvider = SettingsProvider();
    final taskProvider = TaskProvider(taskRepository: MockTaskRepository());

    await tester.pumpWidget(
      TaskFlowApp(
        authProvider: authProvider,
        settingsProvider: settingsProvider,
        taskProvider: taskProvider,
      ),
    );

    expect(find.text('Welcome Back!'), findsOneWidget);
  });
}
