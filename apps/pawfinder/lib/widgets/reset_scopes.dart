import 'package:flutter/widgets.dart';

class MatchResetController extends ChangeNotifier {
  void trigger() => notifyListeners();
}

class MatchResetScope extends InheritedNotifier<MatchResetController> {
  const MatchResetScope({
    super.key,
    required MatchResetController controller,
    required super.child,
  }) : super(notifier: controller);

  static MatchResetController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MatchResetScope>()
        ?.notifier;
  }
}

class StratResetController extends ChangeNotifier {
  void trigger() => notifyListeners();
}

class StratResetScope extends InheritedNotifier<StratResetController> {
  const StratResetScope({
    super.key,
    required StratResetController controller,
    required super.child,
  }) : super(notifier: controller);

  static StratResetController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StratResetScope>()
        ?.notifier;
  }
}
