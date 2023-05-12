import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/dialog/filter_bottom_sheet.dart';
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

  final PushStreamController controller = PushStreamController();
  final Completer<void> initialCompleter = Completer<void>();

  bool isRecording = false;
  DateTime? lastPressedTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
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
        if (isRecording) {
          if (lastPressedTime == null ||
              DateTime.now().difference(lastPressedTime!) >
                  const Duration(milliseconds: 3000)) {
            Fluttertoast.showToast(msg: '当前正在录制，再次返回将会将会自动保存视频');
            lastPressedTime = DateTime.now();
            return false;
          }
          String? filePath = await controller.stopRecord();
          String? fileName = filePath?.substring(filePath.lastIndexOf("/") + 1);
          Fluttertoast.showToast(msg: '视频保存成功 $fileName');
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
          initialComplete: () => initialCompleter.complete(),
        ),
        FutureBuilder(
          future: initialCompleter.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return _ControllerView(
                controller: controller,
                screenSize: screenSize,
                recordCall: (isRecording) => this.isRecording = isRecording,
                exitCall: exit,
              );
            } else {
              return const LoadingWidget();
            }
          },
        ),
      ],
    );
  }

  void exit([bool? result]) => Navigator.pop(context, result);
}

class _ControllerView extends StatefulWidget {
  const _ControllerView({
    Key? key,
    required this.controller,
    required this.screenSize,
    required this.recordCall,
    required this.exitCall,
  }) : super(key: key);

  final PushStreamController controller;
  final Size screenSize;
  final void Function(bool isRecording) recordCall;
  final void Function([bool? result]) exitCall;

  @override
  State<StatefulWidget> createState() => _ControllerViewState();
}

class _ControllerViewState extends State<_ControllerView> {
  PushStreamController get controller => widget.controller;

  Size get screenSize => widget.screenSize;

  bool isRecording = false;
  bool isBeauty = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          right: 16,
          bottom: 192,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  isRecord: true,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 48,
          child: SizedBox(
            width: screenSize.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: isRecording ? stopRecord : startRecord,
                      child: Image(
                        image: isRecording
                            ? Assets.images.stopRecord.provider()
                            : Assets.images.startRecord.provider(),
                        width: 80,
                        height: 80,
                        color: isRecording ? Colors.red : ColorName.redFF6FA2,
                      ),
                    ),
                  ),
                ),
                C(screenSize.width / 2 - 114),
                buildIcon(
                  icon: Assets.images.switchCamera.provider(),
                  onTap: () => controller.switchCamera(),
                ),
                const C(32),
              ],
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

  Future<void> startRecord() async {
    isRecording = await controller.startRecord();
    if (mounted) {
      setState(() => widget.recordCall.call(isRecording));
    }
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
              filePath.lastIndexOf("/") + 1,
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
          widget.exitCall.call(true);
        });
      } else {
        widget.exitCall.call(true);
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
