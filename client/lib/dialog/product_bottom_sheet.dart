import 'package:cached_network_image/cached_network_image.dart';
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

class ProductBottomSheet extends StatefulWidget {
  const ProductBottomSheet({
    Key? key,
    required this.screenSize,
    required this.liveId,
  }) : super(key: key);

  final Size screenSize;
  final String liveId;

  static Future<bool?> show(
    BuildContext context, {
    required Size screenSize,
    required String liveId,
  }) async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductBottomSheet(
        screenSize: screenSize,
        liveId: liveId,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  Size get screenSize => widget.screenSize;

  String get liveId => widget.liveId;

  final RefreshController refreshController = RefreshController();
  final List<_Product> products = [];

  @override
  void initState() {
    super.initState();
    getProducts(successCall: (result) {
      if (mounted) {
        setState(() => products.addAll(result));
      }
    });
  }

  void onRefresh() {
    getProducts(successCall: (result) {
      if (mounted) {
        setState(() => products
          ..clear()
          ..addAll(result));
      }
      refreshController.refreshCompleted();
    }, errorCall: () {
      refreshController.refreshFailed();
    });
  }

  void getProducts({
    required RequestSuccessCallback<_Product> successCall,
    VoidCallback? errorCall,
  }) {
    DioClient.get(Api.getLiveProducts, {
      'liveId': liveId,
    }).then((response) async {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          List<_Product> result = [];
          for (var product in response.data['data']) {
            if (product['status'] == true) {
              _Product item = _Product(
                product['id'],
                product['enterpriseId'],
                product['name'],
                product['coverUrl'],
                product['intro'],
                product['inventory'],
                product['price'],
              )..resetCoverUrl();
              result.add(item);
            }
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

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: ColorName.grayF5F5F5,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const C(8),
          buildHeader(),
          buildProductList(),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        const C(16),
        InkWell(
          onTap: exit,
          child: const Icon(
            Icons.close,
            size: 24,
            color: ColorName.black333333,
          ),
        ),
        Container(
          height: 48,
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: screenSize.width / 2 - 64),
          child: Text(
            '正在热卖',
            style: GoogleFonts.roboto(
              height: 1.2,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorName.black333333,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProductList() {
    return SizedBox(
      height: screenSize.height * 2 / 3,
      child: ScrollConfiguration(
        behavior: NoBoundaryRippleBehavior(),
        child: SmartRefresher(
          controller: refreshController,
          enablePullDown: true,
          enablePullUp: false,
          onRefresh: onRefresh,
          child: products.isNotEmpty
              ? ListView.builder(
                  itemCount: products.length,
                  itemBuilder: buildProductItem,
                )
              : const _ProductEmptyWidget(),
        ),
      ),
    );
  }

  Widget buildProductItem(BuildContext context, int index) {
    _Product product = products[index];
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 8),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 96,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorName.gray76787A),
            ),
            child: product.coverUrl == null
                ? const DefaultProductWidget(size: 96)
                : CachedNetworkImage(
                    imageUrl: product.coverUrl!,
                    fit: BoxFit.cover,
                  ),
          ),
          const C(8),
          Container(
            width: screenSize.width - 124,
            height: 96,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.roboto(
                    height: 1,
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                if (product.intro != null) ...[
                  const C(4),
                  Text(
                    product.intro!,
                    style: GoogleFonts.roboto(
                      height: 1,
                      fontSize: 12,
                      color: ColorName.gray76787A,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '¥${product.price}',
                          style: GoogleFonts.roboto(
                            height: 1,
                            fontSize: 16,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.bottomRight,
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              height: 32,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      UserContext.checkLoginCallback(context,
                                          () {
                                        CreateOrderBottomSheet.show(
                                          context,
                                          screenSize: screenSize,
                                          productId: product.id,
                                          from: Position.live,
                                          isAddCart: true,
                                        );
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(
                                        left: 14,
                                        right: 8,
                                      ),
                                      color: Colors.orange,
                                      child: const Icon(
                                        Icons.add_shopping_cart,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      UserContext.checkLoginCallback(context,
                                          () {
                                        CreateOrderBottomSheet.show(
                                          context,
                                          screenSize: screenSize,
                                          productId: product.id,
                                          from: Position.live,
                                        );
                                      });
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        right: 14,
                                      ),
                                      color: Colors.deepOrange,
                                      child: Text(
                                        '马上抢',
                                        style: GoogleFonts.roboto(
                                          height: 1.2,
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
        ],
      ),
    );
  }

  void exit() => Navigator.pop(context);
}

class _ProductEmptyWidget extends StatelessWidget {
  const _ProductEmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.imgProductEmpty.image(fit: BoxFit.cover),
          Text(
            '当前没有产品信息',
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
