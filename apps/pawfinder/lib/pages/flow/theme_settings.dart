import 'package:pawfinder/providers/brightness_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/auth_provider.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = ref.watch(brightnessNotifierProvider);
    final isDarkMode = brightness == Brightness.dark;
    final uri = GoRouterState.of(context).uri;
    final from = uri.queryParameters['from'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (from != null && from.isNotEmpty) {
              context.go(from);
              return;
            }

            if (uri.path.startsWith('/strat')) {
              context.go('/strat');
              return;
            }

            context.go('/match/auto');
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dark Mode',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isDarkMode
                                  ? 'Dark theme is currently active'
                                  : 'Light theme is currently active',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _ThemePreviewCard(
                          title: 'Light',
                          isSelected: !isDarkMode,
                          icon: Icons.light_mode,
                          onTap: () {
                            ref
                                .read(brightnessNotifierProvider.notifier)
                                .changeBrightness(false);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ThemePreviewCard(
                          title: 'Dark',
                          isSelected: isDarkMode,
                          icon: Icons.dark_mode,
                          onTap: () {
                            ref
                                .read(brightnessNotifierProvider.notifier)
                                .changeBrightness(true);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            subtitle: const Text('Sign out of your account'),
            onTap: () => _showSignOutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context, WidgetRef ref) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? DO NOT DO THIS WITHOUT INTERNET',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut ?? false) {
      await ref.read(authProvider).logout();
      if (context.mounted) {
        context.go('/welcome');
      }
    }
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.title,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(
                Icons.check_circle,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}