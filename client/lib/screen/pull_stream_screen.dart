import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/models.dart';
import 'package:graduationdesign/user_context.dart';
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

  final String liveId;

  @override
  State<StatefulWidget> createState() => _PullStreamState();
}

class _PullStreamState extends State<PullStreamScreen> {
  String get liveId => widget.liveId;

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
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.9)),
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
          bottom: 86,
          child:
              ScrollBarrageWidget(screenSize: screenSize, wsChannel: wsChannel),
        ),
        Positioned(
          left: 16,
          bottom: 22,
          child: InkWell(
            onTap: () => showBottomSheet(isBag: false),
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
          child:
              SendBarrageWidget(screenSize: screenSize, wsChannel: wsChannel),
        ),
        Positioned(
          right: 69,
          bottom: 27,
          child: InkWell(
            onTap: () {
              UserContext.checkLoginCallback(context, () {
                showBottomSheet(isBag: true).then((result) {
                  if (result == false) {
                    showBottomSheet(isBag: false);
                  }
                });
              });
            },
            child: Assets.images.bag.image(width: 37, height: 37),
          ),
        ),
        Positioned(
          right: 16,
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
                color: isLiked
                    ? ColorName.redF14336
                    : Colors.white.withOpacity(0.9),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<bool?> showBottomSheet({required bool isBag}) async {
    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _BottomSheet(screenSize: screenSize, liveId: liveId, isBag: isBag),
    );
  }
}

class _GiftWrapper {
  final Gift gift;
  late int number;

  _GiftWrapper(this.gift);

  Future<void> setGiftNumber() async {
    Response response =
        await DioClient.get(Api.getGiftNumber, {'giftId': gift.id});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        number = response.data['data'];
      }
    }
  }
}

class _BagWrapper {
  final Bag bag;
  late String giftName;
  late int giftPrice;

  _BagWrapper(this.bag);

  Future<void> setGiftInfo() async {
    Response response =
        await DioClient.get(Api.getGift, {'giftId': bag.giftId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        giftName = map['name'];
        giftPrice = map['price'];
      }
    }
  }
}

typedef _SuccessCallback = void Function(List<dynamic> data);
typedef _ErrorCallback = void Function();

class _BottomSheet extends StatefulWidget {
  const _BottomSheet({
    Key? key,
    required this.screenSize,
    required this.liveId,
    this.isBag = false,
  }) : super(key: key);

  final Size screenSize;
  final bool isBag;
  final String liveId;

  @override
  State<StatefulWidget> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<_BottomSheet> {
  Size get screenSize => widget.screenSize;

  bool get isBag => widget.isBag;

  String get liveId => widget.liveId;

  final PageController pageController = PageController();
  final int pageNum = 0;
  final int pageSize = 8;
  List<_GiftWrapper> giftWrappers = [];
  List<_BagWrapper> bagWrappers = [];
  int curPageIndex = 0;
  int selectIndex = -1;
  int balance = 0;

  @override
  void initState() {
    super.initState();
    requestServer(successCall: (data) async {
      if (isBag) {
        List<_BagWrapper> result = [];
        for (var bag in data) {
          _BagWrapper bagWrapper = _BagWrapper(Bag.fromJsonMap(bag));
          if (bagWrapper.bag.number > 0) {
            result.add(bagWrapper);
          }
        }
        await Future.wait(result.map((e) => e.setGiftInfo()));
        if (mounted) setState(() => bagWrappers.addAll(result));
      } else {
        List<_GiftWrapper> result = [];
        for (var gift in data) {
          result.add(_GiftWrapper(Gift.fromJsonMap(gift)));
        }
        await Future.wait(result.map((e) => e.setGiftNumber()));
        if (mounted) setState(() => giftWrappers.addAll(result));
      }
    });
    if (!isBag) {
      refreshBalance();
    }
  }

  void requestServer({
    _SuccessCallback? successCall,
    _ErrorCallback? errorCall,
  }) {
    DioClient.get(
      isBag ? Api.getUserBag : Api.getGifts,
    ).then((response) async {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          successCall?.call(response.data['data']);
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
          errorCall?.call();
        }
      }
    });
  }

  void refreshBalance() {
    DioClient.get(Api.getAccount).then((response) {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          Map<String, dynamic> jsonMap = response.data['data'];
          if (mounted) {
            setState(() => balance = jsonMap['balance']);
          }
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
        }
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHeader(),
          buildList(),
          buildBottom(),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Assets.images.giftIcon.image(width: 18, height: 18),
          const C(8.5),
          Text(
            '礼物',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              height: 18 / 15,
              fontSize: 15,
            ),
          ),
          if (isBag) ...[
            const C(46.5),
            Assets.images.bagIcon.image(width: 18, height: 18),
            const C(11),
            Text(
              '背包',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: ColorName.gray76787A,
                height: 18 / 15,
                fontSize: 15,
              ),
            ),
          ] else
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.images.species.image(width: 24, height: 24),
                    const C(11),
                    Text(
                      balance.toString(),
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                        height: 18 / 15,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: (screenSize.width / 4) * 2),
          child: PageView.builder(
            itemCount: getPageCount(),
            onPageChanged: (index) => setState(() => curPageIndex = index),
            itemBuilder: (context, pageIndex) => GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
              ),
              itemCount: getGridCount(pageIndex),
              itemBuilder: (context, index) => InkWell(
                onTap: () => setState(() => selectIndex = index),
                child: Container(
                  width: screenSize.width / 4,
                  height: screenSize.width / 4,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: index == selectIndex
                        ? ColorName.redF63C77.withOpacity(0.5)
                        : null,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.9), width: 0.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Assets.images.lightStick.image(width: 36, height: 36),
                      const C(4),
                      Text(
                        getGiftName(pageIndex, index),
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          height: 14 / 13,
                          fontSize: 13,
                        ),
                      ),
                      if (!isBag) ...[
                        const C(6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Assets.images.species.image(width: 14, height: 14),
                            const C(8),
                            Text(
                              getGiftPrice(pageIndex, index),
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                                height: 14 / 13,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (getPageCount() > 1) ...[
          const C(8),
          DotsIndicator(
            dotsCount: getPageCount(),
            position: curPageIndex.toDouble(),
            decorator: const DotsDecorator(
              color: ColorName.whiteF6F7F8,
              activeColor: ColorName.redF63C77,
            ),
          ),
        ],
      ],
    );
  }

  int getPageCount() => isBag
      ? (bagWrappers.length / pageSize + 1).toInt()
      : (giftWrappers.length / pageSize + 1).toInt();

  int getGridCount(int pageIndex) => isBag
      ? bagWrappers.length - pageSize * pageIndex < 8
          ? (bagWrappers.length - pageSize * pageIndex) % 8
          : 8
      : giftWrappers.length - pageSize * pageIndex < 8
          ? (giftWrappers.length - pageSize * pageIndex) % 8
          : 8;

  String getGiftName(int pageIndex, int gridIndex) => isBag
      ? bagWrappers[pageSize * pageIndex + gridIndex].giftName
      : giftWrappers[pageSize * pageIndex + gridIndex].gift.name;

  String getGiftPrice(int pageIndex, int gridIndex) =>
      giftWrappers[pageSize * pageIndex + gridIndex].gift.price != 0
          ? (giftWrappers[pageSize * pageIndex + gridIndex].gift.price)
              .toString()
          : '免费';

  Widget buildBottom() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          if (isBag && selectIndex != -1) ...[
            Text(
              '数量',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
                height: 18 / 15,
                fontSize: 15,
              ),
            ),
            const C(8),
            Text(
              bagWrappers[selectIndex].bag.number.toString(),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
                height: 18 / 15,
                fontSize: 15,
              ),
            ),
          ],
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: selectIndex != -1 || isBag ? buyGift : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.5),
                        gradient: LinearGradient(
                          colors: [
                            ColorName.purpleB83AF3.withOpacity(0.9),
                            ColorName.purple6950FB.withOpacity(0.9),
                          ],
                        ),
                      ),
                      child: Text(
                        '购买',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                          height: 18 / 15,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  if (isBag) ...[
                    const C(16),
                    InkWell(
                      onTap: selectIndex != -1 ? sendGift : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.5),
                          gradient: LinearGradient(
                            colors: [
                              ColorName.redEC008E.withOpacity(0.9),
                              ColorName.redFC6767.withOpacity(0.9),
                            ],
                          ),
                        ),
                        child: Text(
                          '发送',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                            height: 18 / 15,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendGift() {
    Future.wait([
      DioClient.post(Api.sendGift, {
        'liveId': liveId,
        'giftId': bagWrappers[selectIndex].bag.giftId,
      }),
      DioClient.post(Api.reduceBag, {
        'giftId': isBag
            ? bagWrappers[selectIndex].bag.giftId
            : giftWrappers[selectIndex].gift.id,
      }),
    ]).then((responses) {
      bool success = false;
      for (var response in responses) {
        if (response.statusCode == 200 && response.data != null) {
          if (response.data['code'] == 200) {
            success = true;
          } else {
            Fluttertoast.showToast(msg: response.data['msg']);
            success = false;
            break;
          }
        } else {
          success = false;
          break;
        }
      }
      if (success) {
        exit();
      }
    });
  }

  Future<void> buyGift() async {
    bool isLogin = await UserContext.awaitLogin(context);
    if (!isLogin) {
      return;
    }
    if (isBag) {
      exit(false);
    } else {
      bool canBuy = giftWrappers[selectIndex].gift.price >= 0 &&
          balance - giftWrappers[selectIndex].gift.price >= 0;
      if (!canBuy) {
        await Navigator.pushNamed(context, 'recharge');
        refreshBalance();
      } else {
        if (giftWrappers[selectIndex].gift.price > 0) {
          await Future.wait([
            DioClient.post(Api.spendAccount, {
              'amount': giftWrappers[selectIndex].gift.price,
            }),
            DioClient.post(Api.addDetail, {
              'income': 0,
              'expenditure': giftWrappers[selectIndex].gift.price,
            }),
          ]);
          refreshBalance();
        }
        bool isSend = await showAlert();
        if (isSend) {
          DioClient.post(Api.sendGift, {
            'liveId': liveId,
            'giftId': giftWrappers[selectIndex].gift.id,
          }).then((response) {
            if (response.statusCode == 200 && response.data != null) {
              if (response.data['code'] == 200) {
                Fluttertoast.showToast(msg: '礼物发送成功');
                exit();
              } else {
                Fluttertoast.showToast(msg: response.data['msg']);
              }
            }
          });
        } else {
          DioClient.post(Api.addBag, {
            'giftId': giftWrappers[selectIndex].gift.id,
          }).then((response) {
            if (response.statusCode == 200 && response.data != null) {
              if (response.data['code'] == 200) {
                Fluttertoast.showToast(msg: '礼物购买成功，已放入背包');
              } else {
                Fluttertoast.showToast(msg: response.data['msg']);
              }
            }
          });
        }
      }
    }
  }

  Future<bool> showAlert() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('支付成功'),
            content: const Text('需要现在发送礼物给主播吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('是的'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('不了'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void exit<T>([T? result]) => Navigator.pop(context, result);
}
