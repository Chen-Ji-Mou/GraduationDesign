import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/platform/alipay_platform.dart';

enum Position { live, cart }

class _Product {
  final String id;
  final String enterpriseId;
  final String name;
  String? coverUrl;
  final String? intro;
  final int inventory;
  final double price;

  _Product(this.id, this.enterpriseId, this.name, this.coverUrl, this.intro,
      this.inventory, this.price);

  void resetCoverUrl() {
    if (coverUrl != null) {
      coverUrl =
          'http://${Api.host}:${Api.port}/product/downloadCover?fileName=$coverUrl';
    }
  }
}

class _Address {
  final String id;
  final String name;
  final String phone;
  final String area;
  final String fullAddress;

  _Address(this.id, this.name, this.phone, this.area, this.fullAddress);
}

enum _PaymentType { alipay }

class _Payment {
  final _PaymentType type;
  final ImageProvider icon;
  final String name;
  bool isSelect = false;

  _Payment(
    this.type, {
    required this.icon,
    required this.name,
    this.isSelect = false,
  });
}

class CreateOrderBottomSheet extends StatefulWidget {
  const CreateOrderBottomSheet({
    Key? key,
    required this.screenSize,
    required this.productId,
    required this.from,
    this.orderNumber = 1,
    this.isAddCart = false,
  }) : super(key: key);

  final Size screenSize;
  final String productId;
  final Position from;
  final int orderNumber;
  final bool isAddCart;

  static Future<bool?> show(
    BuildContext context, {
    required Size screenSize,
    required String productId,
    required Position from,
    int orderNumber = 1,
    bool isAddCart = false,
  }) async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateOrderBottomSheet(
        screenSize: screenSize,
        productId: productId,
        from: from,
        orderNumber: orderNumber,
        isAddCart: isAddCart,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _CreateOrderBottomSheetState();
}

class _CreateOrderBottomSheetState extends State<CreateOrderBottomSheet> {
  Size get screenSize => widget.screenSize;

  String get productId => widget.productId;

  bool get isAddCart => widget.isAddCart;

  Position get from => widget.from;

  int get orderNumber => widget.orderNumber;

  _PaymentType? get selectPaymentType =>
      payments.firstWhereOrNull((e) => e.isSelect)?.type;

  bool get hasEnoughInventory =>
      product.inventory > 0 && product.inventory - curNumber >= 0;

  final Completer<String?> productCompleter = Completer<String?>.sync();
  final List<_Address> addresses = [];
  final List<_Payment> payments = [
    _Payment(
      _PaymentType.alipay,
      icon: Assets.images.alipayIcon.provider(),
      name: '支付宝支付',
      isSelect: true,
    ),
  ];

  late _Product product;

  _Address? curSelectAddress;
  late int curNumber = orderNumber;

  @override
  void initState() {
    super.initState();
    getProductInfo();
    if (!isAddCart) {
      getAddress();
    }
  }

  Future<void> getProductInfo() async {
    Response response = await DioClient.get(Api.getProductInfo, {
      'productId': productId,
    });
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        product = _Product(
          map['id'],
          map['enterpriseId'],
          map['name'],
          map['coverUrl'],
          map['intro'],
          map['inventory'],
          map['price'],
        )..resetCoverUrl();
        productCompleter.complete();
      } else {
        productCompleter.complete('获取产品信息错误\n${response.data['msg']}');
      }
    } else {
      productCompleter.complete('获取产品信息错误\n${response.statusMessage}');
    }
  }

  Future<void> getAddress() async {
    Response response = await DioClient.get(Api.getAddresses);
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        List<_Address> result = [];
        for (var address in response.data['data']) {
          _Address item = _Address(
            address['id'],
            address['name'],
            address['phone'],
            address['area'],
            address['fullAddress'],
          );
          result.add(item);
        }
        if (mounted) {
          setState(() {
            addresses.addAll(result);
            curSelectAddress = addresses.firstOrNull;
          });
        }
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenSize.width,
      height: screenSize.height - 108,
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder(
            future: productCompleter.future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == null) {
                return Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const C(10),
                            buildHeader(),
                            if (!isAddCart) ...[
                              const C(10),
                              const Divider(color: ColorName.gray8A8A8A),
                              const C(10),
                              buildAddress(),
                            ],
                            const C(10),
                            const Divider(color: ColorName.gray8A8A8A),
                            const C(10),
                            buildOrderNumber(),
                            if (!isAddCart) ...[
                              const C(10),
                              const Divider(color: ColorName.gray8A8A8A),
                              const C(10),
                              buildPayment(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: buildBottomButton(),
                    ),
                  ],
                );
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                return _ErrorWidget(errorMsg: snapshot.data!);
              } else {
                return const LoadingWidget();
              }
            },
          ),
          Positioned(
            top: 12,
            right: 16,
            child: InkWell(
              onTap: exit,
              child: const Icon(
                Icons.close,
                size: 24,
                color: ColorName.black333333,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60,
          height: 60,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: ColorName.grayBFBFBF,
            borderRadius: BorderRadius.circular(4),
          ),
          child: product.coverUrl == null
              ? const DefaultProductWidget(size: 60)
              : CachedNetworkImage(
                  imageUrl: product.coverUrl!,
                  fit: BoxFit.cover,
                ),
        ),
        const C(16),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.name,
                style: GoogleFonts.roboto(
                  height: 1.2,
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '¥${product.price}',
                style: GoogleFonts.roboto(
                  height: 1.2,
                  fontSize: 16,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAddress() {
    return SizedBox(
      width: screenSize.width - 20,
      height: 48,
      child: curSelectAddress != null
          ? InkWell(
              onTap: () async {
                String? id = await Navigator.pushNamed(context, 'address',
                    arguments: true);
                if (mounted) {
                  setState(() => curSelectAddress =
                      addresses.firstWhere((e) => e.id == id));
                }
              },
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.deepOrange,
                    ),
                    child: Assets.images.addressIcon.image(
                      width: 16,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                  const C(10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curSelectAddress?.fullAddress ?? '',
                        style: GoogleFonts.roboto(
                          height: 1.2,
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const C(8),
                      Text(
                        '${curSelectAddress?.name}  ${curSelectAddress?.phone}',
                        style: GoogleFonts.roboto(
                          height: 1.2,
                          fontSize: 13,
                          color: ColorName.gray8A8A8A,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Assets.images.right.image(width: 16, height: 16),
                    ),
                  ),
                ],
              ),
            )
          : InkWell(
              onTap: () async {
                await Navigator.pushNamed(context, 'address', arguments: false);
                getAddress();
              },
              child: const _ErrorWidget(errorMsg: '未找到收货地址信息，请点击添加'),
            ),
    );
  }

  Widget buildOrderNumber() {
    return Row(
      children: [
        Text(
          '购买数量',
          style: GoogleFonts.roboto(
            height: 1.25,
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        const C(14),
        Text(
          hasEnoughInventory ? '有货' : '无货',
          style: GoogleFonts.roboto(
            height: 1,
            fontSize: 12,
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
                if (from == Position.live) ...[
                  InkWell(
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          if (curNumber > 1) {
                            curNumber--;
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: ColorName.grayBFBFBF,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 16,
                        color: ColorName.gray8A8A8A,
                      ),
                    ),
                  ),
                  const C(1),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  color: from == Position.live ? ColorName.grayBFBFBF : null,
                  child: Text(
                    from == Position.cart
                        ? '×$curNumber'
                        : curNumber.toString(),
                    style: GoogleFonts.roboto(
                      height: 1.2,
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (from == Position.live) ...[
                  const C(1),
                  InkWell(
                    onTap: () {
                      if (mounted) {
                        setState(() => curNumber++);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: ColorName.grayBFBFBF,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: ColorName.gray8A8A8A,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPayment() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: payments.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return SizedBox(
          width: screenSize.width - 20,
          height: 32,
          child: Row(
            children: [
              Image(
                image: payments[index].icon,
                width: 24,
                height: 24,
              ),
              const C(10),
              Text(
                payments[index].name,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  height: 24 / 14,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Checkbox(
                    value: payments[index].isSelect,
                    activeColor: Colors.deepOrange,
                    shape: const CircleBorder(),
                    onChanged: (value) {
                      if (mounted && value == true) {
                        setState(() {
                          for (var payment in payments) {
                            payment.isSelect =
                                payment.type == payments[index].type;
                          }
                        });
                      } else if (mounted && value == false) {
                        setState(() => payments[index].isSelect = false);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => const C(10),
    );
  }

  Widget buildBottomButton() {
    bool showButton = isAddCart ||
        (curSelectAddress != null &&
            hasEnoughInventory &&
            selectPaymentType != null);
    return showButton
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: InkWell(
              onTap: isAddCart ? addCart : createOrder,
              child: Container(
                width: screenSize.width - 16,
                height: 40,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: isAddCart ? Colors.deepOrange : null,
                  borderRadius: BorderRadius.circular(20),
                  gradient: !isAddCart
                      ? const LinearGradient(colors: [
                          Colors.orange,
                          Colors.deepOrange,
                        ])
                      : null,
                ),
                child: Text(
                  isAddCart ? '加入购物车' : '立即支付',
                  style: GoogleFonts.roboto(
                    height: 1.2,
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
        : const C(0);
  }

  Future<void> addCart() async {
    Response response = await DioClient.post(Api.addCart, {
      'productId': product.id,
      'number': curNumber,
    });
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Fluttertoast.showToast(msg: '添加成功');
        exit(true);
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
      }
    }
  }

  Future<void> createOrder() async {
    Response response = await DioClient.post(Api.addOrder, {
      'addressId': curSelectAddress!.id,
      'productId': product.id,
      'number': curNumber,
    });
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Fluttertoast.showToast(msg: '订单创建成功');
        String orderId = response.data['data'];
        bool success = await AlipayPlatform.payV2(product.price * curNumber);
        if (success) {
          Fluttertoast.showToast(msg: '支付成功');
          DioClient.post(Api.updateOrderStatus, {
            'orderId': orderId,
            'status': 1,
          });
        }
        exit(true);
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
      }
    }
  }

  void exit([bool? result]) => Navigator.pop(context, result);
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({
    Key? key,
    required this.errorMsg,
  }) : super(key: key);

  final String errorMsg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        errorMsg,
        style: GoogleFonts.roboto(
          height: 1.2,
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
