import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/common.dart';
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
      child: ScrollConfiguration(
        behavior: NoBoundaryRippleBehavior(),
        child: ScrollablePositionedList.builder(
          itemScrollController: scrollController,
          itemCount: barrages.length,
          itemBuilder: (context, index) => item(index),
          physics: const NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }

  Widget item(int index) {
    Barrage barrage = barrages[index != -1 ? index : 0];
    bool isGift = barrage.gift != null;
    return GestureDetector(
      child: Container(
        constraints: BoxConstraints(maxHeight: itemMaxHeight),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(top: 5),
        decoration: BoxDecoration(
          color: isGift
              ? Color(barrage.gift?.backgroundColor ?? 0x000000)
                  .withOpacity(0.9)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: barrageWidth / 3),
              child: Text(
                '${barrage.userName} : ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                  height: 16 / 14,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: barrageWidth * 2 / 3),
              child: isGift
                  ? Text.rich(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '送出一个',
                            style: GoogleFonts.roboto(
                              color: ColorName.yellowFFB52D.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                              height: 16 / 14,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: barrage.gift?.name,
                            style: GoogleFonts.roboto(
                              color: Color(barrage.gift?.titleColor ?? 0x000000)
                                  .withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                              height: 16 / 14,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ))
                  : Text(
                      barrage.content ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        color: ColorName.yellowFFB52D.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                        height: 16 / 14,
                        fontSize: 14,
                      ),
                    ),
            ),
          ],
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
