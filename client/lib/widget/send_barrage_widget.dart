import 'dart:core';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/models.dart';
import 'package:graduationdesign/user_context.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SendBarrageWidget extends StatefulWidget {
  const SendBarrageWidget({
    Key? key,
    required this.screenSize,
    required this.wsChannel,
  }) : super(key: key);

  final Size screenSize;
  final WebSocketChannel wsChannel;

  @override
  State<StatefulWidget> createState() => _SendBarrageState();
}

class _SendBarrageState extends State<SendBarrageWidget> {
  Size get screenSize => widget.screenSize;

  WebSocketChannel get wsChannel => widget.wsChannel;

  late double width;
  final double height = 50;

  @override
  void initState() {
    super.initState();
    width = screenSize.width * 197 / 375;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _InputBottomSheet.show(
        context,
        screenSize,
        onInputComplete: (content) => wsChannel.sink.add(mapToJsonString(
          Barrage(UserContext.name, content).toJsonMap(),
        )),
      ),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.only(left: 24),
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27.5),
          border: Border.all(
            color: ColorName.redF958A3.withOpacity(0.8),
            width: 3,
          ),
        ),
        child: Text(
          '发送弹幕',
          style: GoogleFonts.roboto(
            color: ColorName.redFF6FA2.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            height: 16 / 14,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _InputBottomSheet extends StatefulWidget {
  const _InputBottomSheet(this.screenSize, {required this.onInputComplete});

  final ValueChanged<String> onInputComplete;
  final Size screenSize;

  static Future<void> show(
    BuildContext context,
    Size screenSize, {
    required ValueChanged<String> onInputComplete,
  }) async {
    await Navigator.push(
      context,
      _BottomPopupRoute(
        child: _InputBottomSheet(screenSize, onInputComplete: onInputComplete),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _InputBottomState();
}

class _InputBottomState extends State<_InputBottomSheet> {
  ValueChanged<String> get onInputComplete => widget.onInputComplete;

  Size get screenSize => widget.screenSize;

  final double height = 40;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
          ),
          Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(height / 2),
                topRight: Radius.circular(height / 2),
              ),
            ),
            child: Row(
              children: [
                const C(10),
                Container(
                  width: screenSize.width * 0.8,
                  padding: const EdgeInsets.only(left: 16),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(height / 2),
                    border: Border.all(
                      color: ColorName.redF958A3.withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    maxLines: 1,
                    style: GoogleFonts.roboto(
                      color: ColorName.redFF6FA2.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                      height: 16 / 14,
                      fontSize: 14,
                    ),
                    textInputAction: TextInputAction.send,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '请输入弹幕内容',
                      hintStyle: GoogleFonts.roboto(
                        color: ColorName.redFF6FA2.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                        height: 16 / 14,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const C(12),
                GestureDetector(
                  onTap: onEditingComplete,
                  child: Assets.images.send.image(
                    width: 24,
                    height: 24,
                    color: ColorName.yellowFFB52D.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onEditingComplete() {
    onInputComplete.call(controller.text);
    Navigator.pop(context);
  }
}

class _BottomPopupRoute extends PopupRoute {
  _BottomPopupRoute({required this.child});

  final Duration _duration = const Duration(milliseconds: 300);
  Widget child;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Duration get transitionDuration => _duration;
}
