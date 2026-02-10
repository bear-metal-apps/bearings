import 'package:beariscope_scouter/models/scouting_session.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:libkoala/providers/api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scouting_providers.g.dart';

@riverpod
Future<List<ScoutingEvent>> events(Ref ref) async {
  final client = ref.read(honeycombClientProvider);
  final year = DateTime.now().year.toString();

  final data = await client.get<List<dynamic>>(
    '/events',
    queryParams: {'team': 'frc2046', 'year': year},
  );

  final events = data
      .map((e) => ScoutingEvent.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  events.sort((a, b) {
    if (a.startDate == null && b.startDate == null) return 0;
    if (a.startDate == null) return 1;
    if (b.startDate == null) return -1;
    return a.startDate!.compareTo(b.startDate!);
  });

  return events;
}

@riverpod
Future<List<ScoutingMatch>> matches(Ref ref, String eventKey) async {
  final client = ref.read(honeycombClientProvider);

  final data = await client.get<List<dynamic>>(
    '/matches',
    queryParams: {'event': eventKey},
  );

  final matches = data
      .map((e) => ScoutingMatch.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  matches.sort((a, b) {
    const levelOrder = {'qm': 0, 'sf': 1, 'f': 2};
    final levelA = levelOrder[a.compLevel] ?? 3;
    final levelB = levelOrder[b.compLevel] ?? 3;
    if (levelA != levelB) return levelA.compareTo(levelB);
    if (a.setNumber != b.setNumber) return a.setNumber.compareTo(b.setNumber);
    return a.matchNumber.compareTo(b.matchNumber);
  });

  return matches;
}

@riverpod
Future<List<Scout>> scouts(Ref ref) async {
  final client = ref.read(honeycombClientProvider);

  final data = await client.get<List<dynamic>>('/scouts');

  final scouts = data
      .map((e) => Scout.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  scouts.sort((a, b) => a.name.compareTo(b.name));

  return scouts;
}

@Riverpod(keepAlive: true)
class ScoutingSessionNotifier extends _$ScoutingSessionNotifier {
  static const String _eventKey = 'selected_event';
  static const String _positionKey = 'selected_position';

  @override
  ScoutingSession build() {
    final box = Hive.box('localData');
    final savedEventJson = box.get(_eventKey);
    final savedPositionString = box.get(_positionKey);

    ScoutingEvent? savedEvent;
    ScoutPosition? savedPosition;

    if (savedEventJson != null) {
      try {
        savedEvent = ScoutingEvent.fromJson(
          Map<String, dynamic>.from(savedEventJson),
        );
      } catch (e) {
        // If deserialization fails, ignore and use null
      }
    }

    if (savedPositionString != null && savedPositionString is String) {
      try {
        savedPosition = ScoutPosition.values.firstWhere(
          (pos) => pos.name == savedPositionString,
        );
      } catch (e) {
        // If parsing fails, ignore and use null
      }
    }

    return ScoutingSession(event: savedEvent, position: savedPosition);
  }

  void setEvent(ScoutingEvent event) {
    state = state.copyWith(event: event);
    final box = Hive.box('localData');
    box.put(_eventKey, event.toJson());
  }

  void setPosition(ScoutPosition position) {
    state = state.copyWith(position: position);
    final box = Hive.box('localData');
    box.put(_positionKey, position.name);
  }

  void setScout(Scout scout) {
    state = state.copyWith(scout: scout);
  }

  void setMatchNumber(int matchNumber) {
    state = state.copyWith(matchNumber: matchNumber);
  }

  void nextMatch() {
    if (state.matchNumber != null) {
      state = state.copyWith(matchNumber: state.matchNumber! + 1);
    }
  }

  void previousMatch() {
    if (state.matchNumber != null && state.matchNumber! > 1) {
      state = state.copyWith(matchNumber: state.matchNumber! - 1);
    }
  }

  void exitToScoutSelect() {
    state = ScoutingSession(
      event: state.event,
      position: state.position,
      matchNumber: state.matchNumber,
    );
  }

  void clear() {
    state = const ScoutingSession();
  }
}
