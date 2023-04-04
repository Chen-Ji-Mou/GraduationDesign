import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/utils.dart';
import 'package:graduationdesign/widget/scroll_barrage_widget.dart';
import 'package:graduationdesign/widget/pull_stream_widget.dart';
import 'package:graduationdesign/widget/send_barrage_widget.dart';

class PullStreamScreen extends StatefulWidget {
  const PullStreamScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PullStreamState();
}

class _PullStreamState extends State<PullStreamScreen> {
  late Size screenSize;

  final PullStreamController controller = PullStreamController();
  final Completer<void> initialCompleter = Completer<void>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          toolbarHeight: 1,
          backgroundColor: Colors.black.withOpacity(0.8),
          brightness: Brightness.dark),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.8)),
          child: buildContent(),
        ),
      ),
    );
  }

  Widget buildContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        PullStreamWidget(
          controller: controller,
          initialComplete: () async {
            await controller.setRtmpUrl('rtmp://81.71.161.128:1935/live/1');
            await controller.resume();
            initialCompleter.complete();
          },
        ),
        FutureBuilder(
          future: initialCompleter.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return buildControlView();
            } else {
              return const C(0);
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
                color: ColorName.ff6fa2.withOpacity(0.35),
                borderRadius: BorderRadius.circular(21),
              ),
              child: Assets.images.arrowLeft.image(width: 24, height: 24),
            ),
          ),
        ),
        Positioned(
          left: 21,
          bottom: 86,
          child: ScrollBarrageWidget(screenSize: screenSize),
        ),
        Positioned(
          left: 21,
          bottom: 22,
          child: GestureDetector(
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: ColorName.f958a3,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Assets.images.giftBox.image(width: 44, height: 44),
            ),
          ),
        ),
        Positioned(
          left: 90,
          bottom: 20,
          child: SendBarrageWidget(screenSize: screenSize),
        ),
        Positioned(
          right: 21,
          bottom: 27,
          child: GestureDetector(
            child: Assets.images.heart.image(width: 37, height: 37),
          ),
        ),
      ],
    );
  }
}
