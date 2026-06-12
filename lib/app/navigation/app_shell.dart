import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isOpeningCreateTaskPage = false;

  bool get _showFloatingActionButton {
    return widget.location == '/dashboard' ||
        widget.location == '/tasks' ||
        widget.location == '/profile' ||
        widget.location == '/settings';
  }

  int get _selectedIndex {
    if (widget.location.startsWith('/tasks')) return 1;
    if (widget.location.startsWith('/profile')) return 2;
    if (widget.location.startsWith('/settings')) return 3;
    if (widget.location.startsWith('/help-support')) return 2;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/tasks');
        break;
      case 2:
        context.go('/profile');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  Future<void> _openCreateTaskPage(BuildContext context) async {
    if (_isOpeningCreateTaskPage) {
      return;
    }

    setState(() {
      _isOpeningCreateTaskPage = true;
    });

    try {
      await context.push('/tasks/create');
    } finally {}

    if (!mounted) {
      return;
    }

    setState(() {
      _isOpeningCreateTaskPage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _showFloatingActionButton
          ? Transform.translate(
              offset: const Offset(0, -10),
              child: FloatingActionButton(
                shape: const CircleBorder(),
                backgroundColor: const Color(0xFF6D5EF8),
                foregroundColor: Colors.white,
                onPressed: _isOpeningCreateTaskPage ? null : () => _openCreateTaskPage(context),
                child: const Icon(Icons.add),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
