import 'package:beariscope_scouter/custom_widgets/upload_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:libkoala/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Settings'),
          actions: [
            UploadButton()
          ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            subtitle: const Text('Sign out of your account'),
            onTap: () => _showSignOutDialog(context, ref),
          ),
          ListTile(
            title: Text("Delete Cache"),
            // onLongPress: () => Hive.deleteFromDisk(),TODO get a Dialogue for this
          )
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
