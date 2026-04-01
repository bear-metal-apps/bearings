import 'package:beariscope/models/match_field_ids.dart';
import 'package:beariscope/models/team_scouting_bundle.dart';
import 'package:beariscope/pages/team_lookup/tabs/averages_tab.dart';
import 'package:beariscope/pages/team_lookup/tabs/capabilities_tab.dart';
import 'package:beariscope/pages/team_lookup/tabs/matches_tab.dart';
import 'package:beariscope/pages/team_lookup/tabs/media_tab.dart';
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
    final cardHeight = height ?? 360;

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

        return Material(
          color: Theme
              .of(context)
              .colorScheme
              .surfaceContainer,
          elevation: 0,
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        TeamDetailsPage(
                          teamName: resolvedTeam.name,
                          teamNumber: resolvedTeam.number,
                        ),
                  ),
                );
              },
              child: SizedBox(
                height: cardHeight,
                width: double.infinity,
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
          _TeamCardHeader(team: team),
          const SizedBox(height: 12),
          Expanded(
            child: bundleAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (bundle) => _SummaryMetrics(
                teamNumber: team.number,
                bundle: bundle,
                stratZScores:
                    ref
                        .watch(stratZScoresProvider)
                        .asData
                        ?.value
                        .changeToRanks() ??
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

class _TeamCardHeader extends StatelessWidget {
  final Team team;

  const _TeamCardHeader({required this.team});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final mediaAsync = ref.watch(teamMediaProvider(team.number));

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: mediaAsync.when(
                loading: () => _fallbackAvatar(context),
                error: (_, _) => _fallbackAvatar(context),
                data: (media) {
                  final avatar = media
                      .where((record) => record.isAvatar)
                      .toList();
                  final preferredAvatar = avatar.firstWhere(
                        (record) =>
                    record.preferred && record.base64Image != null,
                    orElse: () =>
                        avatar.firstWhere(
                              (record) => record.base64Image != null,
                          orElse: () =>
                          const TeamMediaRecord(
                            foreignKey: '',
                            type: '',
                            preferred: false,
                            teamKeys: [],
                            directUrl: null,
                            viewUrl: null,
                            base64Image: null,
                          ),
                        ),
                  );
                  final bytes = preferredAvatar.base64Image;
                  if (bytes == null) return _fallbackAvatar(context);
                  return Image.memory(
                    bytes,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) =>
                        _fallbackAvatar(context),
                  );
                },
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
            const SizedBox(width: 8),
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
        );
      },
    );
  }

  Widget _fallbackAvatar(BuildContext context) {
    return Icon(
      Icons.account_circle,
      size: 32,
      color: Theme
          .of(context)
          .colorScheme
          .onSurfaceVariant,
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
    const playStyleOptions = ['Passing', 'Cycling', 'Shooting', 'Defense'];

    final trenchCapable =
        bundle.getPitsField<String>('trenchCapability') == 'Trench Capable';
    final climbCapable = bundle.getPitsField<String>('climbMethod');

    final mostCommonPlayStyle = RegExp(r'\d+')
        .allMatches(
          bundle.modalMatchField(kSectionEndgame, kEndPlayStyle).toString(),
        )
        .map((m) {
          final index = int.parse(m.group(0)!);
          return (index >= 0 && index < playStyleOptions.length)
              ? playStyleOptions[index]
              : null;
        })
        .whereType<String>()
        .join(', ');

    final avgAutoFuel = bundle.avgMatchField(kSectionAuto, kAutoFuelScored);
    final avgTeleFuel = bundle.avgMatchField(kSectionTele, kTeleFuelScored);
    final avgAccuracy = bundle.avgMatchAccuracyTotal();
    final hasMatch = bundle.hasMatchData;
    final hasZScores = stratZScores?.hasDataForTeam(teamNumber) ?? false;
    final hasPitsData = bundle.hasPitsData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasPitsData) ...[
          _ChipsRow(
            mostCommonPlayStyle: mostCommonPlayStyle,
            trenchCapable: trenchCapable,
            climbCapable: climbCapable,
          ),
          const SizedBox(height: 8),
        ],

        const SizedBox(height: 8),

        Expanded(
          child: SfCartesianChart(
            margin: EdgeInsets.zero,
            primaryXAxis: NumericAxis(),
            primaryYAxis: NumericAxis(),
            plotAreaBorderWidth: 0,
            series: _buildLineSeries(bundle.matchDocs),
          ),
        ),

        const Divider(height: 8, thickness: 1),

        if (hasZScores) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 2,
            children: [
              _zScoreLabel(
                context,
                'Driver',
                stratZScores!.driverSkillZ[teamNumber] ?? 0,
              ),
              _zScoreLabel(
                context,
                'Defense',
                stratZScores!.defensiveSkillZ[teamNumber] ?? 0,
              ),
              _zScoreLabel(
                context,
                'Def. Resilience',
                stratZScores!.defensiveResilienceZ[teamNumber] ?? 0,
              ),
              _zScoreLabel(
                context,
                'Stability',
                stratZScores!.mechanicalStabilityZ[teamNumber] ?? 0,
              ),
            ],
          ),
        ],

        if (hasMatch) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 12,
                children: [
                  _StatPill(
                    label: 'Auto',
                    value: avgAutoFuel.toStringAsFixed(1),
                  ),
                  _StatPill(
                    label: 'Tele',
                    value: avgTeleFuel.toStringAsFixed(1),
                  ),
                  _StatPill(
                    label: 'Total',
                    value: (avgAutoFuel + avgTeleFuel).toStringAsFixed(1),
                    highlight: true,
                  ),
                  _StatPill(
                    label: 'Accuracy',
                    value: avgAccuracy != null
                        ? '${avgAccuracy.toStringAsFixed(1)}%'
                        : '?',
                    highlight: true,
                  ),
                ],
              ),
              if (ranking != null) _RankBadge(ranking: ranking!),
            ],
          ),
        ],
      ],
    );
  }

  Widget _zScoreLabel(BuildContext context, String label, double value) {
    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodySmall,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: formattedRank(value)),
        ],
      ),
    );
  }
}

class _ChipsRow extends StatelessWidget {
  final String mostCommonPlayStyle;
  final bool trenchCapable;
  final String? climbCapable;

  const _ChipsRow({
    required this.mostCommonPlayStyle,
    required this.trenchCapable,
    required this.climbCapable,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (mostCommonPlayStyle.isNotEmpty)
          Chip(
            label: Text(
              mostCommonPlayStyle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        if (trenchCapable)
          _OutlinedChip(
            icon: Symbols.merge_type_rounded,
            label: 'Trench',
            color: secondaryColor,
          ),
        if (climbCapable != null && climbCapable != 'No Climb')
          _OutlinedChip(
            icon: Symbols.arrow_upload_ready_rounded,
            label: climbCapable!,
            color: secondaryColor,
          ),
      ],
    );
  }
}

class _OutlinedChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _OutlinedChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatPill({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
  final TeamRanking ranking;

  const _RankBadge({required this.ranking});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '#${ranking.rank}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${ranking.rankingPoints} RP',
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
    final mediaAsync = ref.watch(teamMediaProvider(teamNumber));

    return mediaAsync.when(
      loading: () =>
      const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(
        appBar: AppBar(
          title: Text('$teamName — $teamNumber'),
        ),
            body: Center(child: Text('Error: $e')),
          ),
      data: (media) {
        final hasMedia = media.any((record) {
          return record.isImgurPhoto && (record.directUrl?.isNotEmpty ?? false);
        });

        return DefaultTabController(
          key: ValueKey('$showNotes-$hasMedia'),
          length: 3 + (showNotes ? 1 : 0) + (hasMedia ? 1 : 0),
          child: Scaffold(
            appBar: AppBar(
              title: Text('$teamName — $teamNumber'),
              actions: [
                PopupMenuButton<_TeamAction>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'More options',
                  onSelected: (action) => _handleAction(context, action, ref),
                  itemBuilder: (context) =>
                  [
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
                isScrollable: true,
                tabs: [
                  const Tab(text: 'Averages'),
                  if (showNotes) const Tab(text: 'Notes'),
                  const Tab(text: 'Capabilities'),
                  const Tab(text: 'Matches'),
                  if (hasMedia) const Tab(text: 'Media'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                AveragesTab(teamNumber: teamNumber),
                if (showNotes) NotesTab(teamNumber: teamNumber),
                CapabilitiesTab(teamNumber: teamNumber),
                MatchesTab(teamNumber: teamNumber),
                if (hasMedia) MediaTab(teamNumber: teamNumber),
              ],
            ),
          ),
        );
      },
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

List<LineSeries<ProcessedScoutingDoc, num>> _buildLineSeries(
  List<ProcessedScoutingDoc> data,
) {
  return [
    LineSeries<ProcessedScoutingDoc, num>(
      dataSource: data,
      xValueMapper: (doc, index) => index,
      yValueMapper: (doc, _) =>
          TeamScoutingBundle.getMatchField(
            doc.raw,
            kSectionTele,
            kTeleFuelScored,
          ) +
          TeamScoutingBundle.getMatchField(
            doc.raw,
            kSectionAuto,
            kAutoFuelScored,
          ),
      name: 'Total',
      color: Colors.green,
    ),
    LineSeries<ProcessedScoutingDoc, num>(
      dataSource: data,
      xValueMapper: (doc, index) => index,
      yValueMapper: (doc, _) => TeamScoutingBundle.getMatchField(
        doc.raw,
        kSectionTele,
        kTeleFuelScored,
      ),
      name: 'Tele',
      color: Colors.blue,
    ),
    LineSeries<ProcessedScoutingDoc, num>(
      dataSource: data,
      xValueMapper: (doc, index) => index,
      yValueMapper: (doc, _) => TeamScoutingBundle.getMatchField(
        doc.raw,
        kSectionAuto,
        kAutoFuelScored,
      ),
      name: 'Auto',
      color: Colors.red,
    ),
  ];
}

enum _TeamAction { openTba, openStatbotics, openFrcEvents, copyNumber }
