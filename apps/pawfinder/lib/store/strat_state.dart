import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:pawfinder/data/local_data.dart';
import 'package:pawfinder/data/match_json_gen.dart';
import 'package:pawfinder/data/upload_queue.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'strat_state.g.dart';

String stratStorageKey({
  required String eventKey,
  required int matchNumber,
  required String alliance,
}) => 'STRAT_${eventKey}_${matchNumber}_$alliance';

String stratStorageKeyForIdentity(MatchIdentity identity) => stratStorageKey(
  eventKey: identity.event.key,
  matchNumber: identity.matchNumber,
  alliance: identity.position.allianceKey,
);

String _stratScoutedByKey(MatchIdentity identity) =>
    '${stratStorageKeyForIdentity(identity)}_scoutedBy';

// legacy scout-dependent key used before task 11 refactor
String _legacyStratStorageKey(MatchIdentity identity) =>
    'STRAT_${identityDataKey(identity)}';

String stratQueueIdForIdentity(MatchIdentity identity) =>
    '$stratQueuePrefix${identity.event.key}:${identity.matchNumber}:${identity.position.allianceKey}';

class StratState {
  final List<String> driverSkill;
  final List<String> defensiveSkill;
  final List<String> defensiveResilience;
  final List<String> mechanicalStability;
  final double defenseActivityLevel;
  final int autoHumanPlayerScore;
  final int teleHumanPlayerScore;

  const StratState({
    required this.driverSkill,
    required this.defensiveSkill,
    required this.defensiveResilience,
    required this.mechanicalStability,
    required this.defenseActivityLevel,
    required this.autoHumanPlayerScore,
    required this.teleHumanPlayerScore,
  });

  // empty state for a match that hasn't been filled in yet
  const StratState.empty()
    : driverSkill = const [],
      defensiveSkill = const [],
      defensiveResilience = const [],
      mechanicalStability = const [],
      defenseActivityLevel = 0.0,
      autoHumanPlayerScore = 0,
      teleHumanPlayerScore = 0;

  StratState copyWith({
    List<String>? driverSkill,
    List<String>? defensiveSkill,
    List<String>? defensiveResilience,
    List<String>? mechanicalStability,
    double? defenseActivityLevel,
    int? autoHumanPlayerScore,
    int? teleHumanPlayerScore,
  }) => StratState(
    driverSkill: driverSkill ?? this.driverSkill,
    defensiveSkill: defensiveSkill ?? this.defensiveSkill,
    defensiveResilience: defensiveResilience ?? this.defensiveResilience,
    mechanicalStability: mechanicalStability ?? this.mechanicalStability,
    defenseActivityLevel: defenseActivityLevel ?? this.defenseActivityLevel,
    autoHumanPlayerScore: autoHumanPlayerScore ?? this.autoHumanPlayerScore,
    teleHumanPlayerScore: teleHumanPlayerScore ?? this.teleHumanPlayerScore,
  );

  Map<String, dynamic> toJson() => {
    'driverSkill': driverSkill,
    'defensiveSkill': defensiveSkill,
    'defensiveResilience': defensiveResilience,
    'mechanicalStability': mechanicalStability,
    'defenseActivityLevel': defenseActivityLevel,
    'autoHumanPlayerScore': autoHumanPlayerScore,
    'teleHumanPlayerScore': teleHumanPlayerScore,
  };

  factory StratState.fromJson(Map<String, dynamic> json) => StratState(
    driverSkill: List<String>.from(json['driverSkill'] ?? []),
    defensiveSkill: List<String>.from(json['defensiveSkill'] ?? []),
    defensiveResilience: List<String>.from(json['defensiveResilience'] ?? []),
    mechanicalStability: List<String>.from(json['mechanicalStability'] ?? []),
    defenseActivityLevel:
        (json['defenseActivityLevel'] as num?)?.toDouble() ?? 0.0,
    autoHumanPlayerScore: (json['autoHumanPlayerScore'] as num?)?.toInt() ?? 0,
    teleHumanPlayerScore: (json['teleHumanPlayerScore'] as num?)?.toInt() ?? 0,
  );
}

// one notifier per match identity — reads/writes to hive on every change
// using keepAlive so the data doesn't get reset while the scout is still on the strat page
@Riverpod(keepAlive: true)
class StratStateNotifier extends _$StratStateNotifier {
  @override
  StratState build(MatchIdentity identity) {
    final box = Hive.box(boxKey);
    final stratKey = stratStorageKeyForIdentity(identity);
    var raw = box.get(stratKey);

    if (raw is! String) {
      final legacyRaw = box.get(_legacyStratStorageKey(identity));
      if (legacyRaw is String) {
        raw = legacyRaw;
        box.put(stratKey, legacyRaw);
      }
    }

    if (raw is String) {
      try {
        return StratState.fromJson(jsonDecode(raw));
      } catch (_) {}
    }
    return const StratState.empty();
  }

  void _save() {
    final box = Hive.box(boxKey);
    box.put(stratStorageKeyForIdentity(identity), jsonEncode(state.toJson()));
    final scoutedBy = identity.scout.name.trim();
    if (scoutedBy.isNotEmpty) {
      box.put(_stratScoutedByKey(identity), scoutedBy);
    }
  }

  // populate lists from the schedule if they're still empty (new match)
  void initFromSchedule(List<String> teams) {
    if (teams.isEmpty || state.driverSkill.isNotEmpty) return;
    state = state.copyWith(
      driverSkill: List.from(teams),
      defensiveSkill: List.from(teams),
      defensiveResilience: List.from(teams),
      mechanicalStability: List.from(teams),
    );
    _save();
  }

  void reorderDriverSkill(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final list = List<String>.from(state.driverSkill);
    list.insert(newIndex, list.removeAt(oldIndex));
    state = state.copyWith(driverSkill: list);
    _save();
  }

  void reorderDefensiveSkill(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final list = List<String>.from(state.defensiveSkill);
    list.insert(newIndex, list.removeAt(oldIndex));
    state = state.copyWith(defensiveSkill: list);
    _save();
  }

  void reorderDefensiveResilience(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final list = List<String>.from(state.defensiveResilience);
    list.insert(newIndex, list.removeAt(oldIndex));
    state = state.copyWith(defensiveResilience: list);
    _save();
  }

  void reorderMechanicalStability(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final list = List<String>.from(state.mechanicalStability);
    list.insert(newIndex, list.removeAt(oldIndex));
    state = state.copyWith(mechanicalStability: list);
    _save();
  }

  void setDefenseActivityLevel(double value) {
    state = state.copyWith(defenseActivityLevel: value);
    _save();
  }

  void incrementAutoHumanPlayer() {
    state = state.copyWith(
      autoHumanPlayerScore: state.autoHumanPlayerScore + 1,
    );
    _save();
  }

  void decrementAutoHumanPlayer() {
    if (state.autoHumanPlayerScore <= 0) return;
    state = state.copyWith(
      autoHumanPlayerScore: state.autoHumanPlayerScore - 1,
    );
    _save();
  }

  void incrementTeleHumanPlayer() {
    state = state.copyWith(
      teleHumanPlayerScore: state.teleHumanPlayerScore + 1,
    );
    _save();
  }

  void decrementTeleHumanPlayer() {
    if (state.teleHumanPlayerScore <= 0) return;
    state = state.copyWith(
      teleHumanPlayerScore: state.teleHumanPlayerScore - 1,
    );
    _save();
  }

  void reset() {
    final box = Hive.box(boxKey);
    box.delete(stratStorageKeyForIdentity(identity));
    box.delete(_stratScoutedByKey(identity));
    ref.read(uploadQueueProvider.notifier).markUploaded([stratQueueIdForIdentity(identity)]);
    state = const StratState.empty();
  }
}
