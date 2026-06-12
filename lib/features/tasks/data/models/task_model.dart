import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';

/// Data-layer representation of a task.
///
/// This model converts between JSON and the domain [TaskEntity].
class TaskModel {
  /// Creates a task model with the same fields used by the domain entity.
  const TaskModel({
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

  /// Short title shown in the UI.
  final String title;

  /// Longer text describing the task.
  final String description;

  /// Due date stored as a [DateTime].
  final DateTime dueDate;

  /// Logical grouping for the task.
  final String category;

  /// Urgency level of the task.
  final TaskPriority priority;

  /// Current completion state of the task.
  final TaskStatus status;

  /// Creates a [TaskModel] from a domain [TaskEntity].
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      category: entity.category,
      priority: entity.priority,
      status: entity.status,
    );
  }

  /// Converts this model into a domain [TaskEntity].
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      category: category,
      priority: priority,
      status: status,
    );
  }

  /// Creates a [TaskModel] from a JSON-like map.
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      category: json['category'] as String,
      priority: _priorityFromString(json['priority'] as String),
      status: _statusFromString(json['status'] as String),
    );
  }

  /// Converts this model to a JSON-like map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'category': category,
      'priority': priority.name,
      'status': status.name,
    };
  }

  static TaskPriority _priorityFromString(String value) {
    switch (value) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      default:
        throw FormatException('Unknown task priority: $value');
    }
  }

  static TaskStatus _statusFromString(String value) {
    switch (value) {
      case 'pending':
        return TaskStatus.pending;
      case 'completed':
        return TaskStatus.completed;
      default:
        throw FormatException('Unknown task status: $value');
    }
  }
}
