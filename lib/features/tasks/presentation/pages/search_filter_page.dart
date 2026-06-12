import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../providers/task_provider.dart';

/// Screen used to search and filter tasks in one place.
class SearchFilterPage extends StatefulWidget {
  const SearchFilterPage({super.key});

  @override
  State<SearchFilterPage> createState() => _SearchFilterPageState();
}

class _SearchFilterPageState extends State<SearchFilterPage> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;
  TaskStatus? _selectedStatus;
  TaskPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    final TaskProvider provider = context.read<TaskProvider>();
    _searchController.text = provider.searchQuery;
    _selectedCategory = provider.selectedCategory;
    _selectedStatus = provider.selectedStatus;
    _selectedPriority = provider.selectedPriority;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<TaskProvider>().applyFilters(
          searchQuery: _searchController.text,
          selectedCategory: _selectedCategory,
          selectedStatus: _selectedStatus,
          selectedPriority: _selectedPriority,
        );
    context.pop();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedStatus = null;
      _selectedPriority = null;
    });
    context.read<TaskProvider>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search and Filters'),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _FilterChips<TaskStatus>(
            values: const {
              null: 'All',
              TaskStatus.pending: 'Pending',
              TaskStatus.completed: 'Completed',
            },
            selectedValue: _selectedStatus,
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _FilterChips<String>(
            values: const {
              null: 'All',
              'Work': 'Work',
              'Personal': 'Personal',
              'Health': 'Health',
              'Study': 'Study',
              'Finance': 'Finance',
            },
            selectedValue: _selectedCategory,
            onSelected: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Priority',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _FilterChips<TaskPriority>(
            values: const {
              null: 'All',
              TaskPriority.low: 'Low',
              TaskPriority.medium: 'Medium',
              TaskPriority.high: 'High',
            },
            selectedValue: _selectedPriority,
            onSelected: (value) {
              setState(() {
                _selectedPriority = value;
              });
            },
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _applyFilters,
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}

class _FilterChips<T> extends StatelessWidget {
  const _FilterChips({
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  final Map<T?, String> values;
  final T? selectedValue;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.entries.map((entry) {
        final bool isSelected = selectedValue == entry.key;
        return ChoiceChip(
          label: Text(entry.value),
          selected: isSelected,
          onSelected: (_) => onSelected(entry.key),
        );
      }).toList(),
    );
  }
}
