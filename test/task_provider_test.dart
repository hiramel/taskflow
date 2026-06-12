import 'package:flutter_test/flutter_test.dart';

import 'package:task_flow/features/tasks/data/repositories/mock_task_repository.dart';
import 'package:task_flow/features/tasks/domain/entities/task_entity.dart';
import 'package:task_flow/features/tasks/domain/entities/task_priority.dart';
import 'package:task_flow/features/tasks/domain/entities/task_status.dart';
import 'package:task_flow/features/tasks/domain/repositories/task_repository.dart';
import 'package:task_flow/features/tasks/presentation/providers/task_provider.dart';

void main() {
  group('TaskProvider', () {
    test(
      'loadTasks loads tasks from repository, updates the tasks list, and clears errorMessage',
      () async {
        final _FlakyTaskRepository repository = _FlakyTaskRepository();
        final TaskProvider provider = TaskProvider(taskRepository: repository);

        await provider.loadTasks();

        expect(provider.tasks, isEmpty);
        expect(provider.errorMessage, isNotNull);

        await provider.loadTasks();

        expect(provider.tasks, hasLength(5));
        expect(provider.tasks.first.title, 'Plan sprint review');
        expect(provider.errorMessage, isNull);
      },
    );

    test(
      'createTask creates a task, refreshes the task list, and returns true',
      () async {
        final MockTaskRepository repository = MockTaskRepository();
        final TaskProvider provider = TaskProvider(taskRepository: repository);

        await provider.loadTasks();

        final TaskEntity task = _task(
          id: 'new-task',
          title: 'Write unit tests',
          description: 'Add provider tests for task loading and mutations.',
        );

        final bool result = await provider.createTask(task);

        expect(result, isTrue);
        expect(provider.tasks, hasLength(6));
        expect(
          provider.tasks.any((TaskEntity item) => item.id == 'new-task'),
          isTrue,
        );
        expect(provider.errorMessage, isNull);
      },
    );

    test(
      'deleteTask deletes a task, refreshes the task list, and returns true',
      () async {
        final MockTaskRepository repository = MockTaskRepository();
        final TaskProvider provider = TaskProvider(taskRepository: repository);

        await provider.loadTasks();

        final bool result = await provider.deleteTask('1');

        expect(result, isTrue);
        expect(provider.tasks, hasLength(4));
        expect(
          provider.tasks.any((TaskEntity item) => item.id == '1'),
          isFalse,
        );
        expect(provider.errorMessage, isNull);
      },
    );
  });
}

TaskEntity _task({
  required String id,
  required String title,
  required String description,
}) {
  return TaskEntity(
    id: id,
    title: title,
    description: description,
    dueDate: DateTime(2026, 6, 20),
    category: 'Test',
    priority: TaskPriority.medium,
    status: TaskStatus.pending,
  );
}

class _FlakyTaskRepository implements TaskRepository {
  _FlakyTaskRepository() : _repository = MockTaskRepository();

  final MockTaskRepository _repository;
  bool _shouldFailFirstLoad = true;

  @override
  Future<List<TaskEntity>> getTasks() async {
    if (_shouldFailFirstLoad) {
      _shouldFailFirstLoad = false;
      throw StateError('Temporary load failure.');
    }

    return _repository.getTasks();
  }

  @override
  Future<TaskEntity> createTask(TaskEntity task) {
    return _repository.createTask(task);
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) {
    return _repository.updateTask(task);
  }

  @override
  Future<void> deleteTask(String id) {
    return _repository.deleteTask(id);
  }
}
