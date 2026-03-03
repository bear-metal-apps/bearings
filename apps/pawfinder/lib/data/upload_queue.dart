import 'dart:convert';

import 'package:beariscope_scouter/data/local_data.dart';
import 'package:beariscope_scouter/data/match_json_gen.dart';
import 'package:beariscope_scouter/models/scouting_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/adapters.dart';

Map<String, dynamic> _identityToJson(MatchIdentity id) => {
  'event': id.event.toJson(),
  'matchNumber': id.matchNumber,
  'position': id.position.name,
  'scoutName': id.scout.name,
  'scoutUuid': id.scout.uuid,
};

MatchIdentity? _identityFromJson(dynamic raw) {
  try {
    final m = Map<String, dynamic>.from(raw as Map);
    return (
      event: ScoutingEvent.fromJson(Map<String, dynamic>.from(m['event'])),
      matchNumber: m['matchNumber'] as int,
      position: ScoutPosition.values.firstWhere((p) => p.name == m['position']),
      scout: Scout(
        name: m['scoutName'] as String,
        uuid: m['scoutUuid'] as String,
      ),
    );
  } catch (_) {
    return null;
  }
}

class UploadQueueNotifier extends Notifier<List<MatchIdentity>> {
  static const _hiveKey = 'upload_queue';

  @override
  List<MatchIdentity> build() {
    final box = Hive.box(boxKey);
    final raw = box.get(_hiveKey);
    if (raw is! String) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map(_identityFromJson).whereType<MatchIdentity>().toList();
    } catch (_) {
      return [];
    }
  }

  /// Add a single match identity to the upload queue.
  void add(MatchIdentity identity) {
    state = [...state, identity];
    _persist();
  }

  void addIfNotPresent(MatchIdentity identity) {
    final key = identityDataKey(identity);
    if (state.any((e) => identityDataKey(e) == key)) return;
    add(identity);
  }

  void removeUploaded(List<MatchIdentity> uploaded) {
    final keys = uploaded.map(identityDataKey).toSet();
    state = state.where((e) => !keys.contains(identityDataKey(e))).toList();
    _persist();
  }

  void restoreAll(List<MatchIdentity> identities) {
    // Prepend so that the failed entries show up at the front.
    state = [...identities, ...state];
    _persist();
  }

  void _persist() {
    Hive.box(
      boxKey,
    ).put(_hiveKey, jsonEncode(state.map(_identityToJson).toList()));
  }
}

final uploadQueueProvider =
    NotifierProvider<UploadQueueNotifier, List<MatchIdentity>>(
      UploadQueueNotifier.new,
    );
