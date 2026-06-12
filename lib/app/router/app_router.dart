import 'package:go_router/go_router.dart';

import '../navigation/app_shell.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/help_support/presentation/pages/help_support_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/tasks/domain/entities/task_entity.dart';
import '../../features/tasks/presentation/pages/create_task_page.dart';
import '../../features/tasks/presentation/pages/edit_task_page.dart';
import '../../features/tasks/presentation/pages/search_filter_page.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool isAuthenticated = authProvider.isAuthenticated;
        final bool isLoginRoute = state.matchedLocation == '/login';

        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }

        if (isAuthenticated && isLoginRoute) {
          return '/dashboard';
        }

        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return AppShell(
              location: state.matchedLocation,
              child: child,
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: '/tasks',
              name: 'tasks',
              builder: (context, state) => const TasksPage(),
            ),
            GoRoute(
              path: '/tasks/create',
              name: 'create-task',
              builder: (context, state) => const CreateTaskPage(),
            ),
            GoRoute(
              path: '/tasks/edit',
              name: 'edit-task',
              builder: (context, state) {
                final TaskEntity? task = state.extra as TaskEntity?;
                return EditTaskPage(task: task);
              },
            ),
            GoRoute(
              path: '/tasks/filters',
              name: 'task-filters',
              builder: (context, state) => const SearchFilterPage(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
            GoRoute(
              path: '/help-support',
              name: 'help-support',
              builder: (context, state) => const HelpSupportPage(),
            ),
          ],
        ),
      ],
    );
  }
}
