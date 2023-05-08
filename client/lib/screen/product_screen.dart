import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/mixin/lifecycle_observer.dart';
import 'package:graduationdesign/user_context.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef _SuccessCallback = void Function(List<_Product> details);
typedef _ErrorCallback = void Function();

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProductState();
}

class _ProductState extends State<ProductScreen> with LifecycleObserver {
  final RefreshController refreshController = RefreshController();
  final List<_Product> products = [];

  late Size screenSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void onResume() {
    getProducts(successCall: (result) {
      if (mounted) {
        setState(() => products
          ..clear()
          ..addAll(result));
      }
    });
  }

  void getProducts({
    _SuccessCallback? successCall,
    _ErrorCallback? errorCall,
  }) {
    DioClient.get(Api.getEnterpriseProducts, {
      'enterpriseId': UserContext.enterpriseId,
    }).then((response) {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          List<_Product> result = [];
          for (var product in response.data['data']) {
            _Product item = _Product(
              product['id'],
              product['name'],
              product['coverUrl'],
              product['intro'],
              product['status'],
              product['inventory'],
            )..setCoverUrl();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          '我的产品',
          style: GoogleFonts.roboto(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: ScrollConfiguration(
          behavior: NoBoundaryRippleBehavior(),
          child: SmartRefresher(
            controller: refreshController,
            enablePullDown: true,
            enablePullUp: false,
            onRefresh: onRefresh,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: buildProductItem,
            ),
          ),
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
              SizedBox(
                height: 112,
                child: Column(
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
                        text: product.status ? '已上架' : '已下架',
                        style: GoogleFonts.roboto(
                          height: 1,
                          fontSize: 14,
                          color: product.status ? Colors.green : Colors.red,
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
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            buildControlButton(
                              title: '修改信息',
                            ),
                            const C(6),
                            buildControlButton(
                              title: product.status ? '下架' : '上架',
                            ),
                            const C(6),
                            buildControlButton(
                              title: '修改库存',
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
}

class _Product {
  final String id;
  final String name;
  String? coverUrl;
  String? intro;
  final bool status;
  final int inventory;

  _Product(this.id, this.name, this.coverUrl, this.intro, this.status,
      this.inventory);

  void setCoverUrl() {
    if (coverUrl != null) {
      coverUrl =
          'http://${Api.host}:${Api.port}/product/downloadCover?fileName=$coverUrl';
    }
  }
}
