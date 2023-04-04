import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ScrollBarrageWidget extends StatefulWidget {
  const ScrollBarrageWidget({Key? key, required this.screenSize})
      : super(key: key);

  final Size screenSize;

  @override
  State<StatefulWidget> createState() => _ScrollBarrageState();
}

class _ScrollBarrageState extends State<ScrollBarrageWidget> {
  Size get screenSize => widget.screenSize;

  final double itemMaxHeight = 26;

  late Timer timer;
  late ItemScrollController scrollController;
  late double barrageWidth;
  late double barrageHeight;
  int curIndex = 0;
  List<String> barrages = [];

  @override
  void initState() {
    super.initState();
    scrollController = ItemScrollController();
    timer = Timer.periodic(
        const Duration(milliseconds: 600), (_) => scrollScheduleTask());
    barrageWidth = screenSize.width * 2 / 3;
    barrageHeight = itemMaxHeight * 8; // 最多同时展示8条弹幕
    generateSomeBarrageForTest();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: barrageWidth,
      height: barrageHeight,
      alignment: Alignment.center,
      child: ScrollablePositionedList.builder(
        itemScrollController: scrollController,
        itemCount: barrages.length,
        itemBuilder: (context, index) => item(index),
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget item(int index) {
    return GestureDetector(
      child: Container(
        constraints: BoxConstraints(maxHeight: itemMaxHeight),
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          barrages[index != -1 ? index : 0],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.roboto(
            color: ColorName.ffb52d.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            height: 16 / 14,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// 添加弹幕用于测试
  void generateSomeBarrageForTest() {
    StringBuffer stringBuffer = StringBuffer();
    for (int i = 0; i < 100; i++) {
      stringBuffer.clear();
      int random = Random().nextInt(300);
      int times = Random().nextInt(30);
      for (int j = 1; j <= times; j++) {
        stringBuffer.write(random);
      }
      barrages.add(stringBuffer.toString());
    }
    if (mounted) setState(() {});
  }

  void scrollScheduleTask() {
    if (curIndex < barrages.length - 1 && mounted) {
      setState(() {
        scrollController.scrollTo(
          index: ++curIndex,
          duration: const Duration(milliseconds: 400),
        );
      });
    }
  }
}
