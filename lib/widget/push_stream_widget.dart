import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/utils.dart';

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
  bigEye
}

class PushStreamWidget extends StatefulWidget {
  const PushStreamWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PushStreamState();
}

class _PushStreamState extends State<PushStreamWidget> with LifecycleObserver {
  static const MethodChannel channel = MethodChannel('pushStreamChannel');

  bool initialized = false;
  bool pushStreaming = false;
  bool recording = false;

  void init() {
    channel
        .invokeMethod('setRtmpUrl', 'rtmp://81.71.161.128:1935/live/1')
        .then((_) => initialized = true);
  }

  @override
  void onResume() {
    if (initialized) {
      channel
          .invokeMethod('resume')
          .then((_) => setState(() => pushStreaming = true));
    }
  }

  @override
  void onPause() {
    if (initialized) {
      channel
          .invokeMethod('pause')
          .then((_) => setState(() => pushStreaming = false));
    }
  }

  @override
  void dispose() {
    if (initialized) {
      channel.invokeMethod('release');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double buttonWidth = (MediaQuery.of(context).size.width - 32) / 3;
    return Stack(
      fit: StackFit.expand,
      children: [
        AndroidView(
          viewType: 'pushStream',
          onPlatformViewCreated: (_) => init(),
          creationParamsCodec: const StandardMessageCodec(),
        ),
        Positioned(
          width: buttonWidth,
          left: 8,
          bottom: 8,
          child: ElevatedButton(
            onPressed: () => channel
                .invokeMethod(pushStreaming ? 'pause' : 'resume')
                .then((_) => setState(() => pushStreaming = !pushStreaming)),
            child: Text(pushStreaming ? '停止推流' : '开始推流'),
          ),
        ),
        Positioned(
          width: buttonWidth,
          left: 16 + buttonWidth,
          bottom: 8,
          child: ElevatedButton(
            onPressed: () => channel.invokeMethod('switchCamera'),
            child: const Text('翻转摄像头'),
          ),
        ),
        Positioned(
          width: buttonWidth,
          right: 8,
          bottom: 8,
          child: ElevatedButton(
            onPressed: () => channel
                .invokeMethod(recording ? 'stopRecord' : 'startRecord')
                .then((_) => setState(() => recording = !recording)),
            child: Text(recording ? '停止录制' : '开始录制'),
          ),
        ),
        Positioned(
          width: 32,
          height: 32,
          top: 8,
          right: 8,
          child: PopupMenuButton<Filter>(
            onSelected: popupMenuSelect,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem<Filter>(
                value: Filter.cancel,
                child: Text('取消滤镜'),
              ),
              PopupMenuItem<Filter>(
                value: Filter.vintageTV,
                child: Text('老式电视滤镜'),
              ),
              PopupMenuItem<Filter>(
                value: Filter.wave,
                child: Text('波浪滤镜'),
              ),
              PopupMenuItem<Filter>(
                value: Filter.beauty,
                child: Text('美颜滤镜'),
              ),
              PopupMenuItem<Filter>(
                value: Filter.cartoon,
                child: Text('卡通滤镜'),
              ),
              PopupMenuItem<Filter>(
                value: Filter.profound,
                child: Text('深邃滤镜'),
              ),
              PopupMenuItem<Filter>(
                value: Filter.snow,
                child: Text('雪花滤镜'),
              ),
              PopupMenuItem<Filter>(
                value: Filter.oldPhoto,
                child: Text('老式相片滤镜'),
              ),
              PopupMenuItem<Filter>(
                value: Filter.lamoish,
                child: Text('Lamoish滤镜'),
              ),
              PopupMenuItem<Filter>(
                value: Filter.money,
                child: Text('美元花纹滤镜'),
              ),
              PopupMenuItem<Filter>(
                value: Filter.waterRipple,
                child: Text('水波纹滤镜'),
              ),
              PopupMenuItem<Filter>(
                value: Filter.bigEye,
                child: Text('大眼滤镜'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void popupMenuSelect(Filter filter) {
    switch (filter) {
      case Filter.cancel:
        channel.invokeMethod('cancelFilter');
        break;
      case Filter.vintageTV:
        channel.invokeMethod('addVintageTVFilter');
        break;
      case Filter.wave:
        channel.invokeMethod('addWaveFilter');
        break;
      case Filter.beauty:
        channel.invokeMethod('addBeautyFilter');
        break;
      case Filter.cartoon:
        channel.invokeMethod('addCartoonFilter');
        break;
      case Filter.profound:
        channel.invokeMethod('addProfoundFilter');
        break;
      case Filter.snow:
        channel.invokeMethod('addSnowFilter');
        break;
      case Filter.oldPhoto:
        channel.invokeMethod('addOldPhotoFilter');
        break;
      case Filter.lamoish:
        channel.invokeMethod('addLamoishFilter');
        break;
      case Filter.money:
        channel.invokeMethod('addMoneyFilter');
        break;
      case Filter.waterRipple:
        channel.invokeMethod('addWaterRippleFilter');
        break;
      case Filter.bigEye:
        channel.invokeMethod('addBigEyeFilter');
        break;
    }
  }
}
