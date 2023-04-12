import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/widget/scroll_barrage_widget.dart';
import 'package:graduationdesign/widget/pull_stream_widget.dart';
import 'package:graduationdesign/widget/send_barrage_widget.dart';
import 'package:like_button/like_button.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PullStreamScreen extends StatefulWidget {
  const PullStreamScreen({
    Key? key,
    required this.liveId,
  }) : super(key: key);

  final int liveId;

  @override
  State<StatefulWidget> createState() => _PullStreamState();
}

class _PullStreamState extends State<PullStreamScreen> {
  int get liveId => widget.liveId;

  late Size screenSize;
  late WebSocketChannel wsChannel;

  final PullStreamController controller = PullStreamController();
  final Completer<void> initialCompleter = Completer<void>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void initState() {
    super.initState();
    wsChannel = WebSocketChannel.connect(
        Uri.parse('ws://81.71.161.128:8088/websocket?lid=$liveId'));
  }

  @override
  void dispose() {
    wsChannel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: toolbarHeight),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.8)),
        child: buildContent(),
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
            await controller
                .setRtmpUrl('rtmp://81.71.161.128:1935/live/$liveId');
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
              child: Assets.images.arrowLeft.image(width: 24, height: 24),
            ),
          ),
        ),
        Positioned(
          left: 21,
          bottom: 86,
          child:
              ScrollBarrageWidget(screenSize: screenSize, wsChannel: wsChannel),
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
                color: ColorName.redF958A3,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Assets.images.giftBox.image(width: 44, height: 44),
            ),
          ),
        ),
        Positioned(
          left: 90,
          bottom: 20,
          child:
              SendBarrageWidget(screenSize: screenSize, wsChannel: wsChannel),
        ),
        Positioned(
          right: 21,
          bottom: 27,
          child: LikeButton(
            size: 37,
            circleColor: const CircleColor(
                start: ColorName.redEC008E, end: ColorName.redFC6767),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: ColorName.redF958A3,
              dotSecondaryColor: ColorName.redFF6FA2,
            ),
            likeBuilder: (bool isLiked) {
              return Assets.images.heart.image(
                width: 37,
                height: 37,
                color: isLiked ? ColorName.redF14336 : Colors.white,
              );
            },
          ),
        ),
      ],
    );
  }
}
