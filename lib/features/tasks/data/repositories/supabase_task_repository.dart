import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task_model.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

/// Supabase-backed implementation of [TaskRepository].
///
/// This repository maps between the `tasks` table and the domain entity.
class SupabaseTaskRepository implements TaskRepository {
  const SupabaseTaskRepository();

  @override
  Future<List<TaskEntity>> getTasks() async {
    final List<dynamic> response = await Supabase.instance.client
        .from('tasks')
        .select()
        .order('due_date', ascending: true);

    return response
        .map(
          (dynamic row) =>
              TaskModel.fromJson(Map<String, dynamic>.from(row as Map))
                  .toEntity(),
        )
        .toList();
  }

  @override
  Future<TaskEntity> createTask(TaskEntity task) async {
    final TaskModel model = TaskModel.fromEntity(task);
    final Map<String, dynamic> payload = model.toJson();
    if (payload['id'] == null || payload['id'].toString().trim().isEmpty) {
      payload.remove('id');
    }

    final dynamic response = await Supabase.instance.client
        .from('tasks')
        .insert(payload)
        .select()
        .single();

    return TaskModel.fromJson(Map<String, dynamic>.from(response as Map))
        .toEntity();
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async {
    if (task.id.trim().isEmpty) {
      throw ArgumentError('Task id is required to update a task.');
    }

    final Map<String, dynamic> payload = TaskModel.fromEntity(task).toJson();

    final dynamic response = await Supabase.instance.client
        .from('tasks')
        .update(payload)
        .eq('id', task.id)
        .select()
        .single();

    return TaskModel.fromJson(Map<String, dynamic>.from(response as Map))
        .toEntity();
  }

  @override
  Future<void> deleteTask(String id) async {
    if (id.trim().isEmpty) {
      return;
    }

    await Supabase.instance.client.from('tasks').delete().eq('id', id);
  }
}
