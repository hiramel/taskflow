import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/task_repository.dart';

/// Temporary in-memory implementation of [TaskRepository].
///
/// This repository is useful while building the UI before connecting Supabase.
class MockTaskRepository implements TaskRepository {
  MockTaskRepository() : _tasks = <TaskEntity>[
      TaskEntity(
        id: '1',
        title: 'Plan sprint review',
        description: 'Prepare the notes and agenda for the sprint review.',
        dueDate: DateTime(2026, 6, 12),
        category: 'Work',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
      ),
      TaskEntity(
        id: '2',
        title: 'Buy groceries',
        description: 'Get fruit, vegetables, and coffee for the week.',
        dueDate: DateTime(2026, 6, 10),
        category: 'Personal',
        priority: TaskPriority.medium,
        status: TaskStatus.completed,
      ),
      TaskEntity(
        id: '3',
        title: 'Read architecture notes',
        description: 'Review Clean Architecture examples and summarize ideas.',
        dueDate: DateTime(2026, 6, 15),
        category: 'Study',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
      ),
      TaskEntity(
        id: '4',
        title: 'Pay internet bill',
        description: 'Confirm the payment before the due date.',
        dueDate: DateTime(2026, 6, 11),
        category: 'Finance',
        priority: TaskPriority.high,
        status: TaskStatus.completed,
      ),
      TaskEntity(
        id: '5',
        title: 'Workout session',
        description: 'Do a light training session after work.',
        dueDate: DateTime(2026, 6, 13),
        category: 'Health',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
      ),
    ];

  final List<TaskEntity> _tasks;

  @override
  Future<List<TaskEntity>> getTasks() async {
    return List<TaskEntity>.unmodifiable(_tasks);
  }

  @override
  Future<TaskEntity> createTask(TaskEntity task) async {
    _tasks.add(task);
    return task;
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async {
    final int index = _tasks.indexWhere((TaskEntity item) => item.id == task.id);
    if (index == -1) {
      throw StateError('Task with id ${task.id} was not found.');
    }

    _tasks[index] = task;
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((TaskEntity task) => task.id == id);
  }
}
