import 'package:beariscope_scouter/providers/scouting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScoutingShell extends ConsumerWidget {
  final Widget child;

  const ScoutingShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(scoutingSessionProvider);
    final notifier = ref.read(scoutingSessionProvider.notifier);
    final matchNumber = session.matchNumber ?? 0;
    final position = session.position;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Exit to Scout Selection',
          onPressed: () async {
            final shouldExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Scouting'),
                content: const Text(
                  'Are you sure you want to exit this match?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Exit'),
                  ),
                ],
              ),
            );
            if (shouldExit ?? false) {
              notifier.exitToScoutSelect();
              if (context.mounted) {
                context.go('/scout');
              }
            }
          },
        ),
        title: Row(
          children: [
            Text('Match $matchNumber'),
            const VerticalDivider(),
            Text(position?.displayName ?? ''),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.skip_previous),
            tooltip: 'Previous Match',
            onPressed: matchNumber > 1 ? () => notifier.previousMatch() : null,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            tooltip: 'Next Match',
            onPressed: () => notifier.nextMatch(),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex(context),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/match/auto');
              break;
            case 1:
              context.go('/match/tele');
              break;
            case 2:
              context.go('/match/end');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Auto'),
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_bar_chart_sharp),
            label: 'Tele',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_array),
            label: 'Endgame',
          ),
        ],
      ),
    );
  }

  int _currentTabIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.contains('/tele')) return 1;
    if (location.contains('/end')) return 2;
    return 0;
  }
}
