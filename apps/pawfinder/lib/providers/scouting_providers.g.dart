// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scouting_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(events)
final eventsProvider = EventsProvider._();

final class EventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScoutingEvent>>,
          List<ScoutingEvent>,
          FutureOr<List<ScoutingEvent>>
        >
    with
        $FutureModifier<List<ScoutingEvent>>,
        $FutureProvider<List<ScoutingEvent>> {
  EventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventsHash();

  @$internal
  @override
  $FutureProviderElement<List<ScoutingEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ScoutingEvent>> create(Ref ref) {
    return events(ref);
  }
}

String _$eventsHash() => r'cb93aaff34eda6618033533b9ce5b9155cf2d761';

@ProviderFor(matches)
final matchesProvider = MatchesFamily._();

final class MatchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScoutingMatch>>,
          List<ScoutingMatch>,
          FutureOr<List<ScoutingMatch>>
        >
    with
        $FutureModifier<List<ScoutingMatch>>,
        $FutureProvider<List<ScoutingMatch>> {
  MatchesProvider._({
    required MatchesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'matchesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$matchesHash();

  @override
  String toString() {
    return r'matchesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ScoutingMatch>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ScoutingMatch>> create(Ref ref) {
    final argument = this.argument as String;
    return matches(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$matchesHash() => r'96b8c5c7fee2a0820ce3be9b2406df4964e2502c';

final class MatchesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ScoutingMatch>>, String> {
  MatchesFamily._()
    : super(
        retry: null,
        name: r'matchesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MatchesProvider call(String eventKey) =>
      MatchesProvider._(argument: eventKey, from: this);

  @override
  String toString() => r'matchesProvider';
}

@ProviderFor(scouts)
final scoutsProvider = ScoutsProvider._();

final class ScoutsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Scout>>,
          List<Scout>,
          FutureOr<List<Scout>>
        >
    with $FutureModifier<List<Scout>>, $FutureProvider<List<Scout>> {
  ScoutsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scoutsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scoutsHash();

  @$internal
  @override
  $FutureProviderElement<List<Scout>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Scout>> create(Ref ref) {
    return scouts(ref);
  }
}

String _$scoutsHash() => r'9b4fc843ec2ccc737351ad27a98f3c546923f1f7';

@ProviderFor(ScoutingSessionNotifier)
final scoutingSessionProvider = ScoutingSessionNotifierProvider._();

final class ScoutingSessionNotifierProvider
    extends $NotifierProvider<ScoutingSessionNotifier, ScoutingSession> {
  ScoutingSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scoutingSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scoutingSessionNotifierHash();

  @$internal
  @override
  ScoutingSessionNotifier create() => ScoutingSessionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScoutingSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScoutingSession>(value),
    );
  }
}

String _$scoutingSessionNotifierHash() =>
    r'a2203eb959137d32792e635e19c1072be45b5f72';

abstract class _$ScoutingSessionNotifier extends $Notifier<ScoutingSession> {
  ScoutingSession build();

  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ScoutingSession, ScoutingSession>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScoutingSession, ScoutingSession>,
              ScoutingSession,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
