import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/generate/colors.gen.dart';

class SendBarrageWidget extends StatefulWidget {
  const SendBarrageWidget({Key? key, required this.screenSize})
      : super(key: key);

  final Size screenSize;

  @override
  State<StatefulWidget> createState() => _SendBarrageState();
}

class _SendBarrageState extends State<SendBarrageWidget> {
  Size get screenSize => widget.screenSize;

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
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.only(left: 24),
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27.5),
          border:
              Border.all(color: ColorName.f958a3.withOpacity(0.8), width: 3),
        ),
        child: Text(
          '发送弹幕',
          style: GoogleFonts.roboto(
            color: ColorName.ff6fa2.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            height: 16 / 14,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
