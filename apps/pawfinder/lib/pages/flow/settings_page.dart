import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:pawfinder/custom_widgets/upload_button.dart';
import 'package:pawfinder/services/device_auth_service.dart';

import '../../data/local_data.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), actions: [UploadButton()]),
      body: ListView(
        children: [
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
      await ref.read(deviceAuthServiceProvider).deprovision();
      if (context.mounted) {
        context.go('/provision');
      }
    }
  }
}
