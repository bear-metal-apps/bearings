// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_auth_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceAuthService)
final deviceAuthServiceProvider = DeviceAuthServiceProvider._();

final class DeviceAuthServiceProvider
    extends
        $FunctionalProvider<
          DeviceAuthService,
          DeviceAuthService,
          DeviceAuthService
        >
    with $Provider<DeviceAuthService> {
  DeviceAuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceAuthServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceAuthServiceHash();

  @$internal
  @override
  $ProviderElement<DeviceAuthService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceAuthService create(Ref ref) {
    return deviceAuthService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceAuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceAuthService>(value),
    );
  }
}

String _$deviceAuthServiceHash() => r'3acd279f7e04f6ba50b0eb548c55ea9f1ea1f240';
