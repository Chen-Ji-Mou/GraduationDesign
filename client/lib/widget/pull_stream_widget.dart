import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/mixin/lifecycle_observer.dart';

class PullStreamController {
  static const MethodChannel _channel = MethodChannel('pullStreamChannel');
  bool _initialized = false;

  Future<void> setRtmpUrl(String url) async {
    if (_initialized) {
      await _channel.invokeMethod('setRtmpUrl', url);
    }
  }

  Future<void> setFillXY(bool fillXY) async {
    if (_initialized) {
      await _channel.invokeMethod('setFillXY', fillXY);
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
}

class PullStreamWidget extends StatefulWidget {
  const PullStreamWidget(
      {Key? key, required this.controller, this.initialComplete})
      : super(key: key);

  final PullStreamController controller;
  final VoidCallback? initialComplete;

  @override
  State<StatefulWidget> createState() => _PullStreamState();
}

class _PullStreamState extends State<PullStreamWidget> with LifecycleObserver {
  PullStreamController get controller => widget.controller;

  VoidCallback? get initialComplete => widget.initialComplete;

  @override
  void onResume() {
    controller.resume();
  }

  @override
  void onPause() {
    controller.pause();
  }

  @override
  void dispose() {
    controller.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: 'pullStream',
      onPlatformViewCreated: (_) {
        controller._initialized = true;
        initialComplete?.call();
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
