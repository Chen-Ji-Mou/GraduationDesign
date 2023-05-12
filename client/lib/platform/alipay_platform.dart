import 'package:flutter/services.dart';

class AlipayPlatform {
  static const MethodChannel _channel = MethodChannel('alipay');

  static Future<bool> payV2(double price) async {
    return await _channel.invokeMethod<bool>('payV2', price) ?? false;
  }
}
