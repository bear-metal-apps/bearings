import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'connectivity_provider.g.dart';

enum HoneycombEndpointMode { azure, cloudflare, custom }

class HoneycombEndpointSelection {
  final HoneycombEndpointMode mode;
  final String? customUrl;

  const HoneycombEndpointSelection({required this.mode, this.customUrl});

  const HoneycombEndpointSelection.azure()
    : mode = HoneycombEndpointMode.azure,
      customUrl = null;

  String get baseUrl {
    switch (mode) {
      case HoneycombEndpointMode.azure:
        return 'https://honeycomb-a3d3bbaacjhsaxbu.westus2-01.azurewebsites.net/api';
      case HoneycombEndpointMode.cloudflare:
        return 'https://honeycomb.bearings.workers.dev/api';
      case HoneycombEndpointMode.custom:
        final url = customUrl?.trim();
        if (url == null || url.isEmpty) {
          // fallback to azure if custom is invalid
          return 'https://honeycomb-a3d3bbaacjhsaxbu.westus2-01.azurewebsites.net/api';
        }
        return url.endsWith('/api') ? url : '$url/api';
    }
  }
}

const _endpointModeKey = 'honeycomb_endpoint_mode';
const _endpointCustomUrlKey = 'honeycomb_endpoint_custom_url';

@Riverpod(keepAlive: true)
class HoneycombEndpointPreference extends _$HoneycombEndpointPreference {
  @override
  HoneycombEndpointSelection build() {
    // Synchronously return default, then async load will update
    return const HoneycombEndpointSelection.azure();
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_endpointModeKey);
    final mode = HoneycombEndpointMode.values
        .cast<HoneycombEndpointMode?>()
        .firstWhere((entry) => entry?.name == modeName, orElse: () => null);

    if (mode != null) {
      state = HoneycombEndpointSelection(
        mode: mode,
        customUrl: prefs.getString(_endpointCustomUrlKey),
      );
    }
  }

  Future<void> setSelection(
    HoneycombEndpointMode mode, {
    String? customUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_endpointModeKey, mode.name);

    if (customUrl != null && customUrl.trim().isNotEmpty) {
      await prefs.setString(_endpointCustomUrlKey, customUrl.trim());
    } else {
      await prefs.remove(_endpointCustomUrlKey);
    }

    state = HoneycombEndpointSelection(
      mode: mode,
      customUrl: customUrl?.trim(),
    );
  }

  Future<void> setBest() => setSelection(HoneycombEndpointMode.azure);

  Future<void> setAzure() => setSelection(HoneycombEndpointMode.azure);

  Future<void> setCloudflare() =>
      setSelection(HoneycombEndpointMode.cloudflare);

  Future<void> setCustomUrl(String? value) {
    return setSelection(HoneycombEndpointMode.custom, customUrl: value);
  }
}

/// A single shared [InternetConnection] instance used by both the reactive
/// stream and one-off awaitable checks in the request/auth paths.
@Riverpod(keepAlive: true)
InternetConnection internetConnection(Ref ref) {
  return InternetConnection.createInstance();
}

/// Streams `true` when the device has internet access, `false` when offline.
@Riverpod(keepAlive: true)
Stream<bool> connectivity(Ref ref) async* {
  final checker = ref.watch(internetConnectionProvider);

  yield await checker.hasInternetAccess;

  await for (final status in checker.onStatusChange) {
    yield status == InternetStatus.connected;
  }
}

Future<bool> checkOnline(Ref ref) {
  return ref.read(internetConnectionProvider).hasInternetAccess;
}

bool isDefinitelyOffline(Ref ref) {
  return ref.read(connectivityProvider).value == false;
}
