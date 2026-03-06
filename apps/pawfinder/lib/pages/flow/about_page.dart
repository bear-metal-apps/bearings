import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawfinder/providers/app_provider.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPapyrusEnabled = ref.watch(papyrusFontProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // App Icon/Logo
                  Icon(
                        Icons.pets,
                        size: 100,
                        color: Theme.of(context).colorScheme.primary,
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.8, 0.8), duration: 500.ms),

                  const SizedBox(height: 24),

                  // App Name
                  Text(
                        'Pawfinder',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 100.ms,
                        duration: 500.ms,
                      ),

                  const SizedBox(height: 8),

                  // Version
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                  const SizedBox(height: 40),

                  // Description Card
                  Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About This App',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Pawfinder is a comprehensive FRC scouting application designed to help teams collect, analyze, and utilize match data efficiently.\n\n'
                                'Built with Flutter for a seamless cross-platform experience.',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideX(
                        begin: -0.2,
                        end: 0,
                        delay: 300.ms,
                        duration: 500.ms,
                      ),

                  const SizedBox(height: 16),

                  // Features Card
                  Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Credits',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  children: [
                                    const TextSpan(
                                      text: 'Developed by:\n\n',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: 'Jack GPT\n'),
                                    TextSpan(text: 'The big Aurav G\n'),
                                    TextSpan(text: 'Ryan Essay\n'),
                                    TextSpan(
                                      text: 'Meghnaa\'s broken computer\n',
                                    ),
                                    TextSpan(text: 'Ben the Ginger\n'),
                                    TextSpan(text: 'Ash Balatro\n'),
                                    TextSpan(text: 'Zaydenyahu Palantir\n'),
                                    TextSpan(text: 'Tiny and Sen\n'),
                                    TextSpan(
                                      text:
                                          'And Nived i guess (emotional support)',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .slideX(
                        begin: -0.2,
                        end: 0,
                        delay: 400.ms,
                        duration: 500.ms,
                      ),

                  const SizedBox(height: 16),

                  // Credits Card
                  Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Made with ❤️ by Bear Metal Apps',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Get back to scouting you lazy bum.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 500.ms)
                      .slideX(
                        begin: -0.2,
                        end: 0,
                        delay: 500.ms,
                        duration: 500.ms,
                      ),

                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Theme(
                                data: Theme.of(context),
                                child: const LicensePage(
                                  applicationName: 'Pawfinder',
                                  applicationVersion: '1.0.0',
                                  applicationIcon: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Icon(Icons.pets, size: 48),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.article_outlined),
                        label: const Text('View Licenses & Credits'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 600.ms,
                        duration: 500.ms,
                      ),
                  SizedBox(height: 16),
                  OutlinedButton.icon(
                        onPressed: () {
                          ref.read(papyrusFontProvider.notifier).toggle();
                        },
                        icon: Text("😭", style: const TextStyle(fontSize: 24)),
                        label: Text(
                          isPapyrusEnabled ? 'son im crine' : 'son im crine',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 550.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: 550.ms,
                        duration: 500.ms,
                      ),

                  const SizedBox(height: 16),

                  // Licenses Button
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
