import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_platform/universal_platform.dart';

part 'device_info_provider.g.dart';

@riverpod
DeviceInfo deviceInfo(Ref ref) {
  final DevicePlatform devicePlatform;
  final DeviceOS deviceOS;

  if (UniversalPlatform.isWeb) {
    devicePlatform = DevicePlatform.web;
    deviceOS = DeviceOS.web;
  } else if (UniversalPlatform.isAndroid) {
    devicePlatform = DevicePlatform.mobile;
    deviceOS = DeviceOS.android;
  } else if (UniversalPlatform.isIOS) {
    devicePlatform = DevicePlatform.mobile;
    deviceOS = DeviceOS.ios;
  } else if (UniversalPlatform.isWindows) {
    devicePlatform = DevicePlatform.desktop;
    deviceOS = DeviceOS.windows;
  } else if (UniversalPlatform.isLinux) {
    devicePlatform = DevicePlatform.desktop;
    deviceOS = DeviceOS.linux;
  } else if (UniversalPlatform.isMacOS) {
    devicePlatform = DevicePlatform.desktop;
    deviceOS = DeviceOS.macos;
  } else {
    devicePlatform = DevicePlatform.web;
    deviceOS = DeviceOS.web;
  }

  return DeviceInfo(deviceType: devicePlatform, deviceOS: deviceOS);
}

class DeviceInfo {
  final DevicePlatform deviceType;
  final DeviceOS deviceOS;

  DeviceInfo({required this.deviceType, required this.deviceOS});
}

enum DevicePlatform { mobile, desktop, web }

enum DeviceOS { android, ios, windows, linux, macos, web }
