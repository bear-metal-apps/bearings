// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tokenStorage)
final tokenStorageProvider = TokenStorageProvider._();

final class TokenStorageProvider
    extends
        $FunctionalProvider<
          AsyncValue<TokenStorage>,
          TokenStorage,
          FutureOr<TokenStorage>
        >
    with $FutureModifier<TokenStorage>, $FutureProvider<TokenStorage> {
  TokenStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenStorageHash();

  @$internal
  @override
  $FutureProviderElement<TokenStorage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TokenStorage> create(Ref ref) {
    return tokenStorage(ref);
  }
}

String _$tokenStorageHash() => r'631acced66260d668911a1b213724b44a5425861';
