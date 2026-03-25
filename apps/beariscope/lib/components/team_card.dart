import 'package:animations/animations.dart';
import 'package:beariscope/models/match_field_ids.dart';
import 'package:beariscope/models/scouting_document.dart';
import 'package:beariscope/models/team_scouting_bundle.dart';
import 'package:beariscope/pages/settings/appearance_settings_page.dart';
import 'package:beariscope/pages/team_lookup/tabs/averages_tab.dart';
import 'package:beariscope/pages/team_lookup/tabs/capabilities_tab.dart';
import 'package:beariscope/pages/team_lookup/tabs/matches_tab.dart';
import 'package:beariscope/pages/team_lookup/tabs/notes_tab.dart';
import 'package:beariscope/pages/team_lookup/team_model.dart';
import 'package:beariscope/pages/team_lookup/team_providers.dart';
import 'package:beariscope/providers/rankings_provider.dart';
import 'package:beariscope/providers/tba_preferences_provider.dart';
import 'package:beariscope/providers/team_scouting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod/src/framework.dart';
import 'package:services/providers/permissions_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/processed_scouting_doc.dart';
import '../providers/strat_z_score_provider.dart';

class TeamCard extends ConsumerWidget {
  final String teamKey;
  final double? height;
  final Color? allianceColor;

  const TeamCard({
    super.key,
    required this.teamKey,
    this.height,
    this.allianceColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamsProvider);
    final cardHeight = height ?? 320;

    return teamsAsync.when(
      loading: () => SizedBox(
        height: cardHeight,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SizedBox(
        height: cardHeight,
        child: Center(child: Text('Error: $err')),
      ),
      data: (teams) {
        final teamList = teams
            .whereType<Map<String, dynamic>>()
            .map((json) => Team.fromJson(json))
            .toList();

        Team? team;
        for (final t in teamList) {
          if (t.key == teamKey || t.number.toString() == teamKey) {
            team = t;
            break;
          }
        }

        if (team == null) {
          return SizedBox(
            height: cardHeight,
            child: const Center(child: Text('Team not found')),
          );
        }

        final resolvedTeam = team;

        return OpenContainer(
          useRootNavigator: true,
          transitionType: ContainerTransitionType.fade,
          closedElevation: 0,
          openColor: Theme.of(context).scaffoldBackgroundColor,
          middleColor: Theme.of(context).scaffoldBackgroundColor,
          closedColor: Theme.of(context).colorScheme.surfaceContainer,
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          closedBuilder: (context, action) => SizedBox(
            height: cardHeight,
            width: double.infinity,
            child: InkWell(
              onTap: action,
              borderRadius: BorderRadius.circular(12),
              child: DecoratedBox(
                decoration: allianceColor != null
                    ? BoxDecoration(
                        border: Border(
                          left: BorderSide(color: allianceColor!, width: 4),
                        ),
                      )
                    : const BoxDecoration(),
                child: _TeamCardSummary(team: resolvedTeam),
              ),
            ),
          ),
          openBuilder: (context, action) => TeamDetailsPage(
            teamName: resolvedTeam.name,
            teamNumber: resolvedTeam.number,
          ),
        );
      },
    );
  }
}

class _TeamCardSummary extends ConsumerWidget {
  final Team team;

  const _TeamCardSummary({required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bundleAsync = ref.watch(teamScoutingProvider(team.number));
    final rankingsAsync = ref.watch(eventRankingsProvider);
    final rankings = switch (rankingsAsync) {
      AsyncData(:final value) => value,
      _ => const <int, TeamRanking>{},
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Image.network(
                  'https://www.thebluealliance.com/avatar/${DateTime.now().year}/frc${team.number}.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.account_circle,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  team.name,
                  style: const TextStyle(fontSize: 20, fontFamily: 'Xolonium'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                team.number.toString(),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Replaced the Spacer with fixed padding
          Expanded(
            // Let the metrics take up the rest of the vertical space
            child: bundleAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (bundle) => _SummaryMetrics(
                teamNumber: team.number,
                bundle: bundle,
                stratZScores:
                    ref.watch(stratZScoresProvider).asData?.value ??
                    StratZScoreData.empty,
                ranking: rankings[team.number],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetrics extends ConsumerWidget {
  final int teamNumber;
  final TeamScoutingBundle bundle;
  final StratZScoreData? stratZScores;
  final TeamRanking? ranking;

  const _SummaryMetrics({
    required this.teamNumber,
    required this.bundle,
    required this.stratZScores,
    required this.ranking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingStyles = bundle.getPitsListField('playingStyle');
    final primaryRole = playingStyles.isNotEmpty ? playingStyles.first : null;
    final trenchCapable =
        bundle.getPitsField<String>('trenchCapability') == 'Trench Capable';
    final climbCapable = bundle.getPitsField<String>('climbLevel');

    final avgAutoFuel = bundle.avgMatchField(kSectionAuto, kAutoFuelScored);
    final avgTeleFuel = bundle.avgMatchField(kSectionTele, kTeleFuelScored);
    final avgAccuracy = bundle.avgMatchAccuracyTotal();
    final hasMatch = bundle.hasMatchData;
    final hasZScores = stratZScores?.hasDataForTeam(teamNumber) ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3. Z-SCORES: Pushed to the bottom by the spacer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 150,
              width: 250,
              child: SfCartesianChart(
                primaryXAxis: NumericAxis(),
                primaryYAxis: NumericAxis(
                ),
                series: _buildLineSeries(bundle.matchDocs),
                plotAreaBorderWidth: 0,
              ),
            ),
            if (hasZScores)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Driver: ${StratZScoreData.zLabel(stratZScores!.driverSkillZ[teamNumber])}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Defensive: ${StratZScoreData.zLabel(stratZScores!.defensiveSkillZ[teamNumber])}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Resilience: ${StratZScoreData.zLabel(stratZScores!.defensiveResilienceZ[teamNumber])}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Stability: ${StratZScoreData.zLabel(stratZScores!.mechanicalStabilityZ[teamNumber])}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),

        // Role chip + trench status
        // 1. CHIPS: Pinned to the top right below the header
        if (bundle.hasPitsData) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (primaryRole != null)
                Chip(
                  label: Text(
                    primaryRole,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              if (trenchCapable)
                Builder(
                  builder: (context) {
                    final color = Theme.of(context).colorScheme.secondary;
                    return Chip(
                      avatar: Icon(
                        Symbols.merge_type_rounded,
                        size: 14,
                        color: color,
                      ),
                      label: Text(
                        'Trench',
                        style: TextStyle(fontSize: 12, color: color),
                      ),
                      backgroundColor: color.withValues(alpha: 0.12),
                      side: BorderSide(color: color.withValues(alpha: 0.4)),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  },
                ),
              if (climbCapable != null)
                Builder(
                  builder: (context) {
                    final color = Theme.of(context).colorScheme.secondary;
                    return Chip(
                      avatar: Icon(
                        Symbols.stairs_rounded,
                        size: 14,
                        color: color,
                      ),
                      label: Text(
                        'Climb $climbCapable',
                        style: TextStyle(fontSize: 12, color: color),
                      ),
                      backgroundColor: color.withValues(alpha: 0.12),
                      side: BorderSide(color: color.withValues(alpha: 0.4)),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  },
                ),
            ],
          ),
        ],

        // 2. SPACER: Pushes the Z-Scores and Averages to the bottom of the card
        const Spacer(),

        const SizedBox(height: 12),

        // 4. AVERAGES: Remaining stuck to the very bottom
        if (hasMatch)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _statPill(
                    context,
                    label: 'Auto',
                    value: avgAutoFuel.toStringAsFixed(1),
                  ),
                  const SizedBox(width: 12),
                  _statPill(
                    context,
                    label: 'Tele',
                    value: avgTeleFuel.toStringAsFixed(1),
                  ),
                  const SizedBox(width: 12),
                  _statPill(
                    context,
                    label: 'Total',
                    value: (avgAutoFuel + avgTeleFuel).toStringAsFixed(1),
                    highlight: true,
                  ),
                  const SizedBox(width: 12),
                  _statPill(
                    context,
                    label: 'Accuracy',
                    value: avgAccuracy != null
                        ? '${avgAccuracy.toStringAsFixed(1)}%'
                        : '—',
                    highlight: true,
                  ),
                ],
              ),
              if (ranking != null)
                _RankBadge(
                  rank: ranking!.rank,
                  rankingPoints: ranking!.rankingPoints,
                ),
            ],
          ),
      ],
    );
  }

  Widget _statPill(
    BuildContext context, {
    required String label,
    required String value,
    bool highlight = false,
  }) {
    final color = highlight
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final int rankingPoints;

  const _RankBadge({required this.rank, required this.rankingPoints});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '#$rank',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$rankingPoints RP',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class TeamDetailsPage extends ConsumerWidget {
  final String teamName;
  final int teamNumber;

  const TeamDetailsPage({
    super.key,
    required this.teamName,
    required this.teamNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showNotes =
        ref
            .watch(permissionCheckerProvider)
            ?.hasPermission(PermissionKey.notesRead) ??
        false;

    return DefaultTabController(
      key: ValueKey(showNotes),
      length: showNotes ? 4 : 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('$teamName - $teamNumber'),
          leading: IconButton(
            icon: const Icon(Symbols.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            PopupMenuButton<_TeamAction>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'More options',
              onSelected: (action) => _handleAction(context, action, ref),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _TeamAction.openTba,
                  child: ListTile(
                    leading: const Icon(Symbols.open_in_new_rounded),
                    title: const Text('Open in TBA'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: _TeamAction.openStatbotics,
                  child: ListTile(
                    leading: const Icon(Symbols.open_in_new_rounded),
                    title: const Text('Open in Statbotics'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: _TeamAction.openFrcEvents,
                  child: ListTile(
                    leading: const Icon(Symbols.open_in_new_rounded),
                    title: const Text('Open in FRC Events'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: _TeamAction.copyNumber,
                  child: ListTile(
                    leading: const Icon(Symbols.content_copy_rounded),
                    title: const Text('Copy team number'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Averages'),
              if (showNotes) const Tab(text: 'Notes'),
              const Tab(text: 'Capabilities'),
              const Tab(text: 'Matches'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AveragesTab(teamNumber: teamNumber),
            if (showNotes) NotesTab(teamNumber: teamNumber),
            CapabilitiesTab(teamNumber: teamNumber),
            MatchesTab(teamNumber: teamNumber),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, _TeamAction action, WidgetRef ref) {
    switch (action) {
      case _TeamAction.openTba:
        launchUrl(
          ref.tbaWebsiteUri('/team/$teamNumber'),
          mode: LaunchMode.externalApplication,
        );
      case _TeamAction.openStatbotics:
        launchUrl(
          Uri.parse('https://www.statbotics.io/team/$teamNumber'),
          mode: LaunchMode.externalApplication,
        );
      case _TeamAction.openFrcEvents:
        launchUrl(
          Uri.parse('https://frc-events.firstinspires.org/team/$teamNumber'),
          mode: LaunchMode.externalApplication,
        );
      case _TeamAction.copyNumber:
        Clipboard.setData(ClipboardData(text: teamNumber.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Team number $teamNumber copied'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }
}

List<LineSeries<ProcessedScoutingDoc, num>> _buildLineSeries(List<ProcessedScoutingDoc> data) {
  return <LineSeries<ProcessedScoutingDoc, num>>[
    LineSeries<ProcessedScoutingDoc, num>(
      dataSource: data,
      xValueMapper: (ProcessedScoutingDoc match, int index) => index,
      yValueMapper: (ProcessedScoutingDoc match, int index) => TeamScoutingBundle.getMatchField(match.raw, kSectionTele, kTeleFuelScored) + TeamScoutingBundle.getMatchField(match.raw, kSectionAuto, kAutoFuelScored),
      name: 'Total',
      // markerSettings: const MarkerSettings(isVisible: true),
      color: Colors.green,
    ),
    LineSeries<ProcessedScoutingDoc, num>(
      dataSource: data,
      xValueMapper: (ProcessedScoutingDoc match, int index) => index,
      yValueMapper: (ProcessedScoutingDoc match, int index) => TeamScoutingBundle.getMatchField(match.raw, kSectionTele, kTeleFuelScored),
      name: 'Tele',
      // markerSettings: const MarkerSettings(isVisible: true),
      color: Colors.blue,
    ),
    LineSeries<ProcessedScoutingDoc, num>(
      dataSource: data,
      xValueMapper: (ProcessedScoutingDoc match, int index) => index,
      yValueMapper: (ProcessedScoutingDoc match, int index) => TeamScoutingBundle.getMatchField(match.raw, kSectionAuto, kAutoFuelScored),
      name: 'Auto',
      // markerSettings: const MarkerSettings(isVisible: true),
      color: Colors.red,
    )
  ];
}

enum _TeamAction { openTba, openStatbotics, openFrcEvents, copyNumber }
