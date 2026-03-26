import 'package:core/core.dart' show Scout, ScoutPosition, ScoutingEvent;

export 'package:core/core.dart'
    show MatchAlliance, Scout, ScoutPosition, ScoutingEvent, ScoutingMatch;

class ScoutingSession {
  final ScoutingEvent? event;
  final ScoutPosition? position;
  final Scout? scout;
  final int? matchNumber;
  final int formResetCounter;
  final int stratResetCounter;

  const ScoutingSession({
    this.event,
    this.position,
    this.scout,
    this.matchNumber,
    this.formResetCounter = 0,
    this.stratResetCounter = 0,
  });

  bool get isConfigured =>
      event != null && position != null && scout != null && matchNumber != null;

  ScoutingSession copyWith({
    ScoutingEvent? event,
    ScoutPosition? position,
    Scout? scout,
    int? matchNumber,
    int? formResetCounter,
    int? stratResetCounter,
  }) {
    return ScoutingSession(
      event: event ?? this.event,
      position: position ?? this.position,
      scout: scout ?? this.scout,
      matchNumber: matchNumber ?? this.matchNumber,
      formResetCounter: formResetCounter ?? this.formResetCounter,
      stratResetCounter: stratResetCounter ?? this.stratResetCounter,
    );
  }
}
