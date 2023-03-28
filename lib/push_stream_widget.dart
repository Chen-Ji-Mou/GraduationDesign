import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/utils.dart';

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
    Future.wait([
      channel.invokeMethod('setRtmpUrl', 'rtmp://81.71.161.128:1935/live/1'),
      channel
          .invokeMethod('resume')
          .then((_) => setState(() => pushStreaming = true))
    ]).then((_) => initialized = true);
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
      ],
    );
  }
}
