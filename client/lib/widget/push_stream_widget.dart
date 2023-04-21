import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/mixin/lifecycle_observer.dart';

enum Filter {
  cancel,
  vintageTV,
  wave,
  beauty,
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

  Future<void> setRtmpUrl(String url) async {
    if (_initialized) {
      await _channel.invokeMethod('setRtmpUrl', url);
    }
  }

  Future<void> resume() async {
    if (_initialized) {
      await _channel.invokeMethod('resume');
    }
  }

  Future<void> pause() async {
    if (_initialized) {
      await _channel.invokeMethod('pause');
    }
  }

  Future<void> release() async {
    if (_initialized) {
      await _channel.invokeMethod('release');
    }
  }

  Future<void> switchCamera() async {
    if (_initialized) {
      await _channel.invokeMethod('switchCamera');
    }
  }

  Future<bool?> startRecord() async {
    if (_initialized) {
      return await _channel.invokeMethod<bool>('startRecord');
    }
    return null;
  }

  Future<String?> stopRecord() async {
    if (_initialized) {
      return await _channel.invokeMethod<String?>('stopRecord');
    }
    return null;
  }

  Future<void> selectFilter(Filter filter) async {
    if (_initialized) {
      switch (filter) {
        case Filter.cancel:
          await _channel.invokeMethod('cancelFilter');
          break;
        case Filter.vintageTV:
          await _channel.invokeMethod('addVintageTVFilter');
          break;
        case Filter.wave:
          await _channel.invokeMethod('addWaveFilter');
          break;
        case Filter.beauty:
          await _channel.invokeMethod('addBeautyFilter');
          break;
        case Filter.cartoon:
          await _channel.invokeMethod('addCartoonFilter');
          break;
        case Filter.profound:
          await _channel.invokeMethod('addProfoundFilter');
          break;
        case Filter.snow:
          await _channel.invokeMethod('addSnowFilter');
          break;
        case Filter.oldPhoto:
          await _channel.invokeMethod('addOldPhotoFilter');
          break;
        case Filter.lamoish:
          await _channel.invokeMethod('addLamoishFilter');
          break;
        case Filter.money:
          await _channel.invokeMethod('addMoneyFilter');
          break;
        case Filter.waterRipple:
          await _channel.invokeMethod('addWaterRippleFilter');
          break;
        case Filter.bigEye:
          await _channel.invokeMethod('addBigEyeFilter');
          break;
        case Filter.stick:
          await _channel.invokeMethod('addStickFilter');
          break;
      }
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
    this.autoPushStream = true,
    this.initialComplete,
  }) : super(key: key);

  final PushStreamController controller;
  final bool autoPushStream;
  final VoidCallback? initialComplete;

  @override
  State<StatefulWidget> createState() => _PushStreamState();
}

class _PushStreamState extends State<PushStreamWidget> with LifecycleObserver {
  PushStreamController get controller => widget.controller;

  bool get autoPushStream => widget.autoPushStream;

  VoidCallback? get initialComplete => widget.initialComplete;

  @override
  void onResume() {
    if (autoPushStream) {
      controller.resume();
    }
  }

  @override
  void onPause() {
    if (autoPushStream) {
      controller.pause();
    }
  }

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
