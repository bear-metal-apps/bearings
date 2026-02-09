import 'package:beariscope_scouter/data/local_data.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'strat_state.g.dart';

mixin StratNotifier {
  final box = Hive.box(boxKey);
  void reorder(int oldIndex, int newIndex);
  List<String> get();
  void set(List<String> list);
}

@riverpod
class DriverSkillNotifier extends _$DriverSkillNotifier with StratNotifier {
  @override
  List<String> build() => box.get('driverSkill') ?? ["2000", "1000", "2046"];

  @override
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = state.removeAt(oldIndex);
    state.insert(newIndex, item);
    box.put('driverSkill', state);
  }

  @override
  List<String> get() {
    return state;
  }

  @override
  void set(List<String> list) {
    state = list;
  }
}

@riverpod
class RigidityNotifier extends _$RigidityNotifier with StratNotifier {
  @override
  List<String> build() => box.get('rigidity') ?? ["2000", "1000", "2046"];

  @override
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = state.removeAt(oldIndex);
    state.insert(newIndex, item);
    box.put('rigidity', state);
  }

  @override
  List<String> get() {
    return state;
  }

  @override
  void set(List<String> list) {
    state = list;
  }
}