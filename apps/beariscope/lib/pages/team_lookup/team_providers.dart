import 'package:beariscope/models/match_field_ids.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:services/providers/api_provider.dart';
import 'package:beariscope/providers/current_event_provider.dart';

class TeamSort {
  TeamSortOptions sort = TeamSortOptions.teamNumber;
  bool isAscending = true;

  TeamSort(this.sort, this.isAscending);
}

enum TeamSortOptions { teamNumber, rank, custom }

extension TeamSortLabel on TeamSortOptions {
  String get label => switch (this) {
    TeamSortOptions.teamNumber => 'Team #',
    TeamSortOptions.rank => 'Rank',
    TeamSortOptions.custom => 'Total #',
  };
}

class TeamSortNotifier extends Notifier<TeamSort> {
  @override
  TeamSort build() => TeamSort(TeamSortOptions.teamNumber, true);
  void setSort(TeamSortOptions sort, bool isAscending) =>
      state = TeamSort(sort, isAscending);

  TeamSortOptions getSort() => state.sort;

  bool getIsAscending() => state.isAscending;
}

final teamSortProvider = NotifierProvider<TeamSortNotifier, TeamSort>(
  () => TeamSortNotifier(),
);

List<Map<String, dynamic>> _toStringKeyMaps(List<dynamic> data) {
  return data
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

final teamsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final selectedEvent = ref.watch(currentEventProvider);
  final client = ref.watch(honeycombClientProvider);

  final teamData = await client.get<List<dynamic>>(
    '/teams',
    queryParams: {'event': selectedEvent},
    cachePolicy: CachePolicy.cacheFirst,
  );

  return _toStringKeyMaps(teamData);
});
