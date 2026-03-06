import 'package:beariscope_scouter/custom_widgets/upload_button.dart';
import 'package:beariscope_scouter/data/upload_queue.dart';
import 'package:beariscope_scouter/providers/guest_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(guestModeProvider);
    final uploadQueue = ref.watch(uploadQueueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), actions: [UploadButton()]),
      body: ListView(
        children: [
          // Guest mode indicator
          if (isGuest)
            Card(
              margin: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_off,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Offline Mode',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'re working offline. Data is being saved locally. You can upload it when internet is available by clicking the upload button.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (uploadQueue.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${uploadQueue.length} match${uploadQueue.length != 1 ? 'es' : ''} queued for upload',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          
          // Exit offline mode option
          if (isGuest)
            ListTile(
              leading: const Icon(Icons.cloud_sync),
              title: const Text('Exit Offline Mode'),
              subtitle: const Text('Return to scout selection and reconnect'),
              onTap: () {
                ref.read(guestModeProvider.notifier).disable();
                context.go('/scout');
              },
            ),
          
          // Sign out option
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            subtitle: const Text('Sign out of your account'),
            onTap: () => _showSignOutDialog(context, ref),
          ),
          
          ListTile(
            title: const Text("Delete Cache"),
            // onLongPress: () => Hive.deleteFromDisk(),TODO get a Dialogue for this
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
      // Disable guest mode when signing out
      ref.read(guestModeProvider.notifier).disable();
      await ref.read(authProvider).logout();
      if (context.mounted) {
        context.go('/welcome');
      }
    }
  }
}
