import 'package:riverpod/riverpod.dart';

class PitsProgressProvider extends Notifier<List<Map<String, double>>> {
  @override
  List<Map<String, double>> build() {
    return [
      {"2026wabon": 0},
      {"2026wasam": 0},
      {"2026waahs": 0},
      {"2026pncmp": 0},
    ];
  }

  void addPercentage(String eventKey, double increment) {
    state = state.map((map) {
      if (map.containsKey(eventKey)) {
        return {eventKey: map[eventKey]! + increment};
      }
      return map;
    }).toList();
  }
}

final pitsProgressNotifierProvider =
NotifierProvider<PitsProgressProvider, List<Map<String, double>>>(
      () => PitsProgressProvider(),
);
