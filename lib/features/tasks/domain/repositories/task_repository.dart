import '../entities/task_entity.dart';

/// Contract for task data operations in the domain layer.
///
/// Implementations can come from remote APIs, local storage, or a mix of both.
abstract class TaskRepository {
  /// Returns all tasks available to the current user.
  Future<List<TaskEntity>> getTasks();

  /// Creates a new task and returns the created entity.
  Future<TaskEntity> createTask(TaskEntity task);

  /// Updates an existing task and returns the updated entity.
  Future<TaskEntity> updateTask(TaskEntity task);

  /// Deletes a task identified by its id.
  Future<void> deleteTask(String id);
}
