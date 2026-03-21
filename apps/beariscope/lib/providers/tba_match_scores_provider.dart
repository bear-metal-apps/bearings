import 'package:beariscope/models/tba_match_score.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:services/providers/api_provider.dart';

final tbaMatchScoresProvider = FutureProvider<Map<int, TbaMatchScore>>((
  ref,
) async {
  final eventKey = ref.watch(currentEventProvider);
  final client = ref.watch(honeycombClientProvider);

  try {
    final data = await client.get<List<dynamic>>(
      '/matches',
      queryParams: {'event': eventKey},
      cachePolicy: CachePolicy.networkFirst,
    );

    final result = <int, TbaMatchScore>{};
    for (final entry in data) {
      if (entry is! Map) continue;
      final match = Map<String, dynamic>.from(entry);
      final compLevel =
          (match['comp_level'] ?? match['compLevel'])?.toString() ?? '';
      if (compLevel != 'qm') continue;

      final score = TbaMatchScore.fromJson(match);
      if (score.matchNumber <= 0 || !score.hasScoreBreakdown) continue;
      result[score.matchNumber] = score;
    }

    return result;
  } catch (_) {
    return {};
  }
});
