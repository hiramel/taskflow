import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../providers/task_provider.dart';

/// Main task list screen with search, filters, and quick task actions.
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.push('/tasks/filters'),
            icon: const Icon(Icons.search_outlined),
            tooltip: 'Search tasks',
          ),
          IconButton(
            onPressed: () => context.push('/tasks/filters'),
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Filters',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load tasks: ${provider.errorMessage}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final List<TaskEntity> tasks = provider.filteredTasks;

          return RefreshIndicator(
            onRefresh: provider.loadTasks,
            color: colorScheme.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _StatusTabs(
                  selectedStatus: provider.selectedStatus,
                  selectedColor: colorScheme.primary,
                  onChanged: (TaskStatus? status) {
                    provider.applyFilters(
                      searchQuery: provider.searchQuery,
                      selectedCategory: provider.selectedCategory,
                      selectedStatus: status,
                      selectedPriority: provider.selectedPriority,
                    );
                  },
                ),
                const SizedBox(height: 18),
                if (tasks.isEmpty)
                  const _EmptyTasksState()
                else
                  ...tasks.map(
                    (TaskEntity task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TaskCard(
                        task: task,
                        onTap: () => context.push('/tasks/edit', extra: task),
                        onToggleCompleted: () => _toggleTaskStatus(context, task),
                        onDelete: () => _confirmDelete(context, task),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleTaskStatus(BuildContext context, TaskEntity task) async {
    final TaskProvider provider = context.read<TaskProvider>();
    final TaskStatus nextStatus = task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;

    await provider.updateTask(
      TaskEntity(
        id: task.id,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        category: task.category,
        priority: task.priority,
        status: nextStatus,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TaskEntity task) async {
    final bool shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Delete Task'),
              content: Text('Delete "${task.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete || !context.mounted) {
      return;
    }

    await context.read<TaskProvider>().deleteTask(task.id);
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({
    required this.selectedStatus,
    required this.selectedColor,
    required this.onChanged,
  });

  final TaskStatus? selectedStatus;
  final Color selectedColor;
  final ValueChanged<TaskStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Set<_StatusTab> selectedTab = <_StatusTab>{_selectedTab(selectedStatus)};

    return SegmentedButton<_StatusTab>(
      segments: const [
        ButtonSegment<_StatusTab>(
          value: _StatusTab.all,
          label: Text('All'),
        ),
        ButtonSegment<_StatusTab>(
          value: _StatusTab.pending,
          label: Text('Pending'),
        ),
        ButtonSegment<_StatusTab>(
          value: _StatusTab.completed,
          label: Text('Completed'),
        ),
      ],
      selected: selectedTab,
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerLow,
        foregroundColor: colorScheme.onSurfaceVariant,
        selectedForegroundColor: colorScheme.onPrimary,
        selectedBackgroundColor: selectedColor,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      onSelectionChanged: (Set<_StatusTab> values) {
        final _StatusTab value = values.first;
        onChanged(_statusFromTab(value));
      },
    );
  }

  _StatusTab _selectedTab(TaskStatus? status) {
    switch (status) {
      case TaskStatus.pending:
        return _StatusTab.pending;
      case TaskStatus.completed:
        return _StatusTab.completed;
      case null:
        return _StatusTab.all;
    }
  }

  TaskStatus? _statusFromTab(_StatusTab tab) {
    switch (tab) {
      case _StatusTab.all:
        return null;
      case _StatusTab.pending:
        return TaskStatus.pending;
      case _StatusTab.completed:
        return TaskStatus.completed;
    }
  }
}

enum _StatusTab { all, pending, completed }

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onToggleCompleted,
    required this.onDelete,
  });

  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onToggleCompleted;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final String dueLabel = _dueLabel(context, task.dueDate);
    final bool isCompleted = task.status == TaskStatus.completed;

    return Material(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(-4, 1),
                child: Checkbox(
                  value: isCompleted,
                  onChanged: (_) => onToggleCompleted(),
                  visualDensity: VisualDensity.compact,
                  activeColor: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dueLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      task.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PriorityBadge(priority: task.priority),
                  const SizedBox(height: 8),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_horiz,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (String value) {
                      if (value == 'edit') {
                        onTap();
                        return;
                      }
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dueLabel(BuildContext context, DateTime dueDate) {
    final DateTime now = DateTime.now();
    final bool isSameDay =
        now.year == dueDate.year && now.month == dueDate.month && now.day == dueDate.day;

    if (isSameDay) {
      final TimeOfDay time = TimeOfDay.fromDateTime(dueDate);
      return 'Due today at ${time.format(context)}';
    }

    return 'Due ${MaterialLocalizations.of(context).formatMediumDate(dueDate)}';
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final (_PriorityVisual visual) = _PriorityVisual.fromPriority(
      priority,
      Theme.of(context).colorScheme,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: visual.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        visual.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: visual.foregroundColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _PriorityVisual {
  const _PriorityVisual({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  factory _PriorityVisual.fromPriority(TaskPriority priority, ColorScheme colorScheme) {
      switch (priority) {
      case TaskPriority.low:
        return _PriorityVisual(
          label: 'Low',
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        );
      case TaskPriority.medium:
        return _PriorityVisual(
          label: 'Medium',
          backgroundColor: colorScheme.tertiaryContainer,
          foregroundColor: colorScheme.onTertiaryContainer,
        );
      case TaskPriority.high:
        return _PriorityVisual(
          label: 'High',
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
        );
    }
  }
}

class _EmptyTasksState extends StatelessWidget {
  const _EmptyTasksState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 56),
      child: Column(
        children: [
          Icon(
            Icons.checklist_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No tasks match the current search or filters.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
