import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beariscope/pages/team_lookup/team_model.dart';
import 'package:beariscope/pages/team_lookup/team_providers.dart';
import 'package:beariscope/pages/match_lookup/match_providers.dart';
import 'package:beariscope/pages/match_lookup/match_card.dart';


class MatchLookupPage extends ConsumerStatefulWidget {
  const MatchLookupPage({super.key});

  @override
  ConsumerState<MatchLookupPage> createState() => _MatchLookupPageState();
}

class _MatchLookupPageState extends ConsumerState<MatchLookupPage> {
  final TextEditingController _team1TEC = TextEditingController();
  final TextEditingController _team2TEC = TextEditingController();

  Alliances _selectedAlliance = Alliances.all;
  bool _currentEventOnly = true;

  @override
  void dispose() {
    _team1TEC.dispose();
    _team2TEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamsAsync = _currentEventOnly ? ref.watch(teamsProvider) : ref.watch(allTeamsProvider);
    final filteredMatches = ref.watch(filteredMatchesProvider);

    final teams = teamsAsync.maybeWhen(
      data: (data) =>
          data
              .whereType<Map<String, dynamic>>()
              .map((json) => Team.fromJson(json))
              .toList(),
      orElse: () => <Team>[],
    );

    return Scaffold(
      appBar: AppBar(
          title: const Text('Match Lookup')
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 12),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    Expanded(child: _buildTeamDropdown("Team 1", _team1TEC, teams)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTeamDropdown("Team 2", _team2TEC, teams)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: SizedBox(
                width: 600,
                child: SegmentedButton<Alliances>(
                  segments: const [
                    ButtonSegment(
                      value: Alliances.same,
                      label: Text("Same"),
                    ),
                    ButtonSegment(
                      value: Alliances.opposite,
                      label: Text("Opposite"),
                    ),
                    ButtonSegment(
                      value: Alliances.all,
                      label: Text("All"),
                    ),
                  ],
                  selected: {_selectedAlliance},
                  onSelectionChanged: (newSelection) {
                    setState(() => _selectedAlliance = newSelection.first);
                    ref.read(allianceFilterProvider.notifier).state = newSelection.first;
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 20),

            Expanded(
              child: filteredMatches.when(
                data: (matches) {
                  // check if user has actually typed anything yet
                  final t1 = ref.watch(team1SearchProvider);
                  final t2 = ref.watch(team2SearchProvider);
                  final seenKeys = <String>{};
                  final uniqueMatches = matches.where((m) => seenKeys.add(m['key'] ?? '')).toList();

                  if ((t1?.isEmpty ?? true) || (t2?.isEmpty ?? true)) {
                    return const Center(child: Text("Search for two teams to see matches"));
                  }

                  return matches.isEmpty
                      ? const Center(child: Text("No matches found for these criteria."))
                      : ListView.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, index) => MatchCard(
                      match: uniqueMatches[index],
                      highlightTeams: [t1!, t2!],

                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text("Error: $err")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamDropdown(String hint,
      TextEditingController controller,
      List<Team> teams,) {
    return Autocomplete<Team>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Team>.empty();
        }

        return teams.where((team) {
          final input = textEditingValue.text.toLowerCase();
          return team.name.toLowerCase().contains(input) ||
              team.number.toString().contains(input);
        });
      },

      displayStringForOption: (team) =>
      "${team.number} ${team.name}",

      onSelected: (team) {
        controller.text = "${team.number}";
        // update the provider so the filter recalculates
        if (controller == _team1TEC) {
          ref.read(team1SearchProvider.notifier).state = team.number.toString();
        } else {
          ref.read(team2SearchProvider.notifier).state = team.number.toString();
        }
      },

      fieldViewBuilder: (context, textController, focusNode, onEditingComplete,) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          onChanged: (value) {
            if (value.isEmpty) {
              if (controller == _team1TEC) {
                ref.read(team1SearchProvider.notifier).state = '';
              } else {
                ref.read(team2SearchProvider.notifier).state = '';
              }
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        );
      },
    );
  }
}