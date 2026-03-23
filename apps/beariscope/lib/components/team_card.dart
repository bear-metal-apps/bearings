import 'package:animations/animations.dart';
import 'package:beariscope/models/match_field_ids.dart';
import 'package:beariscope/models/team_scouting_bundle.dart';
import 'package:beariscope/pages/team_lookup/tabs/averages_tab.dart';
import 'package:beariscope/pages/team_lookup/tabs/capabilities_tab.dart';
import 'package:beariscope/pages/team_lookup/tabs/matches_tab.dart';
import 'package:beariscope/pages/team_lookup/tabs/notes_tab.dart';
import 'package:beariscope/pages/team_lookup/team_model.dart';
import 'package:beariscope/pages/team_lookup/team_providers.dart';
import 'package:beariscope/providers/rankings_provider.dart';
import 'package:beariscope/providers/tba_preferences_provider.dart';
import 'package:beariscope/providers/team_scouting_provider.dart';
import 'package:beariscope/utils/create_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:services/providers/permissions_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final cardHeight = height ?? 256;

    return ref.watch(teamsProvider).when(
      loading: () =>
          SizedBox(height: cardHeight,
              child: const Center(child: CircularProgressIndicator())),
      error: (err, _) =>
          SizedBox(
              height: cardHeight, child: Center(child: Text('Error: $err'))),
      data: (teams) {
        final team = teams
            .whereType<Map<String, dynamic>>()
            .map(Team.fromJson)
            .where((t) => t.key == teamKey || t.number.toString() == teamKey)
            .firstOrNull;

        if (team == null) {
          return SizedBox(height: cardHeight,
              child: const Center(child: Text('Team not found')));
        }

        final teamColor = _getMostVibrantColor(
          team.colors?.primary,
          team.colors?.secondary,
          Theme
              .of(context)
              .colorScheme
              .primary,
        );
        final themedData = createTheme(Theme
            .of(context)
            .brightness, teamColor);
        
        return OpenContainer(
          useRootNavigator: true,
          transitionType: ContainerTransitionType.fade,
          closedElevation: 0,
          openColor: themedData.scaffoldBackgroundColor,
          middleColor: themedData.scaffoldBackgroundColor,
          closedColor: themedData.colorScheme.surfaceContainer,
          closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          closedBuilder: (context, action) =>
              Theme(
                data: themedData,
                child: SizedBox(
                  height: cardHeight,
                  width: double.infinity,
                  child: InkWell(
                    onTap: action,
                    borderRadius: BorderRadius.circular(12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: teamColor, width: 6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _TeamCardSummary(
                            team: team, primaryColor: teamColor),
                      ),
                    ),
                  ),
                ),
              ),
          openBuilder: (context, _) =>
              Theme(
                data: themedData,
                child: TeamDetailsPage(
                    teamName: team.name, teamNumber: team.number),
          ),
        );
      },
    );
  }
}

class _TeamCardSummary extends ConsumerWidget {
  final Team team;
  final Color primaryColor;

  const _TeamCardSummary({required this.team, required this.primaryColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankings = ref
        .watch(eventRankingsProvider)
        .asData
        ?.value ?? const <int, TeamRanking>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(12)),
              ),
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  'https://www.thebluealliance.com/avatar/${DateTime.now().year}/frc${team.number}.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(
                    Icons.account_circle,
                        size: 40,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 14, right: 20, top: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        team.name,
                        style: const TextStyle(
                            fontSize: 20, fontFamily: 'Xolonium'),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      team.number.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: ref.watch(teamScoutingProvider(team.number)).whenData((
                bundle) =>
                _SummaryMetrics(
                  teamNumber: team.number,
                  bundle: bundle,
                  stratZScores: ref
                      .watch(stratZScoresProvider)
                      .asData
                      ?.value ?? StratZScoreData.empty,
                  ranking: rankings[team.number],
                ),
            ).value ?? const SizedBox.shrink(),
          ),
        ),
      ],
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
    final trenchCapable = bundle.getPitsField<String>('trenchCapability') ==
        'Trench Capable';
    final climbCapable = bundle.getPitsField<String>('climbLevel');
    final avgAutoFuel = bundle.avgMatchField(kSectionAuto, kAutoFuelScored);
    final avgTeleFuel = bundle.avgMatchField(kSectionTele, kTeleFuelScored);
    final avgAccuracy = bundle.avgMatchAccuracyTotal();
    final hasZScores = stratZScores?.hasDataForTeam(teamNumber) ?? false;
    final color = Theme
        .of(context)
        .colorScheme
        .secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bundle.hasPitsData)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (playingStyles.isNotEmpty)
                Chip(
                  label: Text(
                    playingStyles.first,
                    style: TextStyle(fontSize: 12, color: Theme
                        .of(context)
                        .colorScheme
                        .onPrimaryContainer),
                  ),
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .primaryContainer,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              if (trenchCapable)
                _outlineChip(context, icon: Symbols.merge_type_rounded,
                    label: 'Trench',
                    color: color),
              if (climbCapable != null)
                _outlineChip(context, icon: Symbols.stairs_rounded,
                    label: 'Climb $climbCapable',
                    color: color),
            ],
          ),

        const Spacer(),

        if (hasZScores)
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _zLabel(context, 'Driver Skill',
                    stratZScores!.driverSkillZ[teamNumber]),
                const SizedBox(height: 2),
                _zLabel(context, 'Defensive Skill',
                    stratZScores!.defensiveSkillZ[teamNumber]),
                const SizedBox(height: 2),
                _zLabel(context, 'Defensive Resilience',
                    stratZScores!.defensiveResilienceZ[teamNumber]),
                const SizedBox(height: 2),
                _zLabel(context, 'Mechanical Stability',
                    stratZScores!.mechanicalStabilityZ[teamNumber]),
              ],
            ),
          ),

        const SizedBox(height: 12),

        if (bundle.hasMatchData)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _statPill(context, label: 'Auto',
                      value: avgAutoFuel.toStringAsFixed(1)),
                  const SizedBox(width: 12),
                  _statPill(context, label: 'Tele',
                      value: avgTeleFuel.toStringAsFixed(1)),
                  const SizedBox(width: 12),
                  _statPill(context, label: 'Total',
                      value: (avgAutoFuel + avgTeleFuel).toStringAsFixed(1),
                      highlight: true),
                  const SizedBox(width: 12),
                  _statPill(
                    context,
                    label: 'Accuracy',
                    value: avgAccuracy != null ? '${avgAccuracy.toStringAsFixed(
                        1)}%' : '?',
                    highlight: true,
                  ),
                ],
              ),
              if (ranking != null)
                _RankBadge(
                    rank: ranking!.rank, rankingPoints: ranking!.rankingPoints),
            ],
          ),
      ],
    );
  }

  Widget _outlineChip(BuildContext context,
      {required IconData icon, required String label, required Color color}) =>
      Chip(
        avatar: Icon(icon, size: 14, color: color),
        label: Text(label, style: TextStyle(fontSize: 12, color: color)),
        backgroundColor: color.withValues(alpha: 0.12),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      );

  Widget _zLabel(BuildContext context, String label, double? z) =>
      Text(
        '$label: ${StratZScoreData.zLabel(z)}',
        style: Theme
            .of(context)
            .textTheme
            .bodySmall,
      );

  Widget _statPill(BuildContext context,
      {required String label, required String value, bool highlight = false}) {
    final color = highlight
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme
            .of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color)),
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
        Text('#$rank', style: Theme
            .of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: scheme.primary, fontWeight: FontWeight.bold)),
        Text('$rankingPoints RP', style: Theme
            .of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

class TeamDetailsPage extends ConsumerWidget {
  final String teamName;
  final int teamNumber;

  const TeamDetailsPage(
      {super.key, required this.teamName, required this.teamNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showNotes = ref.watch(permissionCheckerProvider)?.hasPermission(
        PermissionKey.notesRead) ?? false;

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
                _menuItem(_TeamAction.openTba, 'Open in TBA'),
                _menuItem(_TeamAction.openStatbotics, 'Open in Statbotics'),
                _menuItem(_TeamAction.openFrcEvents, 'Open in FRC Events'),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: _TeamAction.copyNumber,
                  child: const ListTile(
                    leading: Icon(Symbols.content_copy_rounded),
                    title: Text('Copy team number'),
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

  PopupMenuItem<_TeamAction> _menuItem(_TeamAction action, String title) =>
      PopupMenuItem(
        value: action,
        child: ListTile(
          leading: const Icon(Symbols.open_in_new_rounded),
          title: Text(title),
          contentPadding: EdgeInsets.zero,
        ),
      );

  void _handleAction(BuildContext context, _TeamAction action, WidgetRef ref) {
    switch (action) {
      case _TeamAction.openTba:
        launchUrl(ref.tbaWebsiteUri('/team/$teamNumber'),
            mode: LaunchMode.externalApplication);
      case _TeamAction.openStatbotics:
        launchUrl(Uri.parse('https://www.statbotics.io/team/$teamNumber'),
            mode: LaunchMode.externalApplication);
      case _TeamAction.openFrcEvents:
        launchUrl(
            Uri.parse('https://frc-events.firstinspires.org/team/$teamNumber'),
            mode: LaunchMode.externalApplication);
      case _TeamAction.copyNumber:
        Clipboard.setData(ClipboardData(text: teamNumber.toString()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Team number $teamNumber copied'),
              duration: const Duration(seconds: 2)),
        );
    }
  }
}

Color _getMostVibrantColor(Color? primary, Color? secondary, Color fallback) {
  if (primary == null && secondary == null) return fallback;
  final c1 = primary ?? secondary!;
  final c2 = secondary ?? primary!;
  final vibrant = HSLColor
      .fromColor(c1)
      .saturation >= HSLColor
      .fromColor(c2)
      .saturation ? c1 : c2;
  return HSLColor
      .fromColor(vibrant)
      .saturation < 0.15 ? fallback : vibrant;
}

enum _TeamAction { openTba, openStatbotics, openFrcEvents, copyNumber }