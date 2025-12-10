import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


part 'strat_state.g.dart';

mixin StratNotifier {
  void reorder(int oldIndex, int newIndex);
  List<String> get();
}

@riverpod
class DriverSkillNotifier extends _$DriverSkillNotifier with StratNotifier {
  @override
  List<String> build() => ["2000", "1000", "2046"];

  @override
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = state.removeAt(oldIndex);
    state.insert(newIndex, item);
  }

  @override
  List<String> get() {
    return state;
  }
}

@riverpod
class RigidityNotifier extends _$RigidityNotifier with StratNotifier {
  @override
  List<String> build() => ["2000", "1000", "2046"];

  @override
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = state.removeAt(oldIndex);
    state.insert(newIndex, item);
  }

  @override
  List<String> get() {
    return state;
  }
}


