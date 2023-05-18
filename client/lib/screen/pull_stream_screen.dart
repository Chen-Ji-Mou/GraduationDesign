import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/dialog/gift_bottom_sheet.dart';
import 'package:graduationdesign/dialog/cart_bottom_sheet.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/screen/enter_live_screen.dart';
import 'package:graduationdesign/user_context.dart';
import 'package:graduationdesign/widget/scroll_barrage_widget.dart';
import 'package:graduationdesign/widget/pull_stream_widget.dart';
import 'package:graduationdesign/widget/send_barrage_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PullStreamScreen extends StatefulWidget {
  const PullStreamScreen({
    Key? key,
    required this.liveInfo,
  }) : super(key: key);

  final LiveInfo liveInfo;

  @override
  State<StatefulWidget> createState() => _PullStreamState();
}

class _PullStreamState extends State<PullStreamScreen> {
  LiveInfo get liveInfo => widget.liveInfo;

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
        Uri.parse('ws://81.71.161.128:8088/websocket?lid=${liveInfo.id}'));
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
              controller
                  .setRtmpUrl('rtmp://81.71.161.128:1935/live/${liveInfo.id}'),
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
                liveInfo: liveInfo,
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
    required this.liveInfo,
    required this.screenSize,
    required this.wsChannel,
  }) : super(key: key);

  final LiveInfo liveInfo;
  final Size screenSize;
  final WebSocketChannel wsChannel;

  @override
  State<StatefulWidget> createState() => _ControllerViewState();
}

class _ControllerViewState extends State<_ControllerView> {
  LiveInfo get liveInfo => widget.liveInfo;

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
            width: screenSize.width * 2 / 3,
            wsChannel: wsChannel,
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Row(
            children: [
              InkWell(
                onTap: () => GiftBottomSheet.show(
                  context,
                  screenSize: screenSize,
                  liveId: liveInfo.id,
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
              const C(12),
              Expanded(
                child: SendBarrageWidget(
                  screenSize: screenSize,
                  wsChannel: wsChannel,
                ),
              ),
              const C(12),
              InkWell(
                onTap: () {
                  UserContext.checkLoginCallback(context, () {
                    GiftBottomSheet.show(
                      context,
                      screenSize: screenSize,
                      liveId: liveInfo.id,
                      isBag: true,
                    ).then((result) {
                      if (result == false) {
                        GiftBottomSheet.show(
                          context,
                          screenSize: screenSize,
                          liveId: liveInfo.id,
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
              if (liveInfo.status && liveInfo.belongEnterprise) ...[
                const C(12),
                InkWell(
                  onTap: () => CartBottomSheet.show(
                    context,
                    screenSize: screenSize,
                    liveId: liveInfo.id,
                  ),
                  child: Assets.images.cartIcon.image(
                    width: 37,
                    height: 37,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
