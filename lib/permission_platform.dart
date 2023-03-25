import 'package:flutter/services.dart';

class PermissionPlatform {
  static const String _channelName = 'permission';
  static const MethodChannel _channel = MethodChannel(_channelName);

  static Future<bool?> requestPushStreamPermission() async {
    return await _channel.invokeMethod<bool?>("requestPushStreamPermission");
  }
}