import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pawfinder/custom_widgets/upload_button.dart';
import 'package:pawfinder/services/device_auth_service.dart';

import '../../data/local_data.dart';

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
            leading: const Icon(Icons.link_off),
            title: const Text('Deprovision Device'),
            subtitle: const Text('Remove stored credentials from this device'),
            onTap: () => _showDeprovisionDialog(context, ref),
          ),

          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete Local Data'),
            subtitle: const Text(
              'clears all cached match data from this device',
            ),
            onTap: () => _showDeleteCacheDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteCacheDialog(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Local Data'),
        content: const Text(
          'this will delete all locally stored match data, schedule cache, and upload queue. your config (event/position) will be kept.\n\nyou should upload pending matches first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete ?? false) {
      await Hive.box(boxKey).clear();
    }
  }

  Future<void> _showDeprovisionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldDeprovision = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deprovision Device'),
        content: const Text(
          'This will remove all stored credentials from this device. You will need to scan a new QR code from Beariscope to use Pawfinder again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Deprovision',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDeprovision ?? false) {
      // Disable guest mode when signing out
      ref.read(guestModeProvider.notifier).disable();
      await ref.read(deviceAuthServiceProvider).deprovision();
      if (context.mounted) {
        context.go('/provision');
      }
    }
  }
}
