import 'dart:convert';

import 'package:core/core.dart';
import 'package:hive_ce/hive.dart';
import 'package:pawfinder/data/local_data.dart';

class MatchFormStore {
  static String keyFor(String eventKey, int matchNumber, int pos) {
    return 'match:$eventKey:$matchNumber:$pos';
  }

  MatchFormData? load(String eventKey, int matchNumber, int pos) {
    final raw = Hive.box(boxKey).get(keyFor(eventKey, matchNumber, pos));
    if (raw is! String) return null;
    try {
      return MatchFormData.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  void save(MatchFormData data) {
    Hive.box(boxKey).put(
      keyFor(data.eventKey, data.matchNumber, data.pos),
      jsonEncode(data.toJson()),
    );
  }

  MatchFormData? loadById(String id) {
    final box = Hive.box(boxKey);
    for (final dynamic key in box.keys) {
      if (key is! String || !key.startsWith('match:')) continue;
      final raw = box.get(key);
      if (raw is! String) continue;
      try {
        final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
        final data = MatchFormData.fromJson(decoded);
        if (data.id == id) return data;
      } catch (_) {
        // ignore corrupt or non-match documents
      }
    }
    return null;
  }
}
