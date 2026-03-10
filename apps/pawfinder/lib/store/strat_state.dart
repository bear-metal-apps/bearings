import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:pawfinder/data/local_data.dart';
import 'package:pawfinder/data/match_json_gen.dart';
import 'package:pawfinder/data/upload_queue.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'strat_state.g.dart';

// hive key for a given match's strat data
String _stratKey(MatchIdentity identity) =>
    'STRAT_${identityDataKey(identity)}';

class StratState {
  final List<String> driverSkill;
  final List<String> defensiveSkill;
  final List<String> defensiveSusceptibility;
  final List<String> mechanicalStability;
  final double defenseActivityLevel;
  final int humanPlayerScore;

  const StratState({
    required this.driverSkill,
    required this.defensiveSkill,
    required this.defensiveSusceptibility,
    required this.mechanicalStability,
    required this.defenseActivityLevel,
    required this.humanPlayerScore,
  });

  // empty state for a match that hasn't been filled in yet
  const StratState.empty()
    : driverSkill = const [],
      defensiveSkill = const [],
      defensiveSusceptibility = const [],
      mechanicalStability = const [],
      defenseActivityLevel = 0.0,
      humanPlayerScore = 0;

  StratState copyWith({
    List<String>? driverSkill,
    List<String>? defensiveSkill,
    List<String>? defensiveSusceptibility,
    List<String>? mechanicalStability,
    double? defenseActivityLevel,
    int? humanPlayerScore,
  }) => StratState(
    driverSkill: driverSkill ?? this.driverSkill,
    defensiveSkill: defensiveSkill ?? this.defensiveSkill,
    defensiveSusceptibility:
        defensiveSusceptibility ?? this.defensiveSusceptibility,
    mechanicalStability: mechanicalStability ?? this.mechanicalStability,
    defenseActivityLevel: defenseActivityLevel ?? this.defenseActivityLevel,
    humanPlayerScore: humanPlayerScore ?? this.humanPlayerScore,
  );

  Map<String, dynamic> toJson() => {
    'driverSkill': driverSkill,
    'defensiveSkill': defensiveSkill,
    'defensiveSusceptibility': defensiveSusceptibility,
    'mechanicalStability': mechanicalStability,
    'defenseActivityLevel': defenseActivityLevel,
    'humanPlayerScore': humanPlayerScore,
  };

  factory StratState.fromJson(Map<String, dynamic> json) => StratState(
    driverSkill: List<String>.from(json['driverSkill'] ?? []),
    defensiveSkill: List<String>.from(json['defensiveSkill'] ?? []),
    defensiveSusceptibility: List<String>.from(
      json['defensiveSusceptibility'] ?? [],
    ),
    mechanicalStability: List<String>.from(json['mechanicalStability'] ?? []),
    defenseActivityLevel:
        (json['defenseActivityLevel'] as num?)?.toDouble() ?? 0.0,
    humanPlayerScore: (json['humanPlayerScore'] as num?)?.toInt() ?? 0,
  );
}

// one notifier per match identity — reads/writes to hive on every change
// using keepAlive so the data doesn't get reset while the scout is still on the strat page
@Riverpod(keepAlive: true)
class StratStateNotifier extends _$StratStateNotifier {
  @override
  StratState build(MatchIdentity identity) {
    final raw = Hive.box(boxKey).get(_stratKey(identity));
    if (raw is String) {
      try {
        return StratState.fromJson(jsonDecode(raw));
      } catch (_) {}
    }
    return const StratState.empty();
  }

  void _save({bool markForUpload = true}) {
    Hive.box(boxKey).put(_stratKey(identity), jsonEncode(state.toJson()));
    if (markForUpload) {
      // queue only when the scout actually changed something
      ref.read(uploadQueueProvider.notifier).addIfNotPresent(identity);
    }
  }

  // populate lists from the schedule if they're still empty (new match)
  void initFromSchedule(List<String> teams) {
    if (teams.isEmpty || state.driverSkill.isNotEmpty) return;
    state = state.copyWith(
      driverSkill: List.from(teams),
      defensiveSkill: List.from(teams),
      defensiveSusceptibility: List.from(teams),
      mechanicalStability: List.from(teams),
    );
    _save(markForUpload: false);
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

  void reorderDefensiveSusceptibility(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final list = List<String>.from(state.defensiveSusceptibility);
    list.insert(newIndex, list.removeAt(oldIndex));
    state = state.copyWith(defensiveSusceptibility: list);
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

  void incrementHumanPlayer() {
    state = state.copyWith(humanPlayerScore: state.humanPlayerScore + 1);
    _save();
  }

  void decrementHumanPlayer() {
    if (state.humanPlayerScore <= 0) return;
    state = state.copyWith(humanPlayerScore: state.humanPlayerScore - 1);
    _save();
  }
}
