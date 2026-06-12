import 'package:flutter/foundation.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/task_repository.dart';

/// Holds the task screen state and loads tasks from a repository.
class TaskProvider extends ChangeNotifier {
  TaskProvider({required TaskRepository taskRepository})
      : _taskRepository = taskRepository;

  final TaskRepository _taskRepository;

  List<TaskEntity> _tasks = <TaskEntity>[];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategory;
  TaskStatus? _selectedStatus;
  TaskPriority? _selectedPriority;

  /// Tasks currently available in the UI.
  List<TaskEntity> get tasks => List<TaskEntity>.unmodifiable(_tasks);

  /// Tasks after applying search and filter criteria.
  List<TaskEntity> get filteredTasks {
    return List<TaskEntity>.unmodifiable(
      _tasks.where((TaskEntity task) {
        final String query = _searchQuery.trim().toLowerCase();
        final bool matchesSearch = query.isEmpty ||
            task.title.toLowerCase().contains(query) ||
            task.description.toLowerCase().contains(query) ||
            task.category.toLowerCase().contains(query);

        final bool matchesCategory =
            _selectedCategory == null || task.category == _selectedCategory;
        final bool matchesStatus =
            _selectedStatus == null || task.status == _selectedStatus;
        final bool matchesPriority =
            _selectedPriority == null || task.priority == _selectedPriority;

        return matchesSearch && matchesCategory && matchesStatus && matchesPriority;
      }),
    );
  }

  /// Indicates whether tasks are being loaded.
  bool get isLoading => _isLoading;

  /// Indicates whether a task is being created.
  bool get isSaving => _isSaving;

  /// Error message shown when loading tasks fails.
  String? get errorMessage => _errorMessage;

  /// Current search text applied to the task list.
  String get searchQuery => _searchQuery;

  /// Selected category filter.
  String? get selectedCategory => _selectedCategory;

  /// Selected status filter.
  TaskStatus? get selectedStatus => _selectedStatus;

  /// Selected priority filter.
  TaskPriority? get selectedPriority => _selectedPriority;

  /// Loads tasks from the repository and updates the UI state.
  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskRepository.getTasks();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a task and refreshes the task list.
  Future<bool> createTask(TaskEntity task) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _taskRepository.createTask(task);
      await loadTasks();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Updates a task and refreshes the task list.
  Future<bool> updateTask(TaskEntity task) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _taskRepository.updateTask(task);
      await loadTasks();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Deletes a task and refreshes the task list.
  Future<bool> deleteTask(String id) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _taskRepository.deleteTask(id);
      await loadTasks();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Applies search and filter criteria to the task list.
  void applyFilters({
    String? searchQuery,
    String? selectedCategory,
    TaskStatus? selectedStatus,
    TaskPriority? selectedPriority,
  }) {
    _searchQuery = searchQuery ?? '';
    _selectedCategory = selectedCategory;
    _selectedStatus = selectedStatus;
    _selectedPriority = selectedPriority;
    notifyListeners();
  }

  /// Clears all search and filter criteria.
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedStatus = null;
    _selectedPriority = null;
    notifyListeners();
  }
}
