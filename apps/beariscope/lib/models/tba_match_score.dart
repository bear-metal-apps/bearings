class TbaAllianceScore {
  final int autoFuelScored;
  final int teleFuelScored;
  final Map<String, dynamic> raw;

  int get totalFuelScored => autoFuelScored + teleFuelScored;

  const TbaAllianceScore({
    required this.autoFuelScored,
    required this.teleFuelScored,
    this.raw = const {},
  });

  factory TbaAllianceScore.fromScoreBreakdown(Map<String, dynamic> json) {
    final hubScore = _asMap(json['hubScore']);
    final source = hubScore ?? json;

    return TbaAllianceScore(
      autoFuelScored:
          _readInt(source, const [
            'autoCount',
            'autoFuelScored',
            'autoFuelCount',
          ]) ??
          0,
      teleFuelScored:
          _readInt(source, const [
            'teleopCount',
            'teleFuelScored',
            'teleopFuelScored',
            'teleopFuelCount',
          ]) ??
          0,
      raw: json,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(value);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
    }
    return null;
  }
}

class TbaAllianceMatch {
  final int score;
  final List<String> teamKeys;
  final List<String> dqTeamKeys;
  final List<String> surrogateTeamKeys;
  final TbaAllianceScore scoreBreakdown;

  const TbaAllianceMatch({
    required this.score,
    required this.teamKeys,
    required this.dqTeamKeys,
    required this.surrogateTeamKeys,
    required this.scoreBreakdown,
  });

  factory TbaAllianceMatch.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? scoreBreakdown,
  }) {
    return TbaAllianceMatch(
      score: _readInt(json, const ['score']) ?? 0,
      teamKeys: _stringList(json['team_keys']),
      dqTeamKeys: _stringList(json['dq_team_keys']),
      surrogateTeamKeys: _stringList(json['surrogate_team_keys']),
      scoreBreakdown: TbaAllianceScore.fromScoreBreakdown(
        scoreBreakdown ?? const <String, dynamic>{},
      ),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(value);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
    }
    return null;
  }
}

class TbaMatchVideo {
  final String key;
  final String type;

  const TbaMatchVideo({required this.key, required this.type});

  factory TbaMatchVideo.fromJson(Map<String, dynamic> json) {
    return TbaMatchVideo(
      key: json['key']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}

class TbaMatchScore {
  final int actualTime;
  final TbaAllianceMatch blue;
  final TbaAllianceMatch red;
  final String compLevel;
  final String eventKey;
  final String key;
  final int matchNumber;
  final int postResultTime;
  final int predictedTime;
  final int setNumber;
  final int time;
  final List<TbaMatchVideo> videos;
  final String? winningAlliance;
  final bool hasScoreBreakdown;

  const TbaMatchScore({
    required this.actualTime,
    required this.blue,
    required this.red,
    required this.compLevel,
    required this.eventKey,
    required this.key,
    required this.matchNumber,
    required this.postResultTime,
    required this.predictedTime,
    required this.setNumber,
    required this.time,
    required this.videos,
    required this.winningAlliance,
    required this.hasScoreBreakdown,
  });

  String get matchKey => key;

  List<String> get redTeams => red.teamKeys;

  List<String> get blueTeams => blue.teamKeys;

  TbaAllianceScore? forAlliance(String alliance) {
    return switch (alliance.toLowerCase()) {
      'red' => red.scoreBreakdown,
      'blue' => blue.scoreBreakdown,
      _ => null,
    };
  }

  factory TbaMatchScore.fromJson(Map<String, dynamic> json) {
    final key = json['key']?.toString() ?? '';
    final breakdown = _asMap(json['score_breakdown']);
    final alliances = _asMap(json['alliances']);

    final redBreakdown = _asMap(breakdown?['red']);
    final blueBreakdown = _asMap(breakdown?['blue']);

    return TbaMatchScore(
      actualTime: _readInt(json, const ['actual_time', 'actualTime']) ?? 0,
      blue: TbaAllianceMatch.fromJson(
        _asMap(alliances?['blue']) ?? const <String, dynamic>{},
        scoreBreakdown: blueBreakdown,
      ),
      red: TbaAllianceMatch.fromJson(
        _asMap(alliances?['red']) ?? const <String, dynamic>{},
        scoreBreakdown: redBreakdown,
      ),
      compLevel: json['comp_level']?.toString() ?? '',
      eventKey: json['event_key']?.toString() ?? '',
      key: key,
      matchNumber: _matchNumber(json),
      postResultTime:
          _readInt(json, const ['post_result_time', 'postResultTime']) ?? 0,
      predictedTime:
          _readInt(json, const ['predicted_time', 'predictedTime']) ?? 0,
      setNumber: _readInt(json, const ['set_number', 'setNumber']) ?? 0,
      time: _readInt(json, const ['time']) ?? 0,
      videos: _videos(json['videos']),
      winningAlliance: json['winning_alliance']?.toString(),
      hasScoreBreakdown: breakdown != null,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static List<TbaMatchVideo> _videos(dynamic value) {
    if (value is! List) return const <TbaMatchVideo>[];
    return value
        .whereType<Map>()
        .map((item) => TbaMatchVideo.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static int _matchNumber(Map<String, dynamic> json) {
    final value = json['match_number'] ?? json['matchNumber'];
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    final key = json['key']?.toString() ?? '';
    final lastPart = key.contains('_') ? key.split('_').last : key;
    final match = RegExp(
      r'^(?:qm|sf|f)?(\d+)$',
      caseSensitive: false,
    ).firstMatch(lastPart);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 0;
    }
    return 0;
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
        final parsedDouble = double.tryParse(value);
        if (parsedDouble != null) return parsedDouble.toInt();
      }
    }
    return null;
  }
}
