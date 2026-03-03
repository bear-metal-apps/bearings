import 'dart:convert';

import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/data/match_json_gen.dart';
import 'package:beariscope_scouter/providers/match_config_provider.dart';
import 'package:beariscope_scouter/store/strat_state.dart';
import 'package:hive_ce/hive.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scout_upload_service.g.dart';

class ScoutUploadService {
  final Ref _ref;
  final HoneycombClient _client;

  ScoutUploadService(this._ref, this._client);

  // uploads the given identities and returns how many entries were actually sent.
  // throws on network failure so the caller can restore the queue.
  Future<int> upload(List<MatchIdentity> pending) async {
    if (pending.isEmpty) return 0;

    final entries = <Map<String, dynamic>>[];

    // lazy-load match config only if we have any robot entries
    final hasRobotEntries = pending.any((id) => !id.position.isStrategy);
    final matchConfig = hasRobotEntries
        ? await _ref.read(matchConfigProvider.future)
        : null;

    // split by event and do cross-check per event, so upsert stays correct
    final byEvent = <String, List<MatchIdentity>>{};
    for (final id in pending) {
      byEvent.putIfAbsent(id.event.key, () => <MatchIdentity>[]).add(id);
    }

    for (final eventEntry in byEvent.entries) {
      final eventKey = eventEntry.key;
      final eventPending = eventEntry.value;

      // event-local lookup maps for existing docs
      final matchDocIds = <String, String>{};
      final stratDocIds = <String, String>{};

      try {
        final existing = await _client.get<Map<String, dynamic>>(
          '/scouting?event=${Uri.encodeComponent(eventKey)}',
          cachePolicy: CachePolicy.networkFirst,
        );
        final docs = (existing['data'] as List?) ?? [];
        for (final raw in docs) {
          final doc = Map<String, dynamic>.from(raw as Map);
          final id = doc['_id']?.toString() ?? '';
          if (id.isEmpty) continue;
          final data = doc['data'] is Map
              ? Map<String, dynamic>.from(doc['data'] as Map)
              : <String, dynamic>{};
          final meta = data['meta'] is Map
              ? Map<String, dynamic>.from(data['meta'] as Map)
              : <String, dynamic>{};
          final type = meta['type']?.toString();
          if (type == 'match') {
            final mn = data['matchNumber'];
            final pos = data['pos'];
            if (mn != null && pos != null) {
              matchDocIds['${mn}_$pos'] = id;
            }
          } else if (type == 'strat') {
            final mn = meta['matchNumber'];
            final alliance = meta['alliance']?.toString();
            if (mn != null && alliance != null) {
              stratDocIds['${mn}_$alliance'] = id;
            }
          }
        }
      } catch (_) {
        // no cross-check = no existingId tag, backend will create new docs for this event
      }

      for (final id in eventPending) {
        if (id.position.isStrategy) {
          final entry = _buildStratEntry(id);
          if (entry == null) continue; // no strat data saved yet, skip
          final key = '${id.matchNumber}_${id.position.allianceKey}';
          final existingId = stratDocIds[key];
          if (existingId != null && existingId.isNotEmpty) {
            (entry['meta'] as Map<String, dynamic>)['existingId'] = existingId;
          }
          entries.add(entry);
        } else {
          final matchData = generateMatchJsonHive(matchConfig!, id);
          final entry = matchData.toJson();
          final key = '${id.matchNumber}_${id.position.posIndex}';
          final existingId = matchDocIds[key];
          if (existingId != null && existingId.isNotEmpty) {
            (entry['meta'] as Map<String, dynamic>)['existingId'] = existingId;
          }
          entries.add(entry);
        }
      }
    }

    if (entries.isEmpty) return 0;

    await _client.post('/scout/ingest', data: {'entries': entries});
    return entries.length;
  }

  // reads strat state from hive and builds the server-facing json
  Map<String, dynamic>? _buildStratEntry(MatchIdentity id) {
    final raw = Hive.box(boxKey).get('STRAT_${identityDataKey(id)}');
    if (raw is! String) return null;

    StratState strat;
    try {
      strat = StratState.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }

    return {
      'meta': {
        'type': 'strat',
        'season': id.event.year,
        'version': 1,
        'event': id.event.key,
        'matchNumber': id.matchNumber,
        'alliance': id.position.allianceKey,
        'scoutedBy': id.scout.name,
      },
      'driverSkillRanking': strat.driverSkill,
      'defensiveSkillRanking': strat.defensiveSkill,
      'defensiveSusceptibilityRanking': strat.defensiveSusceptibility,
      'mechanicalStabilityRanking': strat.mechanicalStability,
      'defenseActivityLevel': strat.defenseActivityLevel,
      'humanPlayerScore': strat.humanPlayerScore,
    };
  }
}

@Riverpod(keepAlive: true)
ScoutUploadService scoutUploadService(Ref ref) {
  final client = ref.watch(honeycombClientProvider);
  return ScoutUploadService(ref, client);
}
