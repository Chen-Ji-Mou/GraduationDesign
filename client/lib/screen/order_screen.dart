import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/platform/alipay_platform.dart';
import 'package:graduationdesign/screen/home_screen.dart';
import 'package:graduationdesign/user_context.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum TabType { all, payment, send, receive, done }

extension TabTypeExt on TabType {
  String toTitle() {
    switch (this) {
      case TabType.all:
        return '全部';
      case TabType.payment:
        return '待付款';
      case TabType.send:
        return '待发货';
      case TabType.receive:
        return '待收货';
      case TabType.done:
        return '已完成';
    }
  }
}

class _Order {
  final String id;
  final String addressId;
  final String productId;
  final int number;
  final int status;
  final int timestamp;
  late String date;
  late String productName;
  late String? productCoverUrl;
  late String? productIntro;
  late double productPrice;
  late TabType orderStatus;

  _Order(this.id, this.addressId, this.productId, this.number, this.status,
      this.timestamp);

  Future<void> getProductInfo() async {
    Response response = await DioClient.get(Api.getProductInfo, {
      'productId': productId,
    });
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        productName = map['name'];
        productCoverUrl = map['coverUrl'] != null
            ? 'http://${Api.host}:${Api.port}/product/downloadCover?fileName=${map['coverUrl']}'
            : null;
        productIntro = map['intro'];
        productPrice = map['price'];
      }
    }
  }

  void setDate() {
    date = DateTime.fromMillisecondsSinceEpoch(timestamp)
        .toLocal()
        .toString()
        .substring(0, 16);
  }

  void setOrderStatus() {
    orderStatus = TabType.values.firstWhere((e) => e.index - 1 == status);
  }
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrderState();
}

class _OrderState extends State<OrderScreen> with TickerProviderStateMixin {
  final RefreshController refreshController = RefreshController();
  final List<_Order> orders = [];
  final int pageSize = 6;

  late Size screenSize;
  late TabController tabController;
  late List<TabType> tabs = [
    TabType.all,
    if (!UserContext.isEnterprise) TabType.payment,
    TabType.send,
    if (!UserContext.isEnterprise) TabType.receive,
    TabType.done,
  ];

  TabType curTab = TabType.all;
  int curPageNum = 0;
  bool isLastPage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: TabType.values.length, vsync: this);
    getOrders(successCall: (result) {
      if (mounted) {
        setState(() => orders.addAll(result));
      }
    });
  }

  void getOrders({
    required RequestSuccessCallback<_Order> successCall,
    VoidCallback? errorCall,
  }) {
    DioClient.get(Api.getUserOrders, {
      'pageNum': curPageNum,
      'pageSize': pageSize,
    }).then((response) async {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          List<_Order> result = [];
          for (var order in response.data['data']) {
            if (curTab == TabType.all || order['status'] == curTab.index - 1) {
              _Order item = _Order(
                order['id'],
                order['addressId'],
                order['productId'],
                order['number'],
                order['status'],
                order['timestamp'],
              )
                ..setDate()
                ..setOrderStatus();
              result.add(item);
            }
          }
          await Future.wait(result.map((e) => e.getProductInfo()));
          isLastPage = result.length < pageSize;
          if (UserContext.isEnterprise) {
            result.removeWhere((e) => e.orderStatus == TabType.payment);
          }
          successCall.call(result);
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
          errorCall?.call();
        }
      } else {
        errorCall?.call();
      }
    });
  }

  void onRefresh() {
    getOrders(successCall: (result) {
      if (mounted) {
        setState(() => orders
          ..clear()
          ..addAll(result));
      }
      refreshController.refreshCompleted();
    }, errorCall: () {
      refreshController.refreshFailed();
    });
  }

  void onLoading() {
    if (!isLastPage) {
      curPageNum++;
    }
    getOrders(successCall: (result) {
      if (mounted && result.isNotEmpty) {
        setState(() => orders.addAll(result));
      }
      refreshController.loadComplete();
    }, errorCall: () {
      refreshController.loadFailed();
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorName.grayF8F8F8,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          '我的订单',
          style: GoogleFonts.roboto(
            height: 1,
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: Container(
        color: ColorName.grayF8F8F8,
        child: Column(
          children: [
            TabBar(
              controller: tabController,
              isScrollable: true,
              labelColor: ColorName.redF63C77,
              labelStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              unselectedLabelColor: ColorName.black686868,
              unselectedLabelStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              tabs: tabs
                  .map((tab) => Tab(height: 34, text: tab.toTitle()))
                  .toList(),
              indicator: CustomTabIndicator(
                tabController: tabController,
                borderSide: const BorderSide(
                  width: 2,
                  color: ColorName.redF63C77,
                ),
              ),
              onTap: (index) {
                curTab = tabs[index];
                onRefresh();
              },
            ),
            const C(8),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                color: ColorName.grayF8F8F8,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ScrollConfiguration(
                  behavior: NoBoundaryRippleBehavior(),
                  child: SmartRefresher(
                    controller: refreshController,
                    enablePullDown: true,
                    enablePullUp: true,
                    onRefresh: onRefresh,
                    onLoading: onLoading,
                    child: orders.isNotEmpty
                        ? ListView.separated(
                            itemCount: orders.length,
                            itemBuilder: buildAddressItem,
                            separatorBuilder: (context, index) => const C(8),
                          )
                        : const _OrderEmptyWidget(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddressItem(BuildContext context, int index) {
    _Order order = orders[index];
    return InkWell(
      child: Container(
        width: screenSize.width - 12,
        padding: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: screenSize.width - 12,
              alignment: Alignment.centerRight,
              child: Text(
                order.orderStatus.toTitle(),
                style: GoogleFonts.roboto(
                  height: 1,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: order.orderStatus == TabType.done
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorName.gray76787A),
                  ),
                  child: order.productCoverUrl == null
                      ? const DefaultProductWidget(size: 64)
                      : CachedNetworkImage(
                          imageUrl: order.productCoverUrl!,
                          fit: BoxFit.cover,
                        ),
                ),
                const C(20),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.productName,
                      style: GoogleFonts.roboto(
                        height: 1,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    if (order.productIntro != null) ...[
                      const C(4),
                      Text(
                        order.productIntro!,
                        style: GoogleFonts.roboto(
                          height: 1,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: ColorName.gray76787A,
                        ),
                      ),
                    ],
                    const C(8),
                    SizedBox(
                      width: screenSize.width - 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '¥${order.productPrice}',
                            style: GoogleFonts.roboto(
                              height: 1,
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            '×${order.number}',
                            style: GoogleFonts.roboto(
                              height: 1,
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (order.orderStatus != TabType.payment) ...[
                      const C(8),
                      Container(
                        width: screenSize.width - 120,
                        alignment: Alignment.centerRight,
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                            text: '实付款',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              height: 16 / 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '¥',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              height: 16 / 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: (order.productPrice * order.number)
                                .toStringAsFixed(2),
                            style: GoogleFonts.roboto(
                              height: 1,
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ])),
                      ),
                    ],
                    if (getControlButtonTitle(order.orderStatus)
                        .isNotEmpty) ...[
                      const C(24),
                      Container(
                        width: screenSize.width - 120,
                        alignment: Alignment.centerRight,
                        child: buildControlButton(
                          title: getControlButtonTitle(order.orderStatus),
                          onTap: () {
                            switch (order.orderStatus) {
                              case TabType.payment:
                                payForOrder(order);
                                break;
                              case TabType.send:
                                confirmSend(order);
                                break;
                              case TabType.receive:
                                confirmReceive(order);
                                break;
                              case TabType.done:
                                requestRefund(order);
                                break;
                              default:
                                break;
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildControlButton({
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorName.gray76787A),
        ),
        child: Text(
          title,
          style: GoogleFonts.roboto(
            height: 1,
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String getControlButtonTitle(TabType orderStatus) {
    switch (orderStatus) {
      case TabType.all:
        return '';
      case TabType.payment:
        return UserContext.isEnterprise ? '继续支付' : '';
      case TabType.send:
        return UserContext.isEnterprise ? '确认发货' : '催发';
      case TabType.receive:
        return UserContext.isEnterprise ? '' : '确认收货';
      case TabType.done:
        return UserContext.isEnterprise ? '' : '申请退款';
    }
  }

  Future<void> payForOrder(_Order order) async {
    bool paySuccess =
        await AlipayPlatform.payV2(order.productPrice * order.number);
    if (paySuccess) {
      Fluttertoast.showToast(msg: '支付成功');
      Response response = await DioClient.post(Api.updateOrderStatus, {
        'orderId': order.id,
        'status': 1,
      });
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          Fluttertoast.showToast(msg: '订单状态改变');
          if (mounted) {
            setState(() => order.orderStatus = TabType.send);
          }
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
        }
      }
    }
  }

  Future<void> confirmSend(_Order order) async {
    Response response = await DioClient.post(Api.updateOrderStatus, {
      'orderId': order.id,
      'status': 2,
    });
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Fluttertoast.showToast(msg: '订单状态改变');
        if (mounted) {
          setState(() => order.orderStatus = TabType.receive);
        }
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
      }
    }
  }

  Future<void> confirmReceive(_Order order) async {
    Response response = await DioClient.post(Api.updateOrderStatus, {
      'orderId': order.id,
      'status': 3,
    });
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Fluttertoast.showToast(msg: '订单状态改变');
        if (mounted) {
          setState(() => order.orderStatus = TabType.done);
        }
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
      }
    }
  }

  Future<void> requestRefund(_Order order) async {
    Response response = await DioClient.post(Api.addRefund, {
      'orderId': order.id,
    });
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Fluttertoast.showToast(msg: '申请退款成功');
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
      }
    }
  }
}

class _OrderEmptyWidget extends StatelessWidget {
  const _OrderEmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.imgOrderEmpty.image(fit: BoxFit.cover),
          Text(
            '当前没有订单信息',
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
