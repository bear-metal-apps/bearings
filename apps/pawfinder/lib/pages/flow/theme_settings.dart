import 'package:pawfinder/providers/brightness_provider.dart';
import 'package:pawfinder/services/device_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

const String _signOutPassword = 'johnscout2046';

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
            context.pop();
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
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideX(begin: -0.2, end: 0, duration: 500.ms),
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
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOut),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            subtitle: const Text('Sign out of your account'),
            onTap: () => _showPasswordDialog(context, ref),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideX(begin: -0.2, end: 0, delay: 200.ms, duration: 500.ms),
        ],
      ),
    );
  }

  Future<void> _showPasswordDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const _PasswordDialog(),
    );
    
    if (result == true && context.mounted) {
      _showSignOutDialog(context, ref);
    }
  }

  Future<void> _showSignOutDialog(BuildContext context, WidgetRef ref) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Are you sure you want to sign out? You will need to sign in again to access your data.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
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
      await ref.read(deviceAuthServiceProvider).deprovision();
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
              )
                  .animate()
                  .scale(duration: 300.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 200.ms),
            ],
          ],
        ),
      )
          .animate(target: isSelected ? 1 : 0)
          .scale(begin: Offset(1.0, 1.0), end: Offset(1.05, 1.05), duration: 200.ms),
    );
  }
}
class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _verify() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text == _signOutPassword) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = 'Incorrect password';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'IMPORTANT: Doing this will sign you out of your account. You will need to sign in again to access your data.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText:
                    'Additional verification to prevent accidental sign out. Contact anybody in the Apps subteam if you need the password.',
                errorText: _errorMessage,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _verify,
          child: const Text('Verify'),
        ),
      ],
    );
  }
}
