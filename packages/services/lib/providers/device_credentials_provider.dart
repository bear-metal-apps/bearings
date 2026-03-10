import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:services/providers/api_provider.dart';

part 'device_credentials_provider.g.dart';

class DeviceCredentials {
  final String clientId;
  final String clientSecret;
  final String domain;
  final String audience;

  const DeviceCredentials({
    required this.clientId,
    required this.clientSecret,
    required this.domain,
    required this.audience,
  });

  factory DeviceCredentials.fromJson(Map<String, dynamic> json) {
    return DeviceCredentials(
      clientId: json['clientId'] as String,
      clientSecret: json['clientSecret'] as String,
      domain: json['domain'] as String,
      audience: json['audience'] as String,
    );
  }

  String toQrPayload() {
    return '{"clientId":"$clientId","clientSecret":"$clientSecret","domain":"$domain","audience":"$audience"}';
  }
}

@Riverpod(keepAlive: false)
Future<DeviceCredentials> deviceCredentials(Ref ref) async {
  final client = ref.watch(honeycombClientProvider);
  final payload = await client.get<Map<String, dynamic>>(
    '/device/credentials',
    cachePolicy: CachePolicy.networkFirst,
  );
  return DeviceCredentials.fromJson(payload);
}
