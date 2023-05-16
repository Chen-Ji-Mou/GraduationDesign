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

class _Gift {
  final Gift gift;

  _Gift(this.gift);
}

class _Bag {
  final Bag bag;
  late String giftName;
  late int number;

  _Bag(this.bag);

  Future<void> setGiftInfo() async {
    Response response =
        await DioClient.get(Api.getGift, {'giftId': bag.giftId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        giftName = map['name'];
      }
    }
  }

  Future<void> setGiftNumber() async {
    Response response =
        await DioClient.get(Api.getGiftNumber, {'giftId': bag.giftId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        number = response.data['data'];
      }
    }
  }
}

class GiftBottomSheet extends StatefulWidget {
  const GiftBottomSheet({
    Key? key,
    required this.screenSize,
    required this.liveId,
    this.isBag = false,
  }) : super(key: key);

  final Size screenSize;
  final String liveId;
  final bool isBag;

  static Future<bool?> show(
    BuildContext context, {
    required Size screenSize,
    required String liveId,
    bool isBag = false,
  }) async {
    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GiftBottomSheet(
        screenSize: screenSize,
        liveId: liveId,
        isBag: isBag,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _GiftBottomSheetState();
}

class _GiftBottomSheetState extends State<GiftBottomSheet> {
  Size get screenSize => widget.screenSize;

  bool get isBag => widget.isBag;

  String get liveId => widget.liveId;

  final PageController pageController = PageController();
  final int pageNum = 0;
  final int pageSize = 8;
  List<_Gift> gifts = [];
  List<_Bag> bags = [];
  int curPageIndex = 0;
  int selectIndex = -1;
  int balance = 0;

  @override
  void initState() {
    super.initState();
    getGifts(successCall: (data) async {
      if (isBag) {
        List<_Bag> result = [];
        for (var bag in data) {
          _Bag bagWrapper = _Bag(Bag.fromJsonMap(bag));
          if (bagWrapper.bag.number > 0) {
            result.add(bagWrapper);
          }
        }
        await Future.wait([
          Future.wait(result.map((e) => e.setGiftInfo())),
          Future.wait(result.map((e) => e.setGiftNumber())),
        ]);
        if (mounted) setState(() => bags.addAll(result));
      } else {
        List<_Gift> result = [];
        for (var gift in data) {
          result.add(_Gift(Gift.fromJsonMap(gift)));
        }
        if (mounted) setState(() => gifts.addAll(result));
      }
    });
    if (!isBag) {
      refreshBalance();
    }
  }

  void getGifts({
    RequestSuccessCallback? successCall,
    VoidCallback? errorCall,
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
          if ((isBag && bags.isNotEmpty) ||
              (!isBag && gifts.isNotEmpty))
            buildList()
          else
            _GiftEmptyWidget(screenSize: screenSize),
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
          if (isBag) ...[
            Assets.images.bagIcon.image(
              width: 18,
              height: 18,
              color: Colors.white,
            ),
            const C(8.5),
            Text(
              '背包',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 18 / 15,
                fontSize: 15,
              ),
            ),
          ] else ...[
            Assets.images.giftIcon.image(
              width: 18,
              height: 18,
              color: Colors.white,
            ),
            const C(8.5),
            Text(
              '礼物',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 18 / 15,
                fontSize: 15,
              ),
            ),
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
                        color: Colors.white,
                        height: 18 / 15,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                    border: Border.all(color: Colors.white, width: 0.5),
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
                          color: Colors.white,
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
                                color: Colors.white,
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
      ? (bags.length / pageSize + 1).toInt()
      : (gifts.length / pageSize + 1).toInt();

  int getGridCount(int pageIndex) => isBag
      ? bags.length - pageSize * pageIndex < 8
          ? (bags.length - pageSize * pageIndex) % 8
          : 8
      : gifts.length - pageSize * pageIndex < 8
          ? (gifts.length - pageSize * pageIndex) % 8
          : 8;

  String getGiftName(int pageIndex, int gridIndex) => isBag
      ? bags[pageSize * pageIndex + gridIndex].giftName
      : gifts[pageSize * pageIndex + gridIndex].gift.name;

  String getGiftPrice(int pageIndex, int gridIndex) =>
      gifts[pageSize * pageIndex + gridIndex].gift.price != 0
          ? (gifts[pageSize * pageIndex + gridIndex].gift.price)
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
                color: Colors.white,
                height: 18 / 15,
                fontSize: 15,
              ),
            ),
            const C(8),
            Text(
              bags[selectIndex].bag.number.toString(),
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
                        gradient: const LinearGradient(
                          colors: [
                            ColorName.purpleB83AF3,
                            ColorName.purple6950FB,
                          ],
                        ),
                      ),
                      child: Text(
                        '购买',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
                          gradient: const LinearGradient(
                            colors: [
                              ColorName.redEC008E,
                              ColorName.redFC6767,
                            ],
                          ),
                        ),
                        child: Text(
                          '发送',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
    DioClient.post(Api.sendGift, {
      'liveId': liveId,
      'giftId': bags[selectIndex].bag.giftId,
    }).then((response) {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          DioClient.post(Api.reduceBag, {
            'giftId': bags[selectIndex].bag.giftId,
          }).then((response) {
            if (response.statusCode == 200 && response.data != null) {
              if (response.data['code'] == 200) {
                exit();
              } else {
                Fluttertoast.showToast(msg: response.data['msg']);
              }
            }
          });
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
        }
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
      bool canBuy = gifts[selectIndex].gift.price >= 0 &&
          balance - gifts[selectIndex].gift.price >= 0;
      if (!canBuy) {
        await Navigator.pushNamed(context, 'recharge');
        refreshBalance();
      } else {
        if (gifts[selectIndex].gift.price > 0) {
          await Future.wait([
            DioClient.post(Api.spendAccount, {
              'amount': gifts[selectIndex].gift.price,
            }),
            DioClient.post(Api.addDetail, {
              'income': 0,
              'expenditure': gifts[selectIndex].gift.price,
            }),
          ]);
          refreshBalance();
        }
        bool isSend = await showAlert();
        if (isSend) {
          DioClient.post(Api.sendGift, {
            'liveId': liveId,
            'giftId': gifts[selectIndex].gift.id,
          }).then((response) {
            if (response.statusCode == 200 && response.data != null) {
              if (response.data['code'] == 200) {
                Fluttertoast.showToast(msg: '礼物发送成功');
                exit();
              } else {
                Fluttertoast.showToast(msg: response.data['msg']);
                DioClient.post(Api.addBag, {
                  'giftId': gifts[selectIndex].gift.id,
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
          });
        } else {
          DioClient.post(Api.addBag, {
            'giftId': gifts[selectIndex].gift.id,
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

  void exit([bool? result]) => Navigator.pop(context, result);
}

class _GiftEmptyWidget extends StatelessWidget {
  const _GiftEmptyWidget({
    Key? key,
    required this.screenSize,
  }) : super(key: key);

  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (screenSize.width / 4) * 2,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.imgGiftEmpty.image(fit: BoxFit.cover),
          Text(
            '当前没有礼物信息',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorName.black686868.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
