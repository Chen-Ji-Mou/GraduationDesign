import 'package:flutter/services.dart';

bool requestPermissionSuccess = false;

class PermissionPlatform {
  static const MethodChannel _channel = MethodChannel('permission');

  static Future<bool> requestPermission() async {
    return await _channel.invokeMethod<bool>("requestPermission") ?? false;
  }
}