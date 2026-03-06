import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:pawfinder/data/local_data.dart';

/// Provider that tracks whether the app is running in guest mode.
/// Guest mode allows users to use the app without authentication when offline.
class GuestModeNotifier extends Notifier<bool> {
  static const _hiveKey = 'is_guest_mode';

  @override
  bool build() {
    final box = Hive.box(boxKey);
    return box.get(_hiveKey, defaultValue: false) as bool;
  }

  /// Enable guest mode
  void enable() {
    state = true;
    _persist();
  }

  /// Disable guest mode (when user signs in)
  void disable() {
    state = false;
    _persist();
  }

  void _persist() {
    Hive.box(boxKey).put(_hiveKey, state);
  }
}

final guestModeProvider = NotifierProvider<GuestModeNotifier, bool>(
  GuestModeNotifier.new,
);
