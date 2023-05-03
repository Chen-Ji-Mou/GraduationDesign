import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/platform/file_load_platform.dart';
import 'package:graduationdesign/platform/permission_platform.dart';
import 'package:graduationdesign/widget/push_stream_widget.dart';

class StartRecordScreen extends StatefulWidget {
  const StartRecordScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StartRecordState();
}

class _StartRecordState extends State<StartRecordScreen> {
  late Size screenSize;
  late double buttonWidth;

  final PushStreamController controller = PushStreamController();
  final Completer<void> initialCompleter = Completer<void>();

  bool isRecording = false;
  DateTime? lastPressedTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
    buttonWidth = (screenSize.width - 32) / 3;
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
          ],
        ),
      ),
    );
    return WillPopScope(
      onWillPop: () async {
        if (isRecording &&
            (lastPressedTime == null ||
                DateTime.now().difference(lastPressedTime!) >
                    const Duration(milliseconds: 1000))) {
          Fluttertoast.showToast(msg: '当前正在录制，再次返回将会将会自动保存视频');
          lastPressedTime = DateTime.now();
          return false;
        }
        await controller.stopRecord();
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
          initialComplete: () => initialCompleter.complete(),
        ),
        FutureBuilder(
          future: initialCompleter.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return buildControlView();
            } else {
              return const LoadingWidget();
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
          width: buttonWidth,
          left: 8,
          bottom: 8,
          child: ElevatedButton(
            onPressed: () async => isRecording = await controller.startRecord(),
            child: const Text('开始录制'),
          ),
        ),
        Positioned(
          width: buttonWidth,
          left: buttonWidth + 16,
          bottom: 8,
          child: ElevatedButton(
            onPressed: stopRecord,
            child: const Text('停止录制'),
          ),
        ),
        Positioned(
          width: buttonWidth,
          right: 8,
          bottom: 8,
          child: ElevatedButton(
            onPressed: () => controller.switchCamera(),
            child: const Text('翻转摄像头'),
          ),
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
            ],
          ),
        ),
      ],
    );
  }

  Future<void> stopRecord() async {
    String? filePath = await controller.stopRecord();
    if (filePath != null) {
      bool isSend = await showAlert();
      if (isSend) {
        DioClient.post(Api.uploadVideo, {
          'file': await MultipartFile.fromFile(
            filePath,
            filename: filePath.substring(
              filePath.lastIndexOf("/"),
            ),
          ),
        }).then((response) {
          if (response.statusCode == 200 && response.data != null) {
            if (response.data['code'] == 200) {
              Fluttertoast.showToast(msg: '上传成功');
            } else {
              Fluttertoast.showToast(msg: response.data['msg']);
            }
          }
          exit(true);
        });
      } else {
        exit(true);
      }
    }
  }

  Future<bool> showAlert() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('录制完成'),
            content: const Text('已保存至系统相册，需要现在上传发布吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('是的'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('不了'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void exit([bool? result]) => Navigator.pop(context, result);
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
