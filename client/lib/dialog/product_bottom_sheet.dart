import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class _Product {
  final String id;
  final String enterpriseId;
  final String name;
  String? coverUrl;
  final String? intro;
  bool status = false;
  final int inventory;
  final double price;

  _Product(this.id, this.enterpriseId, this.name, this.coverUrl, this.intro,
      this.status, this.inventory, this.price);

  factory _Product.copyFrom(_Product product) {
    return _Product(
      product.id,
      product.enterpriseId,
      product.name,
      product.coverUrl,
      product.intro,
      product.status,
      product.inventory,
      product.price,
    );
  }

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
    required this.enterpriseId,
  }) : super(key: key);

  final Size screenSize;
  final String enterpriseId;

  static Future<bool?> show(
    BuildContext context, {
    required Size screenSize,
    required String enterpriseId,
  }) async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductBottomSheet(
        screenSize: screenSize,
        enterpriseId: enterpriseId,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _ProductBottomSheetState();
}

class _ProductBottomSheetState extends State<ProductBottomSheet> {
  Size get screenSize => widget.screenSize;

  String get enterpriseId => widget.enterpriseId;

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

  void getProducts({
    RequestSuccessCallback<_Product>? successCall,
    VoidCallback? errorCall,
  }) {
    DioClient.get(Api.getEnterpriseProducts, {
      'enterpriseId': enterpriseId,
    }).then((response) {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          List<_Product> result = [];
          for (var product in response.data['data']) {
            _Product item = _Product(
              product['id'],
              product['enterpriseId'],
              product['name'],
              product['coverUrl'],
              product['intro'],
              product['status'],
              product['inventory'],
              product['price'],
            )..resetCoverUrl();
            result.add(item);
          }
          successCall?.call(result);
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
        color: Colors.white,
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
            '我的产品',
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: ColorName.gray8A8A8A),
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
                child: product.coverUrl == null
                    ? const DefaultProductWidget(size: 64)
                    : CachedNetworkImage(
                        imageUrl: product.coverUrl!,
                        fit: BoxFit.cover,
                      ),
              ),
              const C(20),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.roboto(
                      height: 1,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  if (product.intro != null) ...[
                    const C(4),
                    Text(
                      product.intro!,
                      style: GoogleFonts.roboto(
                        height: 1,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: ColorName.gray76787A,
                      ),
                    ),
                  ],
                  const C(8),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: '状态：',
                      style: GoogleFonts.roboto(
                        height: 1,
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: product.status == true ? '已上架' : '已下架',
                      style: GoogleFonts.roboto(
                        height: 1,
                        fontSize: 14,
                        color:
                            product.status == true ? Colors.green : Colors.red,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ])),
                  const C(8),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: '价格：',
                      style: GoogleFonts.roboto(
                        height: 1,
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: '¥${product.price}',
                      style: GoogleFonts.roboto(
                        height: 1,
                        fontSize: 14,
                        color: ColorName.yellowFFB52D,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ])),
                  const C(8),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: '库存：',
                      style: GoogleFonts.roboto(
                        height: 1,
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: product.inventory.toString(),
                      style: GoogleFonts.roboto(
                        height: 1,
                        fontSize: 14,
                        color:
                            product.inventory > 0 ? Colors.black : Colors.red,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ])),
                  const C(8),
                  Container(
                    width: screenSize.width - 124,
                    alignment: Alignment.centerRight,
                    child: buildControlButton(
                      title: product.status == true ? '下架' : '上架',
                      onTap: () async {
                        _Product temp = _Product.copyFrom(product);
                        temp.status = !product.status;
                        bool result = await editProductInfo(temp);
                        if (result && mounted) {
                          setState(() => product.status = temp.status);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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

  Future<bool> editProductInfo(_Product product) async {
    Response response = await DioClient.post(Api.updateProduct, {
      'productId': product.id,
      'name': product.name,
      if (product.coverUrl != null)
        'coverUrl':
            product.coverUrl!.substring(product.coverUrl!.lastIndexOf('=') + 1),
      if (product.intro != null) 'intro': product.intro,
      'status': product.status,
      'inventory': product.inventory,
      'price': product.price,
    });
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Fluttertoast.showToast(msg: '修改成功');
        return true;
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
        return false;
      }
    } else {
      return false;
    }
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
