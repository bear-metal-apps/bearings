import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/providers/auth_provider.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            const Text(
              'Pawfinder',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IntrinsicWidth(
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        await auth.login([
                          'openid',
                          'profile',
                          'email',
                          'offline_access',
                          'ORLhqJbHiTfgdF3Q8hqIbmdwT1wTkkP7',
                        ]);
                      } on OfflineAuthException {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No internet connection')),
                          );
                        }
                      }
                    },
                    label: const Text('Sign In'),
                    icon: const Icon(Symbols.open_in_new_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
