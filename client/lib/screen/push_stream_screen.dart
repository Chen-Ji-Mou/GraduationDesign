import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/platform/file_load_platform.dart';
import 'package:graduationdesign/platform/permission_platform.dart';
import 'package:graduationdesign/widget/scroll_barrage_widget.dart';
import 'package:graduationdesign/widget/push_stream_widget.dart';
import 'package:graduationdesign/common.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PushStreamScreen extends StatefulWidget {
  const PushStreamScreen({
    Key? key,
    required this.liveId,
  }) : super(key: key);

  final String liveId;

  @override
  State<StatefulWidget> createState() => _PushStreamState();
}

class _PushStreamState extends State<PushStreamScreen> {
  String get liveId => widget.liveId;

  late Size screenSize;
  late double buttonWidth;
  late WebSocketChannel wsChannel;

  final PushStreamController controller = PushStreamController();
  final Completer<void> initialCompleter = Completer<void>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
    buttonWidth = (screenSize.width - 24) / 2;
  }

  @override
  void initState() {
    super.initState();
    wsChannel = WebSocketChannel.connect(
        Uri.parse('ws://81.71.161.128:8088/websocket?lid=$liveId'));
  }

  @override
  void dispose() {
    wsChannel.sink.close();
    super.dispose();
  }

  Future<bool> checkInit() async {
    if (requestPermissionSuccess && loadFileSuccess) {
      return true;
    }
    requestPermissionSuccess = await PermissionPlatform.requestPermission();
    loadFileSuccess = await FileLoadPlatform.loadFile();
    return requestPermissionSuccess && loadFileSuccess;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: toolbarHeight),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.8)),
        child: FutureBuilder<bool>(
          future: checkInit(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return buildContent();
            } else {
              return const C(0);
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
          initialComplete: () async {
            await controller
                .setRtmpUrl('rtmp://81.71.161.128:1935/live/$liveId');
            initialCompleter.complete();
          },
        ),
        FutureBuilder(
          future: initialCompleter.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return buildControlView();
            } else {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const C(8),
                    Text(
                      '加载中请稍后...',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
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
          left: 16,
          top: 12,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: ColorName.redFF6FA2.withOpacity(0.35),
                borderRadius: BorderRadius.circular(21),
              ),
              child: Assets.images.arrowLeft.image(
                width: 24,
                height: 24,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ),
        Positioned(
          left: 8,
          bottom: 58,
          child:
              ScrollBarrageWidget(screenSize: screenSize, wsChannel: wsChannel),
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
            icon: Icon(Icons.more_vert,
                size: 24, color: Colors.white.withOpacity(0.8)),
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
