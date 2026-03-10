import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

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
