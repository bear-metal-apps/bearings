import 'package:flutter/widgets.dart';

class ResetController extends ChangeNotifier {
  void trigger() => notifyListeners();
}

class MatchResetScope extends InheritedNotifier<ResetController> {
  const MatchResetScope({
    super.key,
    required ResetController controller,
    required super.child,
  }) : super(notifier: controller);

  static ResetController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MatchResetScope>()
        ?.notifier;
  }
}

class StratResetScope extends InheritedNotifier<ResetController> {
  const StratResetScope({
    super.key,
    required ResetController controller,
    required super.child,
  }) : super(notifier: controller);

  static ResetController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StratResetScope>()
        ?.notifier;
  }
}
