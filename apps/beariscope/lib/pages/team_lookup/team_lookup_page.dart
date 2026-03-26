import 'package:beariscope/models/match_field_ids.dart';
import 'package:beariscope/pages/team_lookup/team_providers.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:beariscope/providers/rankings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:services/providers/api_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:beariscope/pages/main_view.dart';
import 'package:beariscope/components/beariscope_card.dart';
import 'package:beariscope/components/team_card.dart';
import 'package:beariscope/pages/team_lookup/team_model.dart';

import '../../providers/team_scouting_provider.dart';

class TeamLookupPage extends ConsumerStatefulWidget {
  const TeamLookupPage({super.key});

  @override
  ConsumerState<TeamLookupPage> createState() => _TeamLookupPageState();
}

class _TeamLookupPageState extends ConsumerState<TeamLookupPage> {
  final TextEditingController _searchTermTEC = TextEditingController();

  @override
  void dispose() {
    _searchTermTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final main = MainViewController.of(context);
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
      client.invalidateCache(
        '/rankings',
        queryParams: {'event': selectedEvent},
      );
      ref.invalidate(teamsProvider);
      ref.invalidate(eventRankingsProvider);
      try {
        await Future.wait([
          ref.read(teamsProvider.future),
          ref.read(eventRankingsProvider.future),
        ]);
      } catch (_) {
        // Keep current cached data visible if refresh fails.
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8.0,
        title: SearchBar(
          controller: _searchTermTEC,
          onChanged: (_) => setState(() {}),
          hintText: 'Team name or number',
          elevation: WidgetStateProperty.all(0.0),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: const Icon(Symbols.search_rounded),
          trailing: [
            PopupMenuButton<TeamSortOptions>(
              icon: Icon(Symbols.sort_rounded),
              tooltip: 'Sort',
              itemBuilder: (context) => TeamSortOptions.values
                  .map(
                    (sort) => CheckedPopupMenuItem<TeamSortOptions>(
                      value: sort,
                      checked: selectedSort.sort == sort,
                      child: Row(
                        children: [
                          Text(sort.label),
                          if (selectedSort.sort == sort)
                            Icon(
                              isAscending
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                            ),
                        ],
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
                // if(ref.read(teamSortProvider.notifier).getSort() == TeamSortOptions.custom){
                //   Scaffold.of(context).showBottomSheet((BuildContext context) {
                //     return ListView(
                //             children: [
                //               SortByFieldItem(itemName: "Hi")
                //             ]
                //         );
                //   });
                // }
              },
            ),
          ],
        ),
        leading: main.isDesktop
            ? SizedBox(width: 48)
            : IconButton(
                icon: const Icon(Symbols.menu_rounded),
                onPressed: main.openDrawer,
              ),
        actions: [SizedBox(width: 48)],
      ),
      body: teamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (teams) {
          final teamList = teams
              .whereType<Map<String, dynamic>>()
              .map((json) => Team.fromJson(json))
              .toList();

          final searchTerm = _searchTermTEC.text.trim().toLowerCase();
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

          // Apply sort
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
                  // Teams without a rank go to the end
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
                // Teams without a rank go to the end
                final rankA = ref
                    .watch(teamScoutingProvider(a.number))
                    .when(
                      data: (bundle) =>
                          bundle.avgMatchField(kSectionTele, kTeleFuelScored) +
                          bundle.avgMatchField(kSectionAuto, kAutoFuelScored),
                      error: (_, _) => 0,
                      loading: () => 0,
                    );
                final rankB = ref
                    .watch(teamScoutingProvider(b.number))
                    .when(
                      data: (bundle) =>
                          bundle.avgMatchField(kSectionTele, kTeleFuelScored) +
                          bundle.avgMatchField(kSectionAuto, kAutoFuelScored),
                      error: (_, _) => 0,
                      loading: () => 0,
                    );
                if (isAscending) {
                  return rankA.compareTo(rankB);
                } else {
                  return rankB.compareTo(rankA);
                }
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
    );
  }
}

class SortByFieldItem extends StatefulWidget {
  final String itemName;
  VoidCallback? onAddNew;

  SortByFieldItem({super.key, required this.itemName, this.onAddNew});

  @override
  State<StatefulWidget> createState() {
    return SortByFieldItemState();
  }
}

class SortByFieldItemState extends State<SortByFieldItem> {
  String sectionId = '';
  String dataId = '';

  List<DropdownMenuItem<String>> generateDropdownMenuItems(List<String> list) {
    List<DropdownMenuItem<String>> finalList = [];
    list.forEach((item) {
      finalList.add(
        DropdownMenuItem(
          child: Text(item),
          onTap: () {
            sectionId = item;
          },
        ),
      );
    });
    return finalList;
  }

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      elevation: 2.0,
      child: Row(
        children: [
          // DropdownButtonFormField(
          //     items: generateDropdownMenuItems(kSectionsList),
          //     onChanged: (item){
          //
          //     }
          // ),
          // DropdownButtonFormField(
          //     items: ,
          //     onChanged: (item){
          //     }
          // ),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Weight',
              border: OutlineInputBorder(),
            ),
            onChanged: (newValue) {},
          ),
          FilledButton.icon(
            onPressed: () {
              widget.onAddNew;
            },
            label: Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
