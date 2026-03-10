// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rbac_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rbacManagementService)
final rbacManagementServiceProvider = RbacManagementServiceProvider._();

final class RbacManagementServiceProvider
    extends
        $FunctionalProvider<
          RbacManagementService,
          RbacManagementService,
          RbacManagementService
        >
    with $Provider<RbacManagementService> {
  RbacManagementServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rbacManagementServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rbacManagementServiceHash();

  @$internal
  @override
  $ProviderElement<RbacManagementService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RbacManagementService create(Ref ref) {
    return rbacManagementService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RbacManagementService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RbacManagementService>(value),
    );
  }
}

String _$rbacManagementServiceHash() =>
    r'c371b8ab4cc42f3244ca037e9d9c1ae044025bea';

@ProviderFor(rbacRoles)
final rbacRolesProvider = RbacRolesProvider._();

final class RbacRolesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ManagedRole>>,
          List<ManagedRole>,
          FutureOr<List<ManagedRole>>
        >
    with
        $FutureModifier<List<ManagedRole>>,
        $FutureProvider<List<ManagedRole>> {
  RbacRolesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rbacRolesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rbacRolesHash();

  @$internal
  @override
  $FutureProviderElement<List<ManagedRole>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ManagedRole>> create(Ref ref) {
    return rbacRoles(ref);
  }
}

String _$rbacRolesHash() => r'1a386c37fee3f89c5a4415479fc56e7e557700f2';

@ProviderFor(rbacUsers)
final rbacUsersProvider = RbacUsersProvider._();

final class RbacUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ManagedUser>>,
          List<ManagedUser>,
          FutureOr<List<ManagedUser>>
        >
    with
        $FutureModifier<List<ManagedUser>>,
        $FutureProvider<List<ManagedUser>> {
  RbacUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rbacUsersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rbacUsersHash();

  @$internal
  @override
  $FutureProviderElement<List<ManagedUser>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ManagedUser>> create(Ref ref) {
    return rbacUsers(ref);
  }
}

String _$rbacUsersHash() => r'1a2ab24b88721d539558946ba57ab5071462481b';

@ProviderFor(rbacMetadata)
final rbacMetadataProvider = RbacMetadataProvider._();

final class RbacMetadataProvider
    extends
        $FunctionalProvider<
          AsyncValue<RbacMetadata>,
          RbacMetadata,
          FutureOr<RbacMetadata>
        >
    with $FutureModifier<RbacMetadata>, $FutureProvider<RbacMetadata> {
  RbacMetadataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rbacMetadataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rbacMetadataHash();

  @$internal
  @override
  $FutureProviderElement<RbacMetadata> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RbacMetadata> create(Ref ref) {
    return rbacMetadata(ref);
  }
}

String _$rbacMetadataHash() => r'358a26196df41ebe55ed9f05e654a9803f4f46aa';
