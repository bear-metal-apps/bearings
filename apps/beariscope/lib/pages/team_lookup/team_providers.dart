import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:services/providers/api_provider.dart';
import 'package:beariscope/providers/current_event_provider.dart';

enum TeamSort {
  teamNumber,
  rank,
  custom
}

extension TeamSortLabel on TeamSort {
  String get label => switch (this) {
    TeamSort.teamNumber => 'Team #',
    TeamSort.rank => 'Rank',
    TeamSort.custom => 'Rank By'
  };
}

class TeamSortNotifier extends Notifier<TeamSort> {
  @override
  TeamSort build() => TeamSort.teamNumber;

  void setSort(TeamSort sort) => state = sort;
  TeamSort getSort() => state;
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
