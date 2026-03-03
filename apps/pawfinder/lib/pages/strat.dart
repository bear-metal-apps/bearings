import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawfinder/store/strat_state.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../providers/scouting_flow_provider.dart';
import '../providers/scouting_providers.dart';

class StratPage extends ConsumerStatefulWidget {
  const StratPage({super.key});

  @override
  ConsumerState<StratPage> createState() => _StratPageState();
}

class _StratPageState extends ConsumerState<StratPage> {
  int? _initializedForMatch;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scoutingSessionProvider);
    final identity = ref
        .read(scoutingSessionProvider.notifier)
        .createMatchIdentity();

    // shouldn't ever never be null here since the route requires a configured session
    if (identity == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final strat = ref.watch(stratStateProvider(identity));
    final notifier = ref.read(stratStateProvider(identity).notifier);
    final allianceTeamsAsync = ref.watch(allianceTeamsForSessionProvider);
    final size = MediaQuery.sizeOf(context);

    ref.listen<AsyncValue<List<String>>>(
        allianceTeamsForSessionProvider, (_, next) {
      final teams = next.maybeWhen(
          data: (value) => value, orElse: () => const <String>[]);
      final matchNumber = session.matchNumber;
      if (teams.isEmpty || matchNumber == null) return;

      if (_initializedForMatch == matchNumber && strat.driverSkill.isNotEmpty)
        return;
      _initializedForMatch = matchNumber;
      notifier.initFromSchedule(teams);
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: size.width),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: allianceTeamsAsync.when(
                data: (teams) =>
                    Text(
                      teams.isNotEmpty
                          ? 'Match ${session.matchNumber ??
                          "?"} · Alliance: ${teams.join(", ")}'
                          : 'Match ${session.matchNumber ?? "?"}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium,
                      textAlign: TextAlign.center,
                    ),
                loading: () =>
                    Text(
                      'Match ${session.matchNumber ?? "?"}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium,
                    ),
                error: (e, s) =>
                    Text(
                      'Match ${session.matchNumber ?? "?"}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium,
                    ),
              ),
            ),

            _RankingList(
              title: 'Driver Skill',
              teams: strat.driverSkill,
              onReorder: notifier.reorderDriverSkill,
            ),
            _RankingList(
              title: 'Defensive Susceptibility',
              teams: strat.defensiveSusceptibility,
              onReorder: notifier.reorderDefensiveSusceptibility,
            ),
            _RankingList(
              title: 'Defensive Skill',
              teams: strat.defensiveSkill,
              onReorder: notifier.reorderDefensiveSkill,
            ),

            SfSlider(
              min: 0.0,
              max: 10,
              value: strat.defenseActivityLevel,
              onChanged: (value) => notifier.setDefenseActivityLevel(value),
              interval: 1.0,
              showTicks: true,
              showLabels: true,
            ),

            _RankingList(
              title: 'Mechanical Stability',
              teams: strat.mechanicalStability,
              onReorder: notifier.reorderMechanicalStability,
            ),

            ElevatedButton(
              onPressed: notifier.incrementHumanPlayer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Human Player: ${strat.humanPlayerScore}',
                    textAlign: TextAlign.center,
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleSmall,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 56,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.remove, color: Colors.black),
                        onPressed: notifier.decrementHumanPlayer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                ref.read(scoutingFlowControllerProvider).nextMatch();
              },
              child: const Text('Next Match'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingList extends StatelessWidget {
  final String title;
  final List<String> teams;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _RankingList({
    required this.title,
    required this.teams,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, textScaler: TextScaler.linear(2)),
        SizedBox(
          width: 400,
          height: 160,
          child: ReorderableListView(
            onReorder: onReorder,
            children: [
              for (final item in teams)
                ListTile(
                  key: ValueKey(item),
                  title: Text(item),
                  trailing: const Icon(Icons.drag_handle),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
