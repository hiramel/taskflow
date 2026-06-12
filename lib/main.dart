import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/tasks/data/repositories/supabase_task_repository.dart';
import 'features/tasks/presentation/providers/task_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  final AuthProvider authProvider = AuthProvider(
    authRepository: const AuthRepositoryImpl(),
  );
  await authProvider.getCurrentUser();

  final SettingsProvider settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  final TaskProvider taskProvider = TaskProvider(
    taskRepository: const SupabaseTaskRepository(),
  );
  await taskProvider.loadTasks();

  runApp(
    TaskFlowApp(
      authProvider: authProvider,
      settingsProvider: settingsProvider,
      taskProvider: taskProvider,
    ),
  );
}
