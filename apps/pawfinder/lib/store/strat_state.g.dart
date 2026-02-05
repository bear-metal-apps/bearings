// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strat_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DriverSkillNotifier)
final driverSkillProvider = DriverSkillNotifierProvider._();

final class DriverSkillNotifierProvider
    extends $NotifierProvider<DriverSkillNotifier, List<String>> {
  DriverSkillNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverSkillProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverSkillNotifierHash();

  @$internal
  @override
  DriverSkillNotifier create() => DriverSkillNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$driverSkillNotifierHash() =>
    r'03caaae47658770785f45489135c7a3b815c9af7';

abstract class _$DriverSkillNotifier extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(RigidityNotifier)
final rigidityProvider = RigidityNotifierProvider._();

final class RigidityNotifierProvider
    extends $NotifierProvider<RigidityNotifier, List<String>> {
  RigidityNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rigidityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rigidityNotifierHash();

  @$internal
  @override
  RigidityNotifier create() => RigidityNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$rigidityNotifierHash() => r'3c35385535abdb4f60221bbbfe45dc6bd8824b70';

abstract class _$RigidityNotifier extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
