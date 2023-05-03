import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/api.dart';

enum Filter {
  cancel,
  vintageTV,
  wave,
  cartoon,
  profound,
  snow,
  oldPhoto,
  lamoish,
  money,
  waterRipple,
  bigEye,
  stick
}

class PushStreamController {
  static final MethodChannel _channel = const MethodChannel('pushStreamChannel')
    ..setMethodCallHandler(_onMethodCall);
  bool _initialized = false;

  Future<bool> setRtmpUrl(String url) async {
    if (_initialized) {
      return await _channel.invokeMethod<bool>('setRtmpUrl', url) ?? false;
    } else {
      return false;
    }
  }

  Future<bool> resume() async {
    if (_initialized) {
      return await _channel.invokeMethod<bool>('resume') ?? false;
    } else {
      return false;
    }
  }

  Future<bool> pause() async {
    if (_initialized) {
      return await _channel.invokeMethod<bool>('pause') ?? false;
    } else {
      return false;
    }
  }

  Future<bool> release() async {
    if (_initialized) {
      return await _channel.invokeMethod<bool>('release') ?? false;
    } else {
      return false;
    }
  }

  Future<bool> switchCamera() async {
    if (_initialized) {
      return await _channel.invokeMethod<bool>('switchCamera') ?? false;
    } else {
      return false;
    }
  }

  Future<bool> addBeauty() async {
    if (_initialized) {
      return await _channel.invokeMethod<bool>('addBeautyFilter') ?? false;
    } else {
      return false;
    }
  }

  Future<bool> removeBeauty() async {
    if (_initialized) {
      return await _channel.invokeMethod<bool>('removeBeautyFilter') ?? false;
    } else {
      return false;
    }
  }

  Future<bool> startRecord() async {
    if (_initialized) {
      return await _channel.invokeMethod<bool>('startRecord') ?? false;
    } else {
      return false;
    }
  }

  Future<String?> stopRecord() async {
    if (_initialized) {
      return await _channel.invokeMethod<String?>('stopRecord');
    } else {
      return null;
    }
  }

  Future<bool> selectFilter(Filter filter) async {
    if (_initialized) {
      switch (filter) {
        case Filter.cancel:
          return await _channel.invokeMethod<bool>('clearFilter') ?? false;
        case Filter.vintageTV:
          return await _channel.invokeMethod<bool>('addVintageTVFilter') ?? false;
        case Filter.wave:
          return await _channel.invokeMethod<bool>('addWaveFilter') ?? false;
        case Filter.cartoon:
          return await _channel.invokeMethod<bool>('addCartoonFilter') ?? false;
        case Filter.profound:
          return await _channel.invokeMethod<bool>('addProfoundFilter') ?? false;
        case Filter.snow:
          return await _channel.invokeMethod<bool>('addSnowFilter') ?? false;
        case Filter.oldPhoto:
          return await _channel.invokeMethod<bool>('addOldPhotoFilter') ?? false;
        case Filter.lamoish:
          return await _channel.invokeMethod<bool>('addLamoishFilter') ?? false;
        case Filter.money:
          return await _channel.invokeMethod<bool>('addMoneyFilter') ?? false;
        case Filter.waterRipple:
          return await _channel.invokeMethod<bool>('addWaterRippleFilter') ?? false;
        case Filter.bigEye:
          return await _channel.invokeMethod<bool>('addBigEyeFilter') ?? false;
        case Filter.stick:
          return await _channel.invokeMethod<bool>('addStickFilter') ?? false;
      }
    } else {
      return false;
    }
  }

  static Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'returnCameraSnapshotPath':
        String filePath = call.arguments as String;
        DioClient.post(Api.uploadCover, {
          'file': await MultipartFile.fromFile(
            filePath,
            filename: filePath.substring(
              filePath.lastIndexOf('/') + 1,
            ),
          ),
        }).then((response) {
          if (response.statusCode == 200 && response.data != null) {
            if (response.data['code'] == 200) {
              debugPrint(
                  '[PushStreamController] onMethodCall method: returnCameraSnapshotPath result: success');
            } else {
              debugPrint(
                  '[PushStreamController] onMethodCall method: returnCameraSnapshotPath result: fail msg: ${response.data['msg']}');
            }
          }
        });
        break;
    }
  }
}

class PushStreamWidget extends StatefulWidget {
  const PushStreamWidget({
    Key? key,
    required this.controller,
    this.initialComplete,
  }) : super(key: key);

  final PushStreamController controller;
  final VoidCallback? initialComplete;

  @override
  State<StatefulWidget> createState() => _PushStreamState();
}

class _PushStreamState extends State<PushStreamWidget> {
  PushStreamController get controller => widget.controller;

  VoidCallback? get initialComplete => widget.initialComplete;

  @override
  void dispose() {
    controller.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: 'pushStream',
      onPlatformViewCreated: (_) {
        controller._initialized = true;
        initialComplete?.call();
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
