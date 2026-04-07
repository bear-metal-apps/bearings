import 'package:riverpod/riverpod.dart';

class PitsProgressProvider extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() {
    return {
      "2026wabon": 0,
      "2026wasam": 0,
      "2026waahs": 0,
      "2026pncmp": 0,
    };
  }

  void addPercentage(String eventKey, double increment) {
      if (state.containsKey(eventKey)) {
        double? oldValue = state[eventKey];
        state = {...state, eventKey: (oldValue ?? 0) + increment};
      }
  }
}

final pitsProgressNotifierProvider =
NotifierProvider<PitsProgressProvider, Map<String, double>>(
      () => PitsProgressProvider(),
);
