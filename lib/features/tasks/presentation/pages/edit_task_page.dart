import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../providers/task_provider.dart';

/// Simple form used to edit an existing task.
class EditTaskPage extends StatefulWidget {
  const EditTaskPage({super.key, required this.task});

  final TaskEntity? task;

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  late TaskPriority _priority;
  late TaskStatus _status;
  DateTime? _selectedDueDate;
  bool _isInitialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _initializeForm(TaskEntity task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _categoryController.text = task.category;
    _selectedDueDate = task.dueDate;
    _dueDateController.text = MaterialLocalizations.of(context).formatMediumDate(task.dueDate);
    _priority = task.priority;
    _status = task.status;
    _isInitialized = true;
  }

  Future<void> _pickDueDate() async {
    final DateTime initialDate = _selectedDueDate ?? DateTime.now();
    final DateTime firstDate = DateTime.now();
    final DateTime lastDate = DateTime.now().add(const Duration(days: 3650));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDueDate = pickedDate;
      _dueDateController.text = MaterialLocalizations.of(context).formatMediumDate(pickedDate);
    });
  }

  Future<void> _submitForm() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final DateTime? dueDate = _selectedDueDate;
    if (dueDate == null || widget.task == null) {
      setState(() {});
      return;
    }

    final TaskEntity updatedTask = TaskEntity(
      id: widget.task!.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: dueDate,
      category: _categoryController.text.trim(),
      priority: _priority,
      status: _status,
    );

    final bool success = await context.read<TaskProvider>().updateTask(updatedTask);
    if (!mounted) {
      return;
    }

    if (success) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TaskEntity? task = widget.task;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Task')),
        body: const Center(
          child: Text('Task not found.'),
        ),
      );
    }

    if (!_isInitialized) {
      _initializeForm(task);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          return AbsorbPointer(
            absorbing: provider.isSaving,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Description is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Category is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dueDateController,
                          readOnly: true,
                          onTap: _pickDueDate,
                          decoration: InputDecoration(
                            labelText: 'Due Date',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: _pickDueDate,
                              icon: const Icon(Icons.calendar_month_outlined),
                            ),
                          ),
                          validator: (value) {
                            if (_selectedDueDate == null || value == null || value.trim().isEmpty) {
                              return 'Due Date is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<TaskPriority>(
                          initialValue: _priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: TaskPriority.low,
                              child: Text('Low'),
                            ),
                            DropdownMenuItem(
                              value: TaskPriority.medium,
                              child: Text('Medium'),
                            ),
                            DropdownMenuItem(
                              value: TaskPriority.high,
                              child: Text('High'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _priority = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<TaskStatus>(
                          initialValue: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: TaskStatus.pending,
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: TaskStatus.completed,
                              child: Text('Completed'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _status = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: provider.isSaving ? null : _submitForm,
                          child: const Text('Save Changes'),
                        ),
                        if (provider.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (provider.isSaving)
                  Container(
                    color: Colors.black.withValues(alpha: 0.08),
                    child: const Center(
                      child: CircularProgressIndicator(),
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
