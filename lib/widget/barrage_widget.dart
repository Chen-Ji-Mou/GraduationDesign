import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class BarrageWidget extends StatefulWidget {
  const BarrageWidget({Key? key, required this.width, required this.height})
      : super(key: key);

  final double width;
  final double height;

  @override
  State<StatefulWidget> createState() => _BarrageState();
}

class _BarrageState extends State<BarrageWidget> {
  double get width => widget.width;

  double get height => widget.height;

  late Timer timer;
  late ItemScrollController scrollController;
  late ItemPositionsListener positionsListener;
  int curIndex = 0;
  int curVisibleLastIndex = 0;
  List<String> barrages = [];

  @override
  void initState() {
    super.initState();
    scrollController = ItemScrollController();
    positionsListener = ItemPositionsListener.create();
    timer = Timer.periodic(
        const Duration(milliseconds: 600), (_) => scrollScheduleTask());
    positionsListener.itemPositions.addListener(itemPositionNotify);
    generateSomeBarrageForTest();
  }

  @override
  void dispose() {
    timer.cancel();
    positionsListener.itemPositions.removeListener(itemPositionNotify);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ScrollablePositionedList.builder(
        itemScrollController: scrollController,
        itemPositionsListener: positionsListener,
        itemCount: barrages.length,
        itemBuilder: (context, index) => item(index),
        shrinkWrap: true,
      ),
    );
  }

  Widget item(int index) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(
            left: 4, right: 4, bottom: index == barrages.length - 1 ? 0 : 4),
        padding: const EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          barrages[index != -1 ? index : 0],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white
                .withOpacity(index == curVisibleLastIndex ? 0.8 : 0.3),
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
      for (int j = 0; j < times; j++) {
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

  void itemPositionNotify() {
    List<ItemPosition> itemPositions =
        positionsListener.itemPositions.value.toList();
    if (mounted) {
      setState(() => curVisibleLastIndex = itemPositions.last.index);
    }
  }
}
