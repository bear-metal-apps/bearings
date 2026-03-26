import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:pawfinder/data/local_data.dart';
import 'package:pawfinder/data/match_form_store.dart';
import 'package:pawfinder/data/upload_queue.dart';
import 'package:pawfinder/services/scout_upload_service.dart';
import 'package:pawfinder/store/strat_state.dart';

import 'scouting_providers.dart';

class ScoutingFlowController {
  final Ref _ref;

  ScoutingFlowController(this._ref);

  bool markCurrentMatchForUpload() {
    final session = _ref.read(scoutingSessionProvider);
    final eventKey = session.event?.key;
    final matchNumber = session.matchNumber;
    final pos = session.position?.posIndex;
    if (eventKey == null || matchNumber == null || pos == null) return false;

    final data = _ref
        .read(matchFormStoreProvider)
        .load(eventKey, matchNumber, pos);
    if (data == null) return false;

    _ref.read(uploadQueueProvider.notifier).enqueue(data.id);
    return true;
  }

  bool markCurrentStratForUpload() {
    final identity = _ref
        .read(scoutingSessionProvider.notifier)
        .createMatchIdentity();
    if (identity == null) return false;

    final raw = Hive.box(boxKey).get(stratStorageKeyForIdentity(identity));
    if (raw is! String) return false;

    _ref
        .read(uploadQueueProvider.notifier)
        .enqueue(stratQueueIdForIdentity(identity));
    return true;
  }

  bool nextMatch() {
    markCurrentMatchForUpload();
    markCurrentStratForUpload();
    unawaited(_ref.read(scoutUploadServiceProvider).drainIfOnline());
    _ref.read(scoutingSessionProvider.notifier).nextMatch();
    return true;
  }

  bool previousMatch() {
    final current = _ref.read(scoutingSessionProvider).matchNumber;
    if (current == null || current <= 1) return false;

    markCurrentMatchForUpload();
    markCurrentStratForUpload();
    unawaited(_ref.read(scoutUploadServiceProvider).drainIfOnline());
    _ref.read(scoutingSessionProvider.notifier).previousMatch();
    return true;
  }

  bool resetCurrentMatchData() {
    final session = _ref.read(scoutingSessionProvider);
    final eventKey = session.event?.key;
    final matchNumber = session.matchNumber;
    final pos = session.position?.posIndex;
    if (eventKey == null || matchNumber == null || pos == null) return false;

    final store = _ref.read(matchFormStoreProvider);
    final existing = store.load(eventKey, matchNumber, pos);
    if (existing != null) {
      _ref.read(uploadQueueProvider.notifier).markUploaded([existing.id]);
    }

    Hive.box(boxKey).delete(MatchFormStore.keyFor(eventKey, matchNumber, pos));
    final notifier = _ref.read(scoutingSessionProvider.notifier);
    notifier.incrementFormResetCounter();
    return true;
  }
}

final scoutingFlowControllerProvider = Provider<ScoutingFlowController>(
  (ref) => ScoutingFlowController(ref),
);
