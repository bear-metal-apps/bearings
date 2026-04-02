import 'package:beariscope/components/beariscope_card.dart';
import 'package:beariscope/components/team_card.dart';
import 'package:beariscope/models/match_field_ids.dart';
import 'package:beariscope/pages/team_lookup/team_model.dart';
import 'package:beariscope/pages/team_lookup/team_providers.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:beariscope/providers/rankings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:services/providers/api_provider.dart';

import '../../providers/team_scouting_provider.dart';

class TeamLookupPage extends ConsumerStatefulWidget {
  const TeamLookupPage({super.key});

  @override
  ConsumerState<TeamLookupPage> createState() => _TeamLookupPageState();
}

class _TeamLookupPageState extends ConsumerState<TeamLookupPage> {
  @override
  Widget build(BuildContext context) {
    final searchFocusNode = ref.watch(searchFocusNodeProvider);
    final searchTermTEC = ref.watch(searchControllerProvider);
    final selectedEvent = ref.watch(currentEventProvider);
    final teamsAsync = ref.watch(teamsProvider);
    final selectedSort = ref.watch(teamSortProvider);
    final rankingsAsync = ref.watch(eventRankingsProvider);

    final rankings = switch (rankingsAsync) {
      AsyncData(:final value) => value,
      _ => const <int, TeamRanking>{},
    };

    bool isAscending = ref.read(teamSortProvider.notifier).getIsAscending();

    Future<void> onRefresh() async {
      final client = ref.read(honeycombClientProvider);
      client.invalidateCache('/teams', queryParams: {'event': selectedEvent});
      client.invalidateCache('/rankings', queryParams: {'event': selectedEvent});
      ref.invalidate(teamsProvider);
      ref.invalidate(eventRankingsProvider);
      try {
        await Future.wait([
          ref.read(teamsProvider.future),
          ref.read(eventRankingsProvider.future),
        ]);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8.0,
        title: SearchBar(
          focusNode: searchFocusNode,
          controller: searchTermTEC,
          onChanged: (_) => setState(() {}),
          hintText: 'Team name or number',
          elevation: WidgetStateProperty.all(0.0),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: const Icon(Symbols.search_rounded),
          trailing: [
            PopupMenuButton<TeamSortOptions>(
              icon: const Icon(Symbols.sort_rounded),
              tooltip: 'Sort',
              itemBuilder: (context) => TeamSortOptions.values
                  .map(
                    (option) => PopupMenuItem(
                  value: option,
                  child: ListTile(
                    title: Text(option.label),
                    leading: selectedSort.sort == option
                        ? Icon(
                      isAscending
                          ? Symbols.arrow_upward_rounded
                          : Symbols.arrow_downward_rounded,
                    )
                        : const SizedBox(width: 24),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              )
                  .toList(),
              onSelected: (TeamSortOptions newSort) {
                if (ref.read(teamSortProvider.notifier).getSort() == newSort) {
                  isAscending = !isAscending;
                }
                ref
                    .read(teamSortProvider.notifier)
                    .setSort(newSort, isAscending);
                setState(() {});
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          searchFocusNode.unfocus();
        },
        child: teamsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (teams) {
            final teamList = teams
                .whereType<Map<String, dynamic>>()
                .map((json) => Team.fromJson(json))
                .toList();

            final searchTerm = searchTermTEC.text.trim().toLowerCase();
            var filteredTeams = searchTerm.isEmpty
                ? teamList
                : teamList.where((team) {
              final teamName = team.name.toLowerCase();
              final teamNumber = team.number.toString();
              final teamKey = team.key.toLowerCase();
              return teamName.contains(searchTerm) ||
                  teamNumber.contains(searchTerm) ||
                  teamKey.contains(searchTerm);
            }).toList();

            filteredTeams = List.of(filteredTeams);
            switch (selectedSort.sort) {
              case TeamSortOptions.teamNumber:
                if (isAscending) {
                  filteredTeams.sort((a, b) => a.number.compareTo(b.number));
                } else {
                  filteredTeams.sort((a, b) => b.number.compareTo(a.number));
                }
              case TeamSortOptions.rank:
                if (isAscending) {
                  filteredTeams.sort((a, b) {
                    final rankA = rankings[a.number]?.rank ?? 999999;
                    final rankB = rankings[b.number]?.rank ?? 999999;
                    return rankA.compareTo(rankB);
                  });
                } else {
                  filteredTeams.sort((a, b) {
                    final rankA = rankings[a.number]?.rank ?? 0;
                    final rankB = rankings[b.number]?.rank ?? 0;
                    return rankB.compareTo(rankA);
                  });
                }
              case TeamSortOptions.custom:
                filteredTeams.sort((a, b) {
                  final rankA = ref.watch(teamScoutingProvider(a.number)).when(
                    data: (bundle) =>
                    bundle.avgMatchField(kSectionTele, kTeleFuelScored) +
                        bundle.avgMatchField(kSectionAuto, kAutoFuelScored),
                    error: (_, __) => 0,
                    loading: () => 0,
                  );
                  final rankB = ref.watch(teamScoutingProvider(b.number)).when(
                    data: (bundle) =>
                    bundle.avgMatchField(kSectionTele, kTeleFuelScored) +
                        bundle.avgMatchField(kSectionAuto, kAutoFuelScored),
                    error: (_, __) => 0,
                    loading: () => 0,
                  );
                  return isAscending
                      ? rankA.compareTo(rankB)
                      : rankB.compareTo(rankA);
                });
            }

            if (filteredTeams.isEmpty) {
              return const Center(child: Text('No teams found'));
            }

            return RefreshIndicator(
              onRefresh: onRefresh,
              child: BeariscopeCardList(
                children: filteredTeams
                    .map((team) => TeamCard(teamKey: team.key))
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
