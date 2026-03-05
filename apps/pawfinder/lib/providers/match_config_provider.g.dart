// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(matchConfig)
final matchConfigProvider = MatchConfigProvider._();

final class MatchConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<MatchConfig>,
          MatchConfig,
          FutureOr<MatchConfig>
        >
    with $FutureModifier<MatchConfig>, $FutureProvider<MatchConfig> {
  MatchConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchConfigHash();

  @$internal
  @override
  $FutureProviderElement<MatchConfig> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MatchConfig> create(Ref ref) {
    return matchConfig(ref);
  }
}

String _$matchConfigHash() => r'c62188bafbfe53417ba0e1ce9a5056184426dd9e';
