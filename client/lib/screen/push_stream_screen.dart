import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/dialog/filter_bottom_sheet.dart';
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
  final Completer<void> initialCompleter = Completer<void>.sync();

  final ValueNotifier<bool> isLivingNotifier = ValueNotifier(false);
  DateTime? lastPressedTime;

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
    if (isLivingNotifier.value) {
      stopLive();
    }
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
    Widget child = Scaffold(
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
    return WillPopScope(
      onWillPop: () async {
        if (isLivingNotifier.value) {
          if (lastPressedTime == null ||
              DateTime.now().difference(lastPressedTime!) >
                  const Duration(milliseconds: 3000)) {
            Fluttertoast.showToast(msg: '当前正在直播，再次返回将会将会自动结束直播');
            lastPressedTime = DateTime.now();
            return false;
          }
          await stopLive();
          await controller.pause();
          Fluttertoast.showToast(msg: '直播结束');
        }
        return true;
      },
      child: child,
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
              return _ControllerView(
                controller: controller,
                wsChannel: wsChannel,
                screenSize: screenSize,
                liveId: liveId,
                isLivingNotifier: isLivingNotifier,
              );
            } else {
              return const LoadingWidget();
            }
          },
        ),
      ],
    );
  }

  Future<bool> stopLive() async {
    Response response = await DioClient.post(Api.stopLive, {'liveId': liveId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        return true;
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
        return false;
      }
    } else {
      return false;
    }
  }
}

class _ControllerView extends StatefulWidget {
  const _ControllerView({
    Key? key,
    required this.controller,
    required this.wsChannel,
    required this.screenSize,
    required this.liveId,
    required this.isLivingNotifier,
  }) : super(key: key);

  final PushStreamController controller;
  final WebSocketChannel wsChannel;
  final Size screenSize;
  final String liveId;
  final ValueNotifier<bool> isLivingNotifier;

  @override
  State<StatefulWidget> createState() => _ControllerViewState();
}

class _ControllerViewState extends State<_ControllerView> {
  PushStreamController get controller => widget.controller;

  WebSocketChannel get wsChannel => widget.wsChannel;

  Size get screenSize => widget.screenSize;

  String get liveId => widget.liveId;

  ValueNotifier<bool> get isLivingNotifier => widget.isLivingNotifier;

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
            width: screenSize.width * 2 / 3,
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
                onTap: () => FilterBottomSheet.show(
                  context,
                  screenSize: screenSize,
                  controller: controller,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 60,
          right: 60,
          bottom: 20,
          child: buildButton(
            onTap: () {
              reportServer(
                isLivingNotifier.value ? Api.stopLive : Api.startLive,
                successCall: () async {
                  isLivingNotifier.value
                      ? await controller.pause()
                      : await controller.resume();
                  Fluttertoast.showToast(
                      msg: isLivingNotifier.value ? '直播结束' : '直播开始');
                  setState(
                      () => isLivingNotifier.value = !isLivingNotifier.value);
                },
              );
            },
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
          color: isLivingNotifier.value ? Colors.red : null,
          gradient: !isLivingNotifier.value
              ? const LinearGradient(
                  colors: [ColorName.redEC008E, ColorName.redFC6767],
                )
              : null,
        ),
        child: Text(
          isLivingNotifier.value ? '停止推流' : '开始推流',
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
