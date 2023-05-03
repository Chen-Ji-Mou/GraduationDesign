import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
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
  late WebSocketChannel wsChannel;

  final PushStreamController controller = PushStreamController();
  final Completer<void> initialCompleter = Completer<void>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
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
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.9)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<bool>(
              future: checkInit(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == true) {
                    return buildContent();
                  } else {
                    return const _ErrorWidget();
                  }
                } else {
                  return const LoadingWidget();
                }
              },
            ),
            Positioned(
              left: 16,
              top: 12,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorName.redFF6FA2.withOpacity(0.35),
                  ),
                  child: Assets.images.arrowLeft.image(
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
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
              return _PushStreamControllerView(
                controller: controller,
                wsChannel: wsChannel,
                screenSize: screenSize,
                liveId: liveId,
              );
            } else {
              return const LoadingWidget();
            }
          },
        ),
      ],
    );
  }
}

class _PushStreamControllerView extends StatefulWidget {
  const _PushStreamControllerView({
    Key? key,
    required this.controller,
    required this.wsChannel,
    required this.screenSize,
    required this.liveId,
  }) : super(key: key);

  final PushStreamController controller;
  final WebSocketChannel wsChannel;
  final Size screenSize;
  final String liveId;

  @override
  State<StatefulWidget> createState() => _PushStreamControllerViewState();
}

class _PushStreamControllerViewState extends State<_PushStreamControllerView> {
  PushStreamController get controller => widget.controller;

  WebSocketChannel get wsChannel => widget.wsChannel;

  Size get screenSize => widget.screenSize;

  String get liveId => widget.liveId;

  bool pushStreaming = false;
  bool isBeauty = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 16,
          bottom: 72,
          child: ScrollBarrageWidget(
            screenSize: screenSize,
            wsChannel: wsChannel,
          ),
        ),
        Positioned(
          right: 16,
          top: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildIcon(
                icon: Assets.images.switchCamera.provider(),
                onTap: () => controller.switchCamera(),
              ),
              const C(12),
              buildIcon(
                icon: Assets.images.beautyIcon.provider(),
                onTap: () async {
                  if (isBeauty) {
                    bool result = await controller.removeBeauty();
                    isBeauty = !result;
                  } else {
                    isBeauty = await controller.addBeauty();
                  }
                },
              ),
              const C(12),
              buildIcon(
                icon: Assets.images.filterIcon.provider(),
                onTap: () => showBottomSheet(),
              ),
            ],
          ),
        ),
        Positioned(
          left: 60,
          right: 60,
          bottom: 20,
          child: buildButton(
            onTap: () => reportServer(
              pushStreaming ? Api.stopLive : Api.startLive,
              successCall: () async {
                pushStreaming
                    ? await controller.pause()
                    : await controller.resume();
                Fluttertoast.showToast(msg: pushStreaming ? '直播结束' : '直播开始');
                setState(() => pushStreaming = !pushStreaming);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildIcon({required ImageProvider icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorName.redFF6FA2.withOpacity(0.35),
        ),
        child: Image(
          image: icon,
          width: 24,
          height: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildButton({VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: pushStreaming ? Colors.red : null,
          gradient: !pushStreaming
              ? const LinearGradient(
                  colors: [ColorName.redEC008E, ColorName.redFC6767],
                )
              : null,
        ),
        child: Text(
          pushStreaming ? '停止推流' : '开始推流',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> reportServer(
    String url, {
    VoidCallback? successCall,
    VoidCallback? failCall,
  }) async {
    Response response = await DioClient.post(url, {'liveId': liveId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        successCall?.call();
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
        failCall?.call();
      }
    } else {
      Fluttertoast.showToast(msg: response.statusMessage ?? '');
    }
  }

  Future<bool?> showBottomSheet() async {
    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _BottomSheet(screenSize: screenSize, controller: controller),
    );
  }
}

class _BottomSheetItem {
  final Filter filterType;
  final ImageProvider icon;
  final String title;

  _BottomSheetItem(
      {required this.filterType, required this.icon, required this.title});
}

class _BottomSheet extends StatefulWidget {
  const _BottomSheet({
    Key? key,
    required this.screenSize,
    required this.controller,
  }) : super(key: key);

  final Size screenSize;
  final PushStreamController controller;

  @override
  State<StatefulWidget> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<_BottomSheet> {
  Size get screenSize => widget.screenSize;

  PushStreamController get controller => widget.controller;

  final List<_BottomSheetItem> items = [
    _BottomSheetItem(
      filterType: Filter.cancel,
      icon: Assets.images.filterDefault.provider(),
      title: '还原',
    ),
    _BottomSheetItem(
      filterType: Filter.bigEye,
      icon: Assets.images.filterDefault.provider(),
      title: '大眼滤镜',
    ),
    _BottomSheetItem(
      filterType: Filter.stick,
      icon: Assets.images.filterDefault.provider(),
      title: '兔耳滤镜',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenSize.width / 4 + 16,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Scrollbar(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => buildItem(items[index]),
          separatorBuilder: (context, index) => const C(10),
        ),
      ),
    );
  }

  Widget buildItem(_BottomSheetItem item) {
    return InkWell(
      onTap: () async {
        await controller.selectFilter(item.filterType);
        exit();
      },
      child: Container(
        width: screenSize.width / 4,
        height: screenSize.width / 4,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: item.icon,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
            const C(8),
            Text(
              item.title,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 14 / 13,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void exit() => Navigator.pop(context);
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '初始化失败，请退出重试',
        style: GoogleFonts.roboto(
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.bold,
          fontSize: 18,
          height: 1,
        ),
      ),
    );
  }
}
