// Data models for the scouting session flow.
//
// These models represent data fetched from Honeycomb/TBA and the user's
// active scouting configuration.

enum ScoutPosition {
  red1('Red 1', true, false),
  red2('Red 2', true, false),
  red3('Red 3', true, false),
  redStrat('Red Strat', true, true),
  blue1('Blue 1', false, false),
  blue2('Blue 2', false, false),
  blue3('Blue 3', false, false),
  blueStrat('Blue Strat', false, true);

  const ScoutPosition(this.displayName, this.isRed, this.isStrategy);

  final String displayName;
  final bool isRed;
  final bool isStrategy;

  /// Returns the 0-based alliance position index (0, 1, or 2) for non-strategy
  /// positions. Returns -1 for strategy positions.
  int get allianceIndex {
    switch (this) {
      case red1:
      case blue1:
        return 0;
      case red2:
      case blue2:
        return 1;
      case red3:
      case blue3:
        return 2;
      case redStrat:
      case blueStrat:
        return -1;
    }
  }

  String get allianceKey => isRed ? 'red' : 'blue';

  int get posIndex {
    switch (this) {
      case red1:
        return 0;
      case red2:
        return 1;
      case red3:
        return 2;
      case blue1:
        return 3;
      case blue2:
        return 4;
      case blue3:
        return 5;
      case redStrat:
        return 6;
      case blueStrat:
        return 7;
    }
  }
}

class ScoutingEvent {
  final String key;
  final String name;
  final int year;
  final DateTime? startDate;
  final DateTime? endDate;

  const ScoutingEvent({
    required this.key,
    required this.name,
    required this.year,
    this.startDate,
    this.endDate,
  });

  factory ScoutingEvent.fromJson(Map<String, dynamic> json) {
    return ScoutingEvent(
      key: json['key'] as String,
      name: json['name'] as String,
      year: json['year'] as int,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'year': year,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoutingEvent &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => name;
}

class MatchAlliance {
  final int? score;
  final List<String> teamKeys;

  const MatchAlliance({this.score, this.teamKeys = const []});

  factory MatchAlliance.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return MatchAlliance(
      score: parseInt(json['score']),
      teamKeys:
          (json['team_keys'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class ScoutingMatch {
  final String key;
  final String compLevel;
  final int matchNumber;
  final int setNumber;
  final String? eventKey;
  final MatchAlliance? redAlliance;
  final MatchAlliance? blueAlliance;
  final int? predictedTime;
  final int? actualTime;

  const ScoutingMatch({
    required this.key,
    required this.compLevel,
    required this.matchNumber,
    this.setNumber = 1,
    this.eventKey,
    this.redAlliance,
    this.blueAlliance,
    this.predictedTime,
    this.actualTime,
  });

  factory ScoutingMatch.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? asStringMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), v));
      }
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    final alliances = asStringMap(json['alliances']);
    final red = asStringMap(alliances?['red']);
    final blue = asStringMap(alliances?['blue']);

    return ScoutingMatch(
      key: json['key']?.toString() ?? '',
      compLevel: json['comp_level']?.toString() ?? '',
      matchNumber: parseInt(json['match_number']) ?? 0,
      setNumber: parseInt(json['set_number']) ?? 1,
      eventKey: json['event_key'] as String?,
      redAlliance: red != null ? MatchAlliance.fromJson(red) : null,
      blueAlliance: blue != null ? MatchAlliance.fromJson(blue) : null,
      predictedTime: parseInt(json['predicted_time']),
      actualTime: parseInt(json['actual_time']),
    );
  }

  /// Display label for the match (e.g. "Qual 12", "SF 2-1", "Final 1")
  String get displayLabel {
    switch (compLevel) {
      case 'qm':
        return 'Qual $matchNumber';
      case 'sf':
        return 'SF $setNumber-$matchNumber';
      case 'f':
        return 'Final $matchNumber';
      default:
        return '$compLevel $matchNumber';
    }
  }

  /// Get the team key at a specific position for the given alliance.
  String? teamKeyAt(ScoutPosition position) {
    final alliance = position.isRed ? redAlliance : blueAlliance;
    if (alliance == null) return null;
    final idx = position.allianceIndex;
    if (idx < 0 || idx >= alliance.teamKeys.length) return null;
    return alliance.teamKeys[idx];
  }

  /// Returns team number string (without "frc" prefix) for a position.
  String teamNumberAt(ScoutPosition position) {
    final key = teamKeyAt(position);
    if (key == null) return '???';
    return key.replaceFirst('frc', '');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoutingMatch &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
}

class Scout {
  final String name;
  final String uuid;

  const Scout({required this.name, required this.uuid});

  factory Scout.fromJson(Map<String, dynamic> json) {
    return Scout(name: json['name'] as String, uuid: json['uuid'] as String);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Scout && runtimeType == other.runtimeType && uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() => name;
}

class ScoutingSession {
  final ScoutingEvent? event;
  final ScoutPosition? position;
  final Scout? scout;
  final int? matchNumber;
  final int? resetVersion;

  const ScoutingSession({
    this.event,
    this.position,
    this.scout,
    this.matchNumber,
    this.resetVersion = 0,
  });

  bool get isConfigured =>
      event != null && position != null && scout != null && matchNumber != null;

  ScoutingSession copyWith({
    ScoutingEvent? event,
    ScoutPosition? position,
    Scout? scout,
    int? matchNumber,
    int? resetVersion,
  }) {
    return ScoutingSession(
      event: event ?? this.event,
      position: position ?? this.position,
      scout: scout ?? this.scout,
      matchNumber: matchNumber ?? this.matchNumber,
      resetVersion: resetVersion ?? this.resetVersion,
    );
  }
}
