import 'package:beariscope/providers/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kDefaultIncorrectDataThreshold = 10.0;
const _incorrectDataThresholdKey = 'scout_audit_incorrect_data_threshold';

final scoutAuditIncorrectThresholdProvider =
    NotifierProvider<ScoutAuditIncorrectThresholdNotifier, double>(
      ScoutAuditIncorrectThresholdNotifier.new,
    );

class ScoutAuditIncorrectThresholdNotifier extends Notifier<double> {
  @override
  double build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getDouble(_incorrectDataThresholdKey);
    if (stored == null || stored.isNaN || stored <= 0) {
      return kDefaultIncorrectDataThreshold;
    }
    return stored.clamp(0.0, 300.0);
  }

  Future<void> setThreshold(double threshold) async {
    final value = threshold.clamp(1.0, 300.0);
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(_incorrectDataThresholdKey, value);
  }
}
