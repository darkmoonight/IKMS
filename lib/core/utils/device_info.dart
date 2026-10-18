import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Singleton helper for Android device capabilities used by theming.
class DeviceFeature {
  DeviceFeature._internal();

  static final DeviceFeature _singleton = DeviceFeature._internal();

  /// Returns the shared [DeviceFeature] instance.
  factory DeviceFeature() => _singleton;

  final _deviceInfoPlugin = DeviceInfoPlugin();
  bool? _isEdgeToEdgeAvailableCache;

  /// Loads Android device info once at app startup.
  Future<void> init() async {
    try {
      final androidDeviceInfo = await _deviceInfoPlugin.androidInfo;
      _isEdgeToEdgeAvailableCache = androidDeviceInfo.version.sdkInt > 28;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error initializing device info: $e');
      }
      _isEdgeToEdgeAvailableCache = false;
    }
  }

  /// Whether transparent system navigation bars are supported.
  bool isEdgeToEdgeAvailable() => _isEdgeToEdgeAvailableCache ?? false;
}
