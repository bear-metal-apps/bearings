import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            const Text(
                  'Pawfinder',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )
                .animate()
                .fadeIn(duration: 800.ms)
                .slideY(
                  begin: -0.3,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOutCubic,
                ),
            IntrinsicWidth(
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                        onPressed: () async {
                          context.go('/provision');
                        },
                        label: const Text('Sign In'),
                        icon: const Icon(Symbols.open_in_new_rounded),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 800.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 400.ms,
                        duration: 800.ms,
                        curve: Curves.easeOutCubic,
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
