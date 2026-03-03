import 'package:beariscope_scouter/data/upload_queue.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scouting_providers.dart';

class ScoutingFlowController {
  final Ref _ref;

  ScoutingFlowController(this._ref);

  bool markCurrentMatchForUpload() {
    final identity = _ref
        .read(scoutingSessionProvider.notifier)
        .createMatchIdentity();
    if (identity == null) return false;

    // manual call for when we explicitly want to queue current identity
    _ref.read(uploadQueueProvider.notifier).addIfNotPresent(identity);
    return true;
  }

  bool nextMatch() {
    _ref.read(scoutingSessionProvider.notifier).nextMatch();
    return true;
  }

  bool previousMatch() {
    final current = _ref.read(scoutingSessionProvider).matchNumber;
    if (current == null || current <= 1) return false;

    _ref.read(scoutingSessionProvider.notifier).previousMatch();
    return true;
  }
}

final scoutingFlowControllerProvider = Provider<ScoutingFlowController>(
  (ref) => ScoutingFlowController(ref),
);
