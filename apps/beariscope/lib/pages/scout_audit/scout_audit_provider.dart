import 'package:beariscope/models/scouting_document.dart';
import 'package:beariscope/pages/scout_audit/scout_audit_logic.dart';
import 'package:beariscope/pages/scout_audit/scout_audit_preferences_provider.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:beariscope/providers/scouting_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:services/providers/api_provider.dart';

final cachedTbaMatchesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final eventKey = ref.watch(currentEventProvider);
  final client = ref.watch(honeycombClientProvider);

  final raw = await client.get<List<dynamic>>(
    '/matches',
    queryParams: {'event': eventKey},
    cachePolicy: CachePolicy.cacheOnly,
  );

  return raw
      .whereType<Map>()
      .map((entry) => Map<String, dynamic>.from(entry))
      .toList(growable: false);
});

final scoutAuditSnapshotProvider = FutureProvider<ScoutAuditSnapshot>((
  ref,
) async {
  final eventKey = ref.watch(currentEventProvider);
  final threshold = ref.watch(scoutAuditIncorrectThresholdProvider);

  final docs = await ref.watch(scoutingDataProvider.future);
  final tbaMatches = await ref.watch(cachedTbaMatchesProvider.future);

  return buildScoutAuditSnapshot(
    docs: docs,
    tbaMatches: tbaMatches,
    eventKey: eventKey,
    incorrectThreshold: threshold,
  );
});

List<ScoutingDocument> matchDocsForMatch(
  List<ScoutingDocument> docs,
  String eventKey,
  int matchNumber,
) {
  return docs
      .where((doc) {
        final meta = doc.meta;
        return meta?['type']?.toString() == 'match' &&
            meta?['event']?.toString() == eventKey &&
            (doc.data['matchNumber'] == matchNumber ||
                int.tryParse(doc.data['matchNumber']?.toString() ?? '') ==
                    matchNumber);
      })
      .toList(growable: false);
}
