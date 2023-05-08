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
    width = screenSize.width * 170 / 375;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showInputBottomSheet,
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

  void showInputBottomSheet() {
    UserContext.checkLoginCallback(context, () {
      InputBottomSheet.show(
        context,
        screenSize: screenSize,
        onInputComplete: (content) => wsChannel.sink.add(mapToJsonString(
          Barrage(UserContext.name, content, null).toJsonMap(),
        )),
        builder: (inputController, onEditingComplete) {
          return Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
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
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ColorName.redF958A3.withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: inputController,
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
                InkWell(
                  onTap: onEditingComplete,
                  child: Assets.images.send.image(
                    width: 24,
                    height: 24,
                    color: ColorName.yellowFFB52D.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
