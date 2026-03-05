import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
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
                    'PawFinder',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 500.ms),
                  
                  const SizedBox(height: 8),
                  
                  // Version
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms),
                  
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
                            'PawFinder is a comprehensive FRC scouting application designed to help teams collect, analyze, and utilize match data efficiently. '
                            'Built with Flutter for a seamless cross-platform experience.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideX(begin: -0.2, end: 0, delay: 300.ms, duration: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Features Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Key Features',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            context,
                            Icons.analytics,
                            'Match Scouting',
                            'Collect detailed match data for all teams',
                          ),
                          _buildFeatureItem(
                            context,
                            Icons.cloud_upload,
                            'Cloud Sync',
                            'Seamlessly upload and sync scouting data',
                          ),
                          _buildFeatureItem(
                            context,
                            Icons.people,
                            'Multi-Position Support',
                            'Scout from any alliance position',
                          ),
                          _buildFeatureItem(
                            context,
                            Icons.calendar_today,
                            'Event Management',
                            'Support for multiple competitions',
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .slideX(begin: -0.2, end: 0, delay: 400.ms, duration: 500.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Credits Card
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
                            'Made with ❤️ by Bear Metal Apps',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '2046 Bear Metal Robotics',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      .slideX(begin: -0.2, end: 0, delay: 500.ms, duration: 500.ms),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
