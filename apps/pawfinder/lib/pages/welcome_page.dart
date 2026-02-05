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
                    onPressed: () {
                      auth.login([
                        'openid',
                        'profile',
                        'offline_access',
                        'User.Read',
                        'api://bearmet.al/honeycomb/access',
                      ]);
                    },
                    label: const Text('Sign In With BMBC Account'),
                    icon: const Icon(Symbols.login_rounded),
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
