import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                              Text(
                                'Framework and libraries used:\n- Flutter\n- Riverpod\n- GoRouter\n- Hive\n- Flutter Animate\n\nJack GPT\nThe big Aurav G\'s son\nRyan Essay\nMeghnaa\'s computer is broken\nBen the Ginger\nAsh is playing Balatro\nZaydenyahu Palantir\nTiny(\'s in hardware)\nSen(d help)\nAnd Nived (emotional support)',
                                style: Theme.of(context).textTheme.bodyLarge,
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

                  // Licenses Button
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
