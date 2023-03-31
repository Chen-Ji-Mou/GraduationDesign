import 'package:flutter/services.dart';

class InitialPlatform {
  static const MethodChannel _channel = MethodChannel('initial');

  static Future<bool?> initial() async {
    return await _channel.invokeMethod<bool?>("initial");
  }
}