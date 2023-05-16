import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/dialog/create_order_bottom_sheet.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/user_context.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class _Cart {
  final String id;
  final String productId;
  final int number;
  late String productName;
  late String? productCoverUrl;
  late String? productIntro;
  late bool productStatus;
  late double productPrice;
  bool isSelect = false;

  _Cart(this.id, this.productId, this.number);

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
        productStatus = map['status'];
        productPrice = map['price'];
      }
    }
  }
}

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCartScreen>
    with AutomaticKeepAliveClientMixin {
  double get totalAmount {
    double totalAmount = 0;
    for (var cart in carts.where((e) => e.isSelect)) {
      totalAmount = totalAmount + cart.productPrice * cart.number;
    }
    return totalAmount;
  }

  bool get selectedCart => carts.map((e) => e.isSelect).contains(true);

  bool get isSelectAll =>
      carts.isNotEmpty && !carts.map((e) => e.isSelect).contains(false);

  bool get isMultipleSelect => carts.where((e) => e.isSelect).length > 1;

  final RefreshController refreshController = RefreshController();
  final List<_Cart> carts = [];

  late Size screenSize;

  bool isEditing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void initState() {
    super.initState();
    getCarts(successCall: (result) {
      if (mounted) {
        setState(() => carts.addAll(result));
      }
    });
  }

  void onRefresh() {
    getCarts(successCall: (result) {
      if (mounted) {
        setState(() => carts
          ..clear()
          ..addAll(result));
      }
      refreshController.refreshCompleted();
    }, errorCall: () {
      refreshController.refreshFailed();
    });
  }

  void getCarts({
    required RequestSuccessCallback<_Cart> successCall,
    VoidCallback? errorCall,
  }) {
    DioClient.get(Api.getCarts).then((response) async {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          List<_Cart> result = [];
          for (var cart in response.data['data']) {
            _Cart item = _Cart(
              cart['id'],
              cart['productId'],
              cart['number'],
            );
            result.add(item);
          }
          await Future.wait(result.map((e) => e.getProductInfo()));
          result.removeWhere((e) => !e.productStatus);
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

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        children: [
          buildHeader(),
          Expanded(
            child: Container(
              color: ColorName.grayF8F8F8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ScrollConfiguration(
                    behavior: NoBoundaryRippleBehavior(),
                    child: SmartRefresher(
                      controller: refreshController,
                      enablePullDown: true,
                      enablePullUp: false,
                      onRefresh: onRefresh,
                      child: carts.isNotEmpty
                          ? ListView.separated(
                              itemCount: carts.length,
                              itemBuilder: buildCartItem,
                              separatorBuilder: (context, index) => const C(16),
                            )
                          : const _CartEmptyWidget(),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: buildBottom(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: screenSize.width,
      height: 48,
      color: Colors.white,
      child: Row(
        children: [
          const C(16),
          Text(
            '购物车',
            style: GoogleFonts.roboto(
              height: 1,
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: InkWell(
                onTap: () {
                  if (mounted) {
                    setState(() => isEditing = !isEditing);
                  }
                },
                child: Text(
                  !isEditing ? '管理' : '完成',
                  style: GoogleFonts.roboto(
                    height: 1,
                    fontSize: 14,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCartItem(BuildContext context, int index) {
    _Cart cart = carts[index];
    return Container(
      width: screenSize.width - 16,
      margin: EdgeInsets.only(
        left: 8,
        top: index == 0 ? 16 : 0,
        right: 8,
        bottom: index == carts.length - 1 ? 16 : 0,
      ),
      padding: const EdgeInsets.only(top: 12, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: cart.isSelect,
            activeColor: Colors.deepOrange,
            shape: const CircleBorder(),
            onChanged: (value) {
              if (mounted && value == true) {
                setState(() => cart.isSelect = true);
              } else if (mounted && value == false) {
                setState(() => cart.isSelect = false);
              }
            },
          ),
          Container(
            width: 96,
            height: 96,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorName.gray76787A),
            ),
            child: cart.productCoverUrl == null
                ? const DefaultProductWidget(size: 96)
                : CachedNetworkImage(
                    imageUrl: cart.productCoverUrl!,
                    fit: BoxFit.cover,
                  ),
          ),
          const C(12),
          SizedBox(
            height: 88,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cart.productName,
                  style: GoogleFonts.roboto(
                    height: 1,
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (cart.productIntro != null) ...[
                  const C(8),
                  Text(
                    cart.productIntro!,
                    style: GoogleFonts.roboto(
                      height: 1,
                      fontSize: 14,
                      color: ColorName.gray76787A,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
                SizedBox(
                  width: screenSize.width - 188,
                  child: Row(
                    children: [
                      Text(
                        '¥${cart.productPrice}',
                        style: GoogleFonts.roboto(
                          height: 1,
                          fontSize: 18,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomRight,
                          // padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '×${cart.number}',
                            style: GoogleFonts.roboto(
                              height: 1,
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottom() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8, right: 8, bottom: 24),
      child: InkWell(
        child: Container(
          width: screenSize.width - 16,
          height: 40,
          alignment: Alignment.center,
          child: Row(
            children: [
              Checkbox(
                value: isSelectAll,
                activeColor: Colors.deepOrange,
                shape: const CircleBorder(),
                onChanged: (value) {
                  if (mounted && value == true) {
                    setState(() {
                      for (var cur in carts) {
                        cur.isSelect = true;
                      }
                    });
                  } else if (mounted && value == false) {
                    setState(() {
                      for (var cur in carts) {
                        cur.isSelect = false;
                      }
                    });
                  }
                },
              ),
              Text(
                '全选',
                style: GoogleFonts.roboto(
                  height: 1,
                  fontSize: 13,
                  color: ColorName.gray8A8A8A,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isEditing)
                        Text.rich(TextSpan(
                          children: [
                            TextSpan(
                              text: '合计：',
                              style: GoogleFonts.roboto(
                                height: 1,
                                fontSize: 13,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: '¥',
                              style: GoogleFonts.roboto(
                                height: 1,
                                fontSize: 12,
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: totalAmount.toStringAsFixed(2),
                              style: GoogleFonts.roboto(
                                height: 1,
                                fontSize: 20,
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )),
                      const C(8),
                      InkWell(
                        onTap: selectedCart ? bottomClick : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isEditing
                                ? Colors.red.withOpacity(selectedCart ? 1 : 0.5)
                                : null,
                            gradient: !isEditing
                                ? LinearGradient(colors: [
                                    Colors.orange
                                        .withOpacity(selectedCart ? 1 : 0.5),
                                    Colors.deepOrange
                                        .withOpacity(selectedCart ? 1 : 0.5),
                                  ])
                                : null,
                          ),
                          child: Text(
                            !isEditing ? '结算' : '删除',
                            style: GoogleFonts.roboto(
                              height: 1.2,
                              fontSize: 13,
                              color: Colors.white
                                  .withOpacity(selectedCart ? 1 : 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> bottomClick() async {
    if (!isEditing) {
      if (isMultipleSelect) {
        Fluttertoast.showToast(msg: '目前系统仅支持单个商品进行结算');
        return;
      } else {
        _Cart cart = carts.firstWhere((e) => e.isSelect);
        bool success = await CreateOrderBottomSheet.show(
              context,
              screenSize: screenSize,
              productId: cart.productId,
              from: Position.cart,
              orderNumber: cart.number,
            ) ??
            false;
        if (!success) {
          return;
        }
      }
    }
    List<String> cartIds =
        carts.where((e) => e.isSelect).map((e) => e.id).toList();
    Response response = await DioClient.post(Api.deleteCart, {
      'cartIds': cartIds,
    });
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Fluttertoast.showToast(msg: isEditing ? '删除成功' : '下单成功');
        onRefresh();
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
      }
    }
  }

  @override
  bool get wantKeepAlive => UserContext.isLogin;
}

class _CartEmptyWidget extends StatelessWidget {
  const _CartEmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.imgCartEmpty.image(fit: BoxFit.cover),
          Text(
            '当前没有购物车信息',
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
