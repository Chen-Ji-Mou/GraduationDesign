import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/dialog/gift_bottom_sheet.dart';
import 'package:graduationdesign/dialog/product_bottom_sheet.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/user_context.dart';
import 'package:graduationdesign/widget/scroll_barrage_widget.dart';
import 'package:graduationdesign/widget/pull_stream_widget.dart';
import 'package:graduationdesign/widget/send_barrage_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PullStreamScreen extends StatefulWidget {
  const PullStreamScreen({
    Key? key,
    required this.liveId,
  }) : super(key: key);

  final String liveId;

  @override
  State<StatefulWidget> createState() => _PullStreamState();
}

class _PullStreamState extends State<PullStreamScreen> {
  String get liveId => widget.liveId;

  late Size screenSize;
  late WebSocketChannel wsChannel;

  final PullStreamController controller = PullStreamController();
  final Completer<void> initialCompleter = Completer<void>.sync();

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
        color: Colors.black,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: toolbarHeight),
        child: Stack(
          fit: StackFit.expand,
          children: [
            buildContent(),
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
          ],
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
            await Future.wait([
              controller.setRtmpUrl('rtmp://81.71.161.128:1935/live/$liveId'),
              controller.setFillXY(true),
              controller.resume(),
            ]);
            initialCompleter.complete();
          },
        ),
        FutureBuilder(
          future: initialCompleter.future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return _ControllerView(
                liveId: liveId,
                screenSize: screenSize,
                wsChannel: wsChannel,
              );
            } else {
              return const LoadingWidget();
            }
          },
        ),
      ],
    );
  }
}

class _ControllerView extends StatefulWidget {
  const _ControllerView({
    Key? key,
    required this.liveId,
    required this.screenSize,
    required this.wsChannel,
  }) : super(key: key);

  final String liveId;
  final Size screenSize;
  final WebSocketChannel wsChannel;

  @override
  State<StatefulWidget> createState() => _ControllerViewState();
}

class _ControllerViewState extends State<_ControllerView> {
  String get liveId => widget.liveId;

  Size get screenSize => widget.screenSize;

  WebSocketChannel get wsChannel => widget.wsChannel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 16,
          bottom: 86,
          child: ScrollBarrageWidget(
            screenSize: screenSize,
            wsChannel: wsChannel,
          ),
        ),
        Positioned(
          left: 16,
          bottom: 22,
          child: InkWell(
            onTap: () => GiftBottomSheet.show(
              context,
              screenSize: screenSize,
              liveId: liveId,
            ),
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
          left: 76,
          bottom: 20,
          child: SendBarrageWidget(
            screenSize: screenSize,
            wsChannel: wsChannel,
          ),
        ),
        Positioned(
          right: 69,
          bottom: 27,
          child: InkWell(
            onTap: () {
              UserContext.checkLoginCallback(context, () {
                GiftBottomSheet.show(
                  context,
                  screenSize: screenSize,
                  liveId: liveId,
                  isBag: true,
                ).then((result) {
                  if (result == false) {
                    GiftBottomSheet.show(
                      context,
                      screenSize: screenSize,
                      liveId: liveId,
                    );
                  }
                });
              });
            },
            child: Assets.images.bag.image(
              width: 37,
              height: 37,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 27,
          child: InkWell(
            onTap: () => ProductBottomSheet.show(
              context,
              screenSize: screenSize,
              liveId: liveId,
            ),
            child: Assets.images.cartIcon.image(
              width: 37,
              height: 37,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
