// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authMe)
final authMeProvider = AuthMeProvider._();

final class AuthMeProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthMePayload?>,
          AuthMePayload?,
          FutureOr<AuthMePayload?>
        >
    with $FutureModifier<AuthMePayload?>, $FutureProvider<AuthMePayload?> {
  AuthMeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authMeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authMeHash();

  @$internal
  @override
  $FutureProviderElement<AuthMePayload?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AuthMePayload?> create(Ref ref) {
    return authMe(ref);
  }
}

String _$authMeHash() => r'128c21b4c5f0f08104944149198eec5db4cb935a';

@ProviderFor(permissionChecker)
final permissionCheckerProvider = PermissionCheckerProvider._();

final class PermissionCheckerProvider
    extends
        $FunctionalProvider<
          PermissionChecker?,
          PermissionChecker?,
          PermissionChecker?
        >
    with $Provider<PermissionChecker?> {
  PermissionCheckerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionCheckerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionCheckerHash();

  @$internal
  @override
  $ProviderElement<PermissionChecker?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PermissionChecker? create(Ref ref) {
    return permissionChecker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PermissionChecker? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PermissionChecker?>(value),
    );
  }
}

String _$permissionCheckerHash() => r'9bf90be930089398c974048a598e8e59ed7c9165';
