import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:services/providers/auth_provider.dart';
import 'package:services/providers/permissions_provider.dart';

enum AppBootStage { initializing, restoringSession, loadingPermissions, ready }

extension AppBootStageExtention on AppBootStage {
  String get label => switch (this) {
    AppBootStage.initializing => 'Starting up...',
    AppBootStage.restoringSession => 'Authenticating...',
    AppBootStage.loadingPermissions => 'Authorizing...',
    AppBootStage.ready => 'Crescendo!',
  };

  double get progress => switch (this) {
    AppBootStage.initializing => 0.1,
    AppBootStage.restoringSession => 0.3,
    AppBootStage.loadingPermissions => 0.7,
    AppBootStage.ready => 1.0,
  };
}

class AppBootState {
  final AppBootStage stage;
  final String message;
  final double progress;

  const AppBootState({
    required this.stage,
    required this.message,
    required this.progress,
  });

  factory AppBootState.initial() {
    return AppBootState(
      stage: AppBootStage.initializing,
      message: AppBootStage.initializing.label,
      progress: 0.0,
    );
  }

  factory AppBootState.stage(AppBootStage stage) {
    return AppBootState(
      stage: stage,
      message: stage.label,
      progress: stage.progress,
    );
  }

  bool get isReady => stage == AppBootStage.ready;
}

class AppBootNotifier extends Notifier<AppBootState> {
  Completer<void>? _startCompleter;

  @override
  AppBootState build() => AppBootState.initial();

  Future<void> start() {
    if (state.isReady) {
      return Future.value();
    }

    final completer = _startCompleter;
    if (completer != null) {
      return completer.future;
    }

    final nextCompleter = Completer<void>();
    _startCompleter = nextCompleter;
    unawaited(_runBoot(nextCompleter));
    return nextCompleter.future;
  }

  Future<void> _runBoot(Completer<void> completer) async {
    try {
      state = AppBootState.stage(AppBootStage.initializing);
      await Future<void>.delayed(Duration.zero);

      state = AppBootState.stage(AppBootStage.restoringSession);
      await ref.read(authProvider).trySilentLogin();

      state = AppBootState.stage(AppBootStage.loadingPermissions);
      await ref.read(authMeProvider.future);

      state = AppBootState.stage(AppBootStage.ready);
      completer.complete();
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      if (identical(_startCompleter, completer)) {
        _startCompleter = null;
      }
    }
  }
}

final appBootProvider = NotifierProvider<AppBootNotifier, AppBootState>(
  AppBootNotifier.new,
);
