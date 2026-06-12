import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/domain/entities/task_priority.dart';
import '../../../tasks/domain/entities/task_status.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.tasks.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (provider.errorMessage != null && provider.tasks.isEmpty) {
            return Center(
              child: Text('Unable to load dashboard: ${provider.errorMessage}'),
            );
          }

          final List<TaskEntity> tasks = provider.tasks;
          final int totalTasks = tasks.length;
          final int completedTasks = tasks
              .where((TaskEntity task) => task.status == TaskStatus.completed)
              .length;
          final int pendingTasks = tasks
              .where((TaskEntity task) => task.status == TaskStatus.pending)
              .length;

          final List<TaskEntity> upcomingTasks = tasks
              .where((TaskEntity task) => task.status == TaskStatus.pending)
              .toList()
            ..sort((TaskEntity a, TaskEntity b) => a.dueDate.compareTo(b.dueDate));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderSection(
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -24),
                        child: _OverviewCard(
                          totalTasks: totalTasks,
                          completedTasks: completedTasks,
                          pendingTasks: pendingTasks,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upcoming Tasks',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () => context.go('/tasks'),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (upcomingTasks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('No upcoming tasks yet.'),
                        )
                      else
                        ...upcomingTasks.take(3).map(
                              (TaskEntity task) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _UpcomingTaskTile(task: task),
                              ),
                            ),
                      const SizedBox(height: 96),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
            colorScheme.tertiary,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hello, User 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Good morning! Let\'s be productive today.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
  });

  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _MetricItem(
                value: totalTasks,
                label: 'Tasks',
              ),
            ),
            Expanded(
              child: _MetricItem(
                value: completedTasks,
                label: 'Completed',
                accentColor: colorScheme.primary,
              ),
            ),
            Expanded(
              child: _MetricItem(
                value: pendingTasks,
                label: 'Pending',
                accentColor: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.value,
    required this.label,
    this.accentColor,
  });

  final int value;
  final String label;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Color valueColor = accentColor ?? Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _UpcomingTaskTile extends StatelessWidget {
  const _UpcomingTaskTile({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    final String dueDate = MaterialLocalizations.of(context).formatMediumDate(task.dueDate);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due $dueDate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _PriorityBadge(priority: task.priority),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final (Color background, Color foreground, String label) = switch (priority) {
      TaskPriority.low => (
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
          'Low',
        ),
      TaskPriority.medium => (
          colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer,
          'Medium',
        ),
      TaskPriority.high => (
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
          'High',
        ),
    };

    return Chip(
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
      backgroundColor: background,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
