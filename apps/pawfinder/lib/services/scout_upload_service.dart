import 'dart:convert';

import 'package:core/core.dart';
import 'package:hive_ce/hive.dart';
import 'package:pawfinder/data/local_data.dart';
import 'package:pawfinder/data/upload_queue.dart';
import 'package:pawfinder/providers/scouting_providers.dart';
import 'package:pawfinder/store/strat_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:services/providers/api_provider.dart';

part 'scout_upload_service.g.dart';

class ScoutUploadService {
  final Ref _ref;
  final HoneycombClient _client;
  bool _draining = false;

  ScoutUploadService(this._ref, this._client);

  Future<void> drainIfOnline() async {
    if (_draining) return;
    _draining = true;
    try {
      await _drain(_ref.read(uploadQueueProvider));
    } catch (_) {
      // keep queue intact; next drain retries
    } finally {
      _draining = false;
    }
  }

  // uploads the provided queue ids and marks successful ids as uploaded.
  // throws on network failure so callers can surface errors if needed.
  Future<int> upload(List<String> pendingIds) async {
    if (pendingIds.isEmpty) return 0;
    return _drain(pendingIds);
  }

  Future<int> _drain(List<String> pendingIds) async {
    if (pendingIds.isEmpty) return 0;

    final store = _ref.read(matchFormStoreProvider);
    final entries = <Map<String, dynamic>>[];
    final uploadedIds = <String>[];

    for (final queueId in pendingIds) {
      final matchDoc = store.loadById(queueId);
      if (matchDoc != null) {
        final payload = _withTeamNumber(matchDoc);
        entries.add(payload.toJson());
        uploadedIds.add(matchDoc.id);
        continue;
      }

      final stratEntry = _buildStratEntryFromQueueId(queueId);
      if (stratEntry != null) {
        entries.add(stratEntry);
        uploadedIds.add(queueId);
      }
    }

    if (entries.isEmpty) return 0;

    await _client.post('/scout/ingest', data: {'entries': entries});
    _ref.read(uploadQueueProvider.notifier).markUploaded(uploadedIds);
    return entries.length;
  }

  MatchFormData _withTeamNumber(MatchFormData data) {
    if (data.teamNumber != null) return data;
    final teamNumber = _teamNumberFor(
      data.eventKey,
      data.matchNumber,
      data.pos,
    );
    if (teamNumber == null) return data;
    return data.copyWith(teamNumber: teamNumber);
  }

  int? _teamNumberFor(String eventKey, int matchNumber, int pos) {
    final raw = Hive.box(
      boxKey,
    ).get('MATCH_${eventKey}_${matchNumber}_${pos}_team');
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  String? _sessionScoutName() {
    final name = _ref.read(scoutingSessionProvider).scout?.name.trim();
    if (name == null || name.isEmpty) return null;
    return name;
  }

  String _stratScoutedByHiveKey({
    required String eventKey,
    required int matchNumber,
    required String alliance,
  }) =>
      '${_stratHiveKey(eventKey: eventKey, matchNumber: matchNumber, alliance: alliance)}_scoutedBy';

  String _stratHiveKey({
    required String eventKey,
    required int matchNumber,
    required String alliance,
  }) => stratStorageKey(
    eventKey: eventKey,
    matchNumber: matchNumber,
    alliance: alliance,
  );

  Map<String, dynamic>? _parseStratQueueMeta(String queueId) {
    if (!queueId.startsWith(stratQueuePrefix)) return null;
    final raw = queueId.substring(stratQueuePrefix.length);
    final parts = raw.split(':');
    if (parts.length == 3) {
      final eventKey = parts[0].trim();
      final matchNumber = int.tryParse(parts[1]);
      final alliance = parts[2].trim();
      if (eventKey.isEmpty || matchNumber == null || alliance.isEmpty) {
        return null;
      }

      return {
        'eventKey': eventKey,
        'alliance': alliance,
        'matchNumber': matchNumber,
      };
    }

    // legacy queue ids were base64-encoded json payloads
    try {
      final decoded = Map<String, dynamic>.from(
        jsonDecode(utf8.decode(base64Url.decode(raw))) as Map,
      );
      final eventKey = decoded['eventKey']?.toString();
      final alliance = decoded['alliance']?.toString();
      final matchNumber = (decoded['matchNumber'] as num?)?.toInt();
      if (eventKey == null || alliance == null || matchNumber == null) {
        return null;
      }

      return {
        'eventKey': eventKey,
        'alliance': alliance,
        'matchNumber': matchNumber,
      };
    } catch (_) {
      return null;
    }
  }

  // reads strat state from hive and builds the server-facing json
  Map<String, dynamic>? _buildStratEntryFromQueueId(String queueId) {
    final meta = _parseStratQueueMeta(queueId);
    if (meta == null) return null;

    final eventKey = meta['eventKey']?.toString();
    final alliance = meta['alliance']?.toString();
    final matchNumber = (meta['matchNumber'] as num?)?.toInt();
    if (eventKey == null || alliance == null || matchNumber == null) {
      return null;
    }

    final event = _ref.read(scoutingSessionProvider).event;
    final yearPrefix = eventKey.length >= 4
        ? eventKey.substring(0, 4)
        : eventKey;
    final season =
        (event?.key == eventKey ? event?.year : null) ??
        int.tryParse(yearPrefix) ??
        DateTime.now().year;

    final hiveKey = _stratHiveKey(
      eventKey: eventKey,
      matchNumber: matchNumber,
      alliance: alliance,
    );

    final raw = Hive.box(boxKey).get(hiveKey);
    if (raw is! String) return null;

    StratState strat;
    try {
      strat = StratState.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }

    String? scoutedBy;
    final stored = Hive.box(boxKey)
        .get(
          _stratScoutedByHiveKey(
            eventKey: eventKey,
            matchNumber: matchNumber,
            alliance: alliance,
          ),
        )
        ?.toString()
        .trim();
    if (stored != null && stored.isNotEmpty) {
      scoutedBy = stored;
    } else {
      scoutedBy = _sessionScoutName();
    }

    final payloadMeta = {
      'type': 'strat',
      'season': season,
      'version': 1,
      'event': eventKey,
      'matchNumber': matchNumber,
      'alliance': alliance,
    };
    if (scoutedBy != null) {
      payloadMeta['scoutedBy'] = scoutedBy;
    }

    return {
      'meta': payloadMeta,
      'driverSkillRanking': strat.driverSkill,
      'defensiveSkillRanking': strat.defensiveSkill,
      'defensiveResilienceRanking': strat.defensiveResilience,
      'mechanicalStabilityRanking': strat.mechanicalStability,
      'defenseActivityLevel': strat.defenseActivityLevel,
      'autoHumanPlayerScore': strat.autoHumanPlayerScore,
      'teleHumanPlayerScore': strat.teleHumanPlayerScore,
    };
  }
}

@Riverpod(keepAlive: true)
ScoutUploadService scoutUploadService(Ref ref) {
  final client = ref.watch(honeycombClientProvider);
  return ScoutUploadService(ref, client);
}
