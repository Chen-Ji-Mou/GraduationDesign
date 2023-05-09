import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/mixin/lifecycle_observer.dart';
import 'package:graduationdesign/user_context.dart';
import 'package:graduationdesign/widget/text_form_field_widget.dart';
import 'package:image_picker/image_picker.dart';
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
  void initState() {
    super.initState();
    getProducts(successCall: (result) {
      if (mounted) {
        setState(() => products.addAll(result));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
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
            _Product item = _Product(product['id']);
            item.name = product['name'];
            item.coverUrl = product['coverUrl'];
            item.intro = product['intro'];
            item.status = product['status'];
            item.inventory = product['inventory'];
            item.price = product['price'];
            item.resetCoverUrl();
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
        actions: [
          InkWell(
            onTap: () async {
              _EmptyProduct product = _EmptyProduct();
              bool isAdd = await showAddProductAlert(product);
              if (isAdd) {
                bool success = await addProduct(product);
                if (success) {
                  onRefresh();
                }
              }
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.add_box, size: 24, color: Colors.black),
            ),
          ),
        ],
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
    return InkWell(
      onLongPress: () async {
        bool result = await showDeleteConfirmAlert();
        if (result) {
          bool success = await deleteProduct(product.id);
          if (success) {
            onRefresh();
          }
        }
      },
      child: Container(
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
                          color: product.status == true
                              ? Colors.green
                              : Colors.red,
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
                    const C(12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        buildControlButton(
                          title: '修改信息',
                          onTap: () async {
                            _Product temp = _Product.copyFrom(product);
                            bool isEdit = await showEditInfoAlert(temp);
                            if (isEdit) {
                              bool result = await editProductInfo(temp);
                              if (result && mounted) {
                                setState(() {
                                  product.name = temp.name;
                                  product.intro = temp.intro;
                                  product.coverUrl = temp.coverUrl;
                                });
                              }
                            }
                          },
                        ),
                        const C(6),
                        buildControlButton(
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
                        const C(6),
                        buildControlButton(
                          title: '修改库存',
                          onTap: () async {
                            _Product temp = _Product.copyFrom(product);
                            bool isEdit = await showEditInventoryAlert(temp);
                            if (isEdit) {
                              bool result = await editProductInfo(temp);
                              if (result && mounted) {
                                setState(
                                    () => product.inventory = temp.inventory);
                              }
                            }
                          },
                        ),
                      ],
                    ),
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

  Future<bool> addProduct(_EmptyProduct product) async {
    Response response = await DioClient.post(Api.addProduct, {
      'enterpriseId': UserContext.enterpriseId,
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
        Fluttertoast.showToast(msg: '添加成功');
        return true;
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    Response response = await DioClient.post(Api.deleteProduct, {
      'productId': productId,
    });
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Fluttertoast.showToast(msg: '删除成功');
        return true;
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
        return false;
      }
    } else {
      return false;
    }
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

  Future<bool> showDeleteConfirmAlert() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('提示'),
            content: const Text('是否要删除此产品，删除后不可恢复'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确定'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> showAddProductAlert(_EmptyProduct product) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: _EditProductInfoWidget(
              screenSize: screenSize,
              product: product,
              isAdd: true,
            ),
          ),
        ) ??
        false;
  }

  Future<bool> showEditInfoAlert(_Product product) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: _EditProductInfoWidget(
              screenSize: screenSize,
              product: product,
            ),
          ),
        ) ??
        false;
  }

  Future<bool> showEditInventoryAlert(_Product product) async {
    TextEditingController editController =
        TextEditingController(text: product.inventory.toString());
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('请输入库存数量'),
            content: SizedBox(
              height: 48,
              child: TextFormFieldWidget(
                controller: editController,
                hintText: '请输入整数，例如1、10',
                borderColor: Colors.black,
                cursorColor: Colors.black,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  int? input = int.tryParse(editController.text);
                  if (input != null) {
                    product.inventory = input;
                    Navigator.pop(context, true);
                  } else {
                    Fluttertoast.showToast(msg: '请输入整数');
                  }
                },
                child: const Text('确定'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _EditProductInfoWidget extends StatefulWidget {
  const _EditProductInfoWidget({
    Key? key,
    required this.screenSize,
    required this.product,
    this.isAdd = false,
  }) : super(key: key);

  final Size screenSize;
  final _EmptyProduct product;
  final bool isAdd;

  @override
  State<StatefulWidget> createState() => _EditProductInfoState();
}

class _EditProductInfoState extends State<_EditProductInfoWidget> {
  Size get screenSize => widget.screenSize;

  _EmptyProduct get product => widget.product;

  bool get isAdd => widget.isAdd;

  final double width = 280;

  late TextEditingController nameController;
  late TextEditingController introController;
  late TextEditingController inventoryController;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: !isAdd ? product.name : null,
    );
    introController = TextEditingController(
      text: !isAdd ? product.intro : null,
    );
    inventoryController = TextEditingController(
      text: !isAdd ? product.inventory.toString() : null,
    );
    priceController = TextEditingController(
      text: !isAdd ? product.price.toString() : null,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    introController.dispose();
    inventoryController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAdd ? '填写产品信息' : '修改产品信息',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const C(12),
                SizedBox(
                  height: 40,
                  child: TextFormFieldWidget(
                    controller: nameController,
                    hintText: '产品名称',
                    borderColor: Colors.black,
                    cursorColor: Colors.black,
                  ),
                ),
                const C(8),
                SizedBox(
                  height: 40,
                  child: TextFormFieldWidget(
                    controller: introController,
                    hintText: '产品简介',
                    borderColor: Colors.black,
                    cursorColor: Colors.black,
                    maxLines: 2,
                  ),
                ),
                const C(8),
                SizedBox(
                  height: 40,
                  child: TextFormFieldWidget(
                    controller: priceController,
                    hintText: '产品价格',
                    borderColor: Colors.black,
                    cursorColor: Colors.black,
                  ),
                ),
                if (isAdd) ...[
                  const C(8),
                  SizedBox(
                    height: 40,
                    child: TextFormFieldWidget(
                      controller: inventoryController,
                      hintText: '产品库存，请输入整数',
                      borderColor: Colors.black,
                      cursorColor: Colors.black,
                    ),
                  ),
                  const C(8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '是否上架',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const C(8),
                      Switch(
                        value: product.status,
                        onChanged: (value) {
                          if (mounted) {
                            setState(() => product.status = value);
                          }
                        },
                      ),
                    ],
                  ),
                ],
                const C(8),
                Text(
                  '产品封面（点击上传封面）',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                const C(4),
                InkWell(
                  onTap: uploadProductCover,
                  child: Container(
                    width: width - 32,
                    height: (width - 32) * 460 / 650,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: product.coverUrl == null
                        ? const DefaultProductWidget(size: 200)
                        : CachedNetworkImage(
                            imageUrl: product.coverUrl!,
                            width: width - 32,
                            height: (width - 32) * 460 / 650,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const C(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => exit(result: true),
                      child: const Text('确定'),
                    ),
                    const C(8),
                    TextButton(
                      onPressed: () => exit(result: false),
                      child: const Text('取消'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> uploadProductCover() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    String? imagePath = image?.path;
    if (imagePath != null) {
      DioClient.post(Api.uploadProductCover, {
        'enterpriseId': UserContext.enterpriseId,
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.substring(
            imagePath.lastIndexOf('/') + 1,
          ),
        ),
      }).then((response) async {
        if (response.statusCode == 200 && response.data != null) {
          if (response.data['code'] == 200) {
            Fluttertoast.showToast(msg: '上传成功');
            if (mounted) {
              setState(() {
                product.coverUrl =
                    'http://${Api.host}:${Api.port}/product/downloadCover?fileName=${response.data['data']}';
              });
            }
          } else {
            Fluttertoast.showToast(msg: response.data['msg']);
          }
        }
      });
    }
  }

  void exit({required bool result}) {
    if (result) {
      if (nameController.text.isEmpty) {
        Fluttertoast.showToast(msg: '请输入产品名称');
        return;
      } else {
        product.name = nameController.text;
      }
      product.intro = introController.text;
      int? inventory = int.tryParse(inventoryController.text);
      if (inventory != null) {
        product.inventory = inventory;
      } else {
        Fluttertoast.showToast(msg: '产品库存请输入整数');
        inventoryController.clear();
        return;
      }
      double? price = double.tryParse(priceController.text);
      if (price != null) {
        product.price = price;
      } else {
        Fluttertoast.showToast(msg: '请输入正确的产品价格');
        priceController.clear();
        return;
      }
    }
    Navigator.pop(context, result);
  }
}

class _EmptyProduct {
  late String name;
  String? coverUrl;
  String? intro;
  bool status = false;
  late int inventory;
  late double price;
}

class _Product extends _EmptyProduct {
  final String id;

  _Product(this.id);

  factory _Product.copyFrom(_Product product) {
    _Product newProduct = _Product(product.id);
    newProduct.name = product.name;
    newProduct.coverUrl = product.coverUrl;
    newProduct.intro = product.intro;
    newProduct.status = product.status;
    newProduct.inventory = product.inventory;
    newProduct.price = product.price;
    return newProduct;
  }

  void resetCoverUrl() {
    if (coverUrl != null) {
      coverUrl =
          'http://${Api.host}:${Api.port}/product/downloadCover?fileName=$coverUrl';
    }
  }
}
