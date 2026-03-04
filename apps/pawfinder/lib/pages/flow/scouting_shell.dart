import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/data/match_json_gen.dart';
import 'package:beariscope_scouter/data/upload_queue.dart';
import 'package:beariscope_scouter/providers/brightness_provider.dart';
import 'package:beariscope_scouter/providers/scouting_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';

class ScoutingShell extends ConsumerStatefulWidget {
  final Widget child;

  const ScoutingShell({super.key, required this.child});

  @override
  ConsumerState<ScoutingShell> createState() => _ScoutingShellState();
}

late AnimationController teleFlash;

Future<void> startFlash() async {
  await Future.delayed(Duration(seconds: 15));
  teleFlash.forward();
}

class _ScoutingShellState extends ConsumerState<ScoutingShell> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
    teleFlash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        teleFlash.reverse();
      } else if (status == AnimationStatus.dismissed) {
        teleFlash.forward();
      }
    });
    teleFlash.value = double.infinity;
    teleFlash.stop();
  }

  @override
  void dispose() {
    teleFlash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scoutingSessionProvider);
    final notifier = ref.read(scoutingSessionProvider.notifier);
    final queueNotifier = ref.read(uploadQueueProvider.notifier);
    final matchNumber = session.matchNumber ?? 0;
    final position = session.position;

    // always contains the correct team even when navigating via prev/next.
    ref.listen<AsyncValue<int?>>(teamNumberForSessionProvider, (_, next) {
      final team = next.when(
        data: (t) => t,
        loading: () => null,
        error: (_, __) => null,
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
            onPressed: matchNumber > 1
                ? () {
                    final identity = notifier.createMatchIdentity();
                    if (identity != null) {
                      queueNotifier.addIfNotPresent(identity);
                    }
                    notifier.previousMatch();
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            tooltip: 'Next Match',
            onPressed: () {
              final identity = notifier.createMatchIdentity();
              if (identity != null) {
                queueNotifier.addIfNotPresent(identity);
              }
              notifier.nextMatch();
            },
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
              teleFlash.value = double.infinity;
              teleFlash.stop();
              context.go('/match/tele');
              break;
            case 2:
              context.go('/match/end');
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Auto'),
          BottomNavigationBarItem(
            icon:
            FadeTransition(
                opacity: teleFlash, // Animate the opacity (visibility)
                child: const Icon(Icons.stacked_bar_chart_sharp)
            ),
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
  bool value;

  LightSwitch({super.key, required this.value});

  @override
  ConsumerState<LightSwitch> createState() {
    return _LightSwitchState();
  }
}

class _LightSwitchState extends ConsumerState<LightSwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: widget.value,
      onChanged: (bool value) {
        setState(() {
          widget.value = value;
          ref.read(brightnessNotifierProvider.notifier).changeBrightness(value);
        });
      },
    );
  }
}
