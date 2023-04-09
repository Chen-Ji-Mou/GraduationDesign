import 'package:flutter/services.dart';

bool loadFileSuccess = false;

class FileLoadPlatform {
  static const MethodChannel _channel = MethodChannel('fileLoad');

  static Future<bool> loadFile() async {
    return await _channel.invokeMethod<bool>("loadFile") ?? false;
  }
}