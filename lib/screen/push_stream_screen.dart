import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduationdesign/platform/permission_platform.dart';
import 'package:graduationdesign/widget/barrage_widget.dart';
import 'package:graduationdesign/widget/push_stream_widget.dart';
import 'package:graduationdesign/utils.dart';

class PushStreamScreen extends StatefulWidget {
  const PushStreamScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PushStreamState();
}

class _PushStreamState extends State<PushStreamScreen> with LifecycleObserver {
  late Size screenSize;
  late double buttonWidth;
  late double barrageWidth;
  late double barrageHeight;

  final PushStreamController controller = PushStreamController();
  final Completer<void> initialCompleter = Completer<void>();
  bool pushStreaming = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initSize();
  }

  void initSize() {
    screenSize = MediaQuery.of(context).size;
    buttonWidth = (screenSize.width - 24) / 2;
    barrageWidth = screenSize.width * 3 / 5;
    barrageHeight = screenSize.height * 1 / 3;
  }

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
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Colors.black),
        child: FutureBuilder<bool?>(
          future: PermissionPlatform.requestPermission(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == true) {
                return buildContent();
              } else {
                Fluttertoast.showToast(msg: '请打开摄像头、录音和存储权限')
                    .then((_) => Navigator.pop(context));
                return const BlankPlaceholder();
              }
            } else {
              return const BlankPlaceholder();
            }
          },
        ),
      ),
    );
  }

  Widget buildContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        PushStreamWidget(
          controller: controller,
          initialComplete: () {
            controller.setRtmpUrl('rtmp://81.71.161.128:1935/live/1');
            initialCompleter.complete();
          },
        ),
        FutureBuilder(
          future: initialCompleter.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return buildControlView();
            } else {
              return const BlankPlaceholder();
            }
          },
        ),
      ],
    );
  }

  Widget buildControlView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 8,
          top: 8,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, size: 28, color: Colors.white),
          ),
        ),
        Positioned(
          left: 8,
          bottom: 58,
          child: BarrageWidget(
            width: barrageWidth,
            height: barrageHeight,
          ),
        ),
        Positioned(
          width: buttonWidth,
          left: 8,
          bottom: 8,
          child: ElevatedButton(
            onPressed: () => controller.switchCamera(),
            child: const Text('翻转摄像头'),
          ),
        ),
        Positioned(
          width: buttonWidth,
          right: 8,
          bottom: 8,
          child: _PushStreamButton(controller: controller),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: PopupMenuButton<Filter>(
            onSelected: (filter) => controller.selectFilter(filter),
            icon: const Icon(Icons.more_vert, size: 28, color: Colors.white),
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
              PopupMenuItem<Filter>(
                value: Filter.stick,
                child: Text('贴纸滤镜'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PushStreamButton extends StatefulWidget {
  const _PushStreamButton({Key? key, required this.controller})
      : super(key: key);

  final PushStreamController controller;

  @override
  State<StatefulWidget> createState() => _PushStreamButtonState();
}

class _PushStreamButtonState extends State<_PushStreamButton> {
  PushStreamController get controller => widget.controller;

  bool pushStreaming = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        pushStreaming ? await controller.pause() : await controller.resume();
        setState(() => pushStreaming = !pushStreaming);
      },
      child: Text(pushStreaming ? '停止推流' : '开始推流'),
    );
  }
}
