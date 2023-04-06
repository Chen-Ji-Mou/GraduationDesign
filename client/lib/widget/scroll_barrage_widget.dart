import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/mixin/lifecycle_observer.dart';
import 'package:graduationdesign/models.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ScrollBarrageWidget extends StatefulWidget {
  const ScrollBarrageWidget({
    Key? key,
    required this.screenSize,
    required this.wsChannel,
  }) : super(key: key);

  final Size screenSize;
  final WebSocketChannel wsChannel;

  @override
  State<StatefulWidget> createState() => _ScrollBarrageState();
}

class _ScrollBarrageState extends State<ScrollBarrageWidget>
    with LifecycleObserver {
  Size get screenSize => widget.screenSize;

  WebSocketChannel get wsChannel => widget.wsChannel;

  final double itemMaxHeight = 26;

  late Timer timer;
  late ItemScrollController scrollController;
  late double barrageWidth;
  late double barrageHeight;
  late StreamSubscription wsSubscription;
  int curIndex = 0;
  List<Barrage> barrages = [];

  @override
  void initState() {
    super.initState();
    scrollController = ItemScrollController();
    timer = Timer.periodic(
        const Duration(milliseconds: 600), (_) => scrollScheduleTask());

    barrageWidth = screenSize.width * 2 / 3;
    barrageHeight = itemMaxHeight * 8; // 最多同时展示8条弹幕

    wsSubscription =
        wsChannel.stream.listen((jsonStr) => receiveBarrage(jsonStr));
  }

  @override
  void onResume() {
    wsSubscription.resume();
  }

  @override
  void onPause() {
    wsSubscription.pause();
  }

  @override
  void dispose() {
    timer.cancel();
    wsSubscription.cancel();
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
    Barrage barrage = barrages[index != -1 ? index : 0];
    return GestureDetector(
      child: Container(
        constraints: BoxConstraints(maxHeight: itemMaxHeight),
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text.rich(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          TextSpan(children: [
            TextSpan(
              text: '${barrage.userName} : ',
              style: GoogleFonts.roboto(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
                height: 16 / 14,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: barrage.content,
              style: GoogleFonts.roboto(
                color: ColorName.ffb52d.withOpacity(0.8),
                fontWeight: FontWeight.w400,
                height: 16 / 14,
                fontSize: 14,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void scrollScheduleTask() {
    if (curIndex < barrages.length - 1) {
      scrollController.scrollTo(
        index: ++curIndex,
        duration: const Duration(milliseconds: 400),
      );
    }
  }

  void receiveBarrage(String jsonStr) {
    if (mounted) {
      setState(() {
        barrages.add(Barrage.fromJsonMap(jsonDecode(jsonStr)));
      });
    }
  }
}
