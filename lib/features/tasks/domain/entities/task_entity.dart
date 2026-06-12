import 'task_priority.dart';
import 'task_status.dart';

/// Represents a task in the domain layer.
///
/// This is the core business entity used across the app. It is kept plain and
/// immutable so it is easy to reason about and safe to share.
class TaskEntity {
  /// Creates a task with the required business fields.
  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    required this.priority,
    required this.status,
  });

  /// Unique identifier for the task.
  final String id;

  /// Short title shown in lists and summaries.
  final String title;

  /// Longer text describing the task.
  final String description;

  /// Date when the task should be completed.
  final DateTime dueDate;

  /// Logical grouping for the task.
  final String category;

  /// Urgency level of the task.
  final TaskPriority priority;

  /// Current completion state of the task.
  final TaskStatus status;
}
