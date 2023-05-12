import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/mixin/lifecycle_observer.dart';

class PullStreamController {
  static const MethodChannel _channel = MethodChannel('pullStreamChannel');
  bool _initialized = false;

  Future<bool> setRtmpUrl(String url) async {
    if (_initialized) {
      return await _channel.invokeMethod<bool>('setRtmpUrl', url) ?? false;
    } else {
      return false;
    }
  }

  Future<bool> setFillXY(bool fillXY) async {
    if (_initialized) {
      return await _channel.invokeMethod<bool>('setFillXY', fillXY) ?? false;
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
}

class PullStreamWidget extends StatefulWidget {
  const PullStreamWidget({
    Key? key,
    required this.controller,
    this.initialComplete,
  }) : super(key: key);

  final PullStreamController controller;
  final VoidCallback? initialComplete;

  @override
  State<StatefulWidget> createState() => _PullStreamState();
}

class _PullStreamState extends State<PullStreamWidget> {
  PullStreamController get controller => widget.controller;

  VoidCallback? get initialComplete => widget.initialComplete;

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
