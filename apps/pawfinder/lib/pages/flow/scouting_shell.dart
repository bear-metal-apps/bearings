import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:pawfinder/data/local_data.dart';
import 'package:pawfinder/data/match_json_gen.dart';
import 'package:pawfinder/providers/brightness_provider.dart';
import 'package:pawfinder/providers/scouting_flow_provider.dart';
import 'package:pawfinder/providers/scouting_providers.dart';

class ScoutingShell extends ConsumerStatefulWidget {
  final Widget child;

  const ScoutingShell({super.key, required this.child});

  @override
  ConsumerState<ScoutingShell> createState() => _ScoutingShellState();
}

class _ScoutingShellState extends ConsumerState<ScoutingShell> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scoutingSessionProvider);
    final notifier = ref.read(scoutingSessionProvider.notifier);
    final flow = ref.read(scoutingFlowControllerProvider);
    final matchNumber = session.matchNumber ?? 0;
    final position = session.position;
    final location = GoRouterState.of(context).uri.toString();
    final isOnSettings = location.startsWith('/match/settings');

    // always contains the correct team even when navigating via prev/next.
    ref.listen<AsyncValue<int?>>(teamNumberForSessionProvider, (_, next) {
      final team = next.when(
        data: (t) => t,
        loading: () => null,
        error: (_, _) => null,
      );
      if (team == null) return;
      final identity = notifier.createMatchIdentity();
      if (identity == null) return;
      Hive.box(boxKey).put(matchTeamKey(identity), team);
    });

    final teamAsync = ref.watch(teamNumberForSessionProvider);
    final teamLabel = teamAsync.maybeWhen(
      data: (t) => t != null ? ' · $t' : 'null',
      orElse: () => '',
    );

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
            if (teamLabel.isNotEmpty) Text(teamLabel),
          ],
        ),
        actions: [
          LightSwitch(value: true),
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
      body: widget.child,
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
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Auto'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.stacked_bar_chart_sharp),
            label: 'Tele',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.view_array),
            label: 'Post-Match',
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

class LightSwitch extends ConsumerStatefulWidget {
  final bool value;

  const LightSwitch({super.key, required this.value});

  @override
  ConsumerState<LightSwitch> createState() {
    return _LightSwitchState();
  }
}

class _LightSwitchState extends ConsumerState<LightSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (bool value) {
        setState(() {
          _value = value;
          ref.read(brightnessNotifierProvider.notifier).changeBrightness(value);
        });
      },
    );
  }
}
