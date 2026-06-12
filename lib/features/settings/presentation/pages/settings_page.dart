import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final AuthProvider authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!context.mounted) {
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Theme',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: const Text('Dark Mode'),
                    subtitle: const Text(
                      'Use a darker color palette in TaskFlow.',
                    ),
                    value: settingsProvider.isDarkModeEnabled,
                    onChanged: (value) =>
                        settingsProvider.setDarkModeEnabled(value),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Account',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        final bool isLoading = authProvider.isLoading;
                        final String accountName = _accountName(authProvider);
                        final String accountEmail = _accountEmail(authProvider);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.onPrimaryContainer,
                                child: const Icon(Icons.person),
                              ),
                              title: Text(accountName),
                              subtitle: Text(accountEmail),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () => _logout(context),
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.logout),
                                label: Text(
                                  isLoading ? 'Signing out...' : 'Logout',
                                ),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _accountName(AuthProvider authProvider) {
    final String? name = authProvider.currentUser?.name?.trim();
    if (name == null || name.isEmpty) {
      return 'TaskFlow User';
    }

    return name;
  }

  String _accountEmail(AuthProvider authProvider) {
    final String? email = authProvider.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      return 'No email available';
    }

    return email;
  }
}
