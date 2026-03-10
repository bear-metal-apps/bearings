// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthStatusNotifier)
final authStatusProvider = AuthStatusNotifierProvider._();

final class AuthStatusNotifierProvider
    extends $NotifierProvider<AuthStatusNotifier, AuthStatus> {
  AuthStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStatusNotifierHash();

  @$internal
  @override
  AuthStatusNotifier create() => AuthStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthStatus>(value),
    );
  }
}

String _$authStatusNotifierHash() =>
    r'f794c783a7ebcd324113eb848d2aa6f0c02ca9cb';

abstract class _$AuthStatusNotifier extends $Notifier<AuthStatus> {
  AuthStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthStatus, AuthStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthStatus, AuthStatus>,
              AuthStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(auth0Config)
final auth0ConfigProvider = Auth0ConfigProvider._();

final class Auth0ConfigProvider
    extends $FunctionalProvider<Auth0Config, Auth0Config, Auth0Config>
    with $Provider<Auth0Config> {
  Auth0ConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auth0ConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auth0ConfigHash();

  @$internal
  @override
  $ProviderElement<Auth0Config> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Auth0Config create(Ref ref) {
    return auth0Config(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Auth0Config value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Auth0Config>(value),
    );
  }
}

String _$auth0ConfigHash() => r'640f847a5e3de0e4d682dcc18e12bbede8bfafd3';

@ProviderFor(auth)
final authProvider = AuthProvider._();

final class AuthProvider extends $FunctionalProvider<Auth, Auth, Auth>
    with $Provider<Auth> {
  AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  $ProviderElement<Auth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Auth create(Ref ref) {
    return auth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Auth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Auth>(value),
    );
  }
}

String _$authHash() => r'b0e9403e68684cdfccf49ca9b6eade5ce99eb663';
