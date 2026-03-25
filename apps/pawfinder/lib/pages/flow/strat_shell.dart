import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pawfinder/providers/scouting_flow_provider.dart';
import 'package:pawfinder/providers/scouting_providers.dart';
import 'package:pawfinder/widgets/reset_scopes.dart';

class StratShell extends ConsumerStatefulWidget {
  final Widget child;

  const StratShell({super.key, required this.child});

  @override
  ConsumerState<StratShell> createState() => _StratShellState();
}

class _StratShellState extends ConsumerState<StratShell> {
  late final ResetController _resetController;

  @override
  void initState() {
    super.initState();
    _resetController = ResetController();
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scoutingSessionProvider);
    final notifier = ref.read(scoutingSessionProvider.notifier);
    final flow = ref.read(scoutingFlowControllerProvider);
    final matchNumber = session.matchNumber ?? 0;

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
            Text(session.position?.displayName ?? 'Strategy'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Strategy Inputs',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Strategy Inputs'),
                  content: const Text(
                    'This will clear the strat page entries. Continue?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (confirmed ?? false) {
                _resetController.trigger();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.skip_previous),
            tooltip: 'Previous Match',
            onPressed: matchNumber > 1 ? () => flow.previousMatch() : null,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            tooltip: 'Next Match',
            onPressed: () => flow.nextMatch(),
          ),
        ],
      ),
      body: StratResetScope(controller: _resetController, child: widget.child),
    );
  }
}
