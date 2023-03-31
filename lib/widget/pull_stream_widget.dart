import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/utils.dart';

class PullStreamWidget extends StatefulWidget {
  const PullStreamWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PullStreamState();
}

class _PullStreamState extends State<PullStreamWidget> with LifecycleObserver {
  static const MethodChannel channel = MethodChannel('pullStreamChannel');

  bool initialized = false;
  bool pullStreaming = false;

  void init() {
    Future.wait([
      channel.invokeMethod('setRtmpUrl', 'rtmp://81.71.161.128:1935/live/1'),
      channel
          .invokeMethod('resume')
          .then((_) => setState(() => pullStreaming = true))
    ]).then((_) => initialized = true);
  }

  @override
  void onResume() {
    if (initialized) {
      channel
          .invokeMethod('resume')
          .then((_) => setState(() => pullStreaming = true));
    }
  }

  @override
  void onPause() {
    if (initialized) {
      channel
          .invokeMethod('pause')
          .then((_) => setState(() => pullStreaming = false));
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
    return Stack(
      fit: StackFit.expand,
      children: [
        AndroidView(
          viewType: 'pullStream',
          onPlatformViewCreated: (_) => init(),
          creationParamsCodec: const StandardMessageCodec(),
        ),
        Positioned(
          left: 8,
          right: 8,
          bottom: 8,
          child: ElevatedButton(
            onPressed: () => channel
                .invokeMethod(pullStreaming ? 'pause' : 'resume')
                .then((_) => setState(() => pullStreaming = !pullStreaming)),
            child: Text(pullStreaming ? '停止拉流' : '开始拉流'),
          ),
        ),
      ],
    );
  }
}
