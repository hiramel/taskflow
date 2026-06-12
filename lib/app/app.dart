import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import '../features/tasks/presentation/providers/task_provider.dart';

class TaskFlowApp extends StatefulWidget {
  const TaskFlowApp({
    super.key,
    required this.authProvider,
    required this.settingsProvider,
    required this.taskProvider,
  });

  final AuthProvider authProvider;
  final SettingsProvider settingsProvider;
  final TaskProvider taskProvider;

  @override
  State<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends State<TaskFlowApp> {
  late final GoRouter _router = AppRouter.create(widget.authProvider);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProvider.value(value: widget.settingsProvider),
        ChangeNotifierProvider.value(value: widget.taskProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'TaskFlow',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.isDarkModeEnabled
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
