import 'dart:convert';

import 'package:beariscope/models/scouting_document.dart';
import 'package:beariscope/providers/current_event_provider.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:services/providers/api_provider.dart';

part 'scouting_data_provider.g.dart';

const _scoutingSyncPageSize = 5000;

Set<String> scoutingDocumentIdsForEvent(
  Iterable<ScoutingDocument> documents,
  String eventKey,
) {
  return documents
      .where((doc) => doc.meta?['event']?.toString() == eventKey)
      .map((doc) => doc.id)
      .where((id) => id.isNotEmpty)
      .toSet();
}

Set<String> staleScoutingDocumentIds({
  required Iterable<ScoutingDocument> cachedDocuments,
  required Set<String> remoteIds,
  required String eventKey,
}) {
  return scoutingDocumentIdsForEvent(
    cachedDocuments,
    eventKey,
  ).difference(remoteIds);
}

@Riverpod(keepAlive: true)
class ScoutingData extends _$ScoutingData {
  static const _boxName = 'scouting_data';

  @override
  Future<List<ScoutingDocument>> build() async {
    final eventKey = ref.watch(currentEventProvider);

    final cached = _loadFromHive(eventKey);

    _syncInBackground(eventKey);

    return cached;
  }

  List<ScoutingDocument> _loadFromHive(String eventKey) {
    final box = Hive.box<String>(_boxName);
    return box.values
        .map(_decodeDocument)
        .whereType<ScoutingDocument>()
        .where((doc) => doc.meta?['event']?.toString() == eventKey)
        .toList();
  }

  Future<void> _syncInBackground(String eventKey) async {
    try {
      await _syncEventDocuments(eventKey);
      state = AsyncData(_loadFromHive(eventKey));
    } catch (_) {
      // Already showing cached data — don't replace it with an error state.
    }
  }

  Future<void> _syncEventDocuments(String eventKey) async {
    final remoteDocs = await _fetchAllRemoteDocuments(eventKey);
    final box = Hive.box<String>(_boxName);

    final remoteIds = <String>{};
    for (final raw in remoteDocs) {
      final id = raw['_id']?.toString().trim();
      if (id == null || id.isEmpty) {
        continue;
      }
      remoteIds.add(id);
      box.put(id, jsonEncode(raw));
    }

    final staleIds = staleScoutingDocumentIds(
      cachedDocuments: box.values
          .map(_decodeDocument)
          .whereType<ScoutingDocument>()
          .where((doc) => doc.meta?['event']?.toString() == eventKey),
      remoteIds: remoteIds,
      eventKey: eventKey,
    );

    for (final id in staleIds) {
      await box.delete(id);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllRemoteDocuments(
    String eventKey,
  ) async {
    final client = ref.read(honeycombClientProvider);
    final documents = <Map<String, dynamic>>[];
    var skip = 0;

    while (true) {
      final response = await client.get<Map<String, dynamic>>(
        '/scouting?event=${Uri.encodeComponent(eventKey)}&limit=$_scoutingSyncPageSize&skip=$skip',
        cachePolicy: CachePolicy.networkFirst,
      );

      final page = _extractRemoteDocuments(response);
      if (page.isEmpty) {
        break;
      }

      documents.addAll(page);

      if (page.length < _scoutingSyncPageSize) {
        break;
      }

      skip += page.length;
    }

    return documents;
  }

  Future<void> refresh() async {
    final eventKey = ref.read(currentEventProvider);
    await _syncEventDocuments(eventKey);
    state = AsyncData(_loadFromHive(eventKey));
  }

  List<Map<String, dynamic>> _extractRemoteDocuments(
    Map<String, dynamic> response,
  ) {
    final rawList = response['data'];
    if (rawList is! List) {
      return const [];
    }

    return rawList
        .whereType<Map>()
        .map((raw) => Map<String, dynamic>.from(raw))
        .toList(growable: false);
  }

  ScoutingDocument? _decodeDocument(String raw) {
    try {
      return ScoutingDocument.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
