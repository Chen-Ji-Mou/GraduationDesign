import 'package:city_pickers/city_pickers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class _Address {
  final String id;
  late String name;
  late String phone;
  late String area;
  late String fullAddress;

  _Address(this.id, this.name, this.phone, this.area, this.fullAddress);
}

enum _InfoType { name, phone, area, fullAddress }

class AddressScreen extends StatefulWidget {
  const AddressScreen({
    Key? key,
    required this.isSelect,
  }) : super(key: key);

  final bool isSelect;

  @override
  State<StatefulWidget> createState() => _AddressState();
}

class _AddressState extends State<AddressScreen> {
  bool get isSelect => widget.isSelect;

  final RefreshController refreshController = RefreshController();
  final List<_Address> addresses = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fullAddressController = TextEditingController();

  late Size screenSize;

  bool isAdding = false;
  bool isDeleting = false;
  String? area;

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
        setState(() => addresses.addAll(result));
      }
    });
  }

  void onRefresh() {
    getCarts(successCall: (result) {
      if (mounted) {
        setState(() => addresses
          ..clear()
          ..addAll(result));
      }
      refreshController.refreshCompleted();
    }, errorCall: () {
      refreshController.refreshFailed();
    });
  }

  void getCarts({
    required RequestSuccessCallback<_Address> successCall,
    VoidCallback? errorCall,
  }) {
    DioClient.get(Api.getAddresses).then((response) async {
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
    nameController.dispose();
    phoneController.dispose();
    fullAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      appBar: AppBar(
        backgroundColor: ColorName.grayF8F8F8,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          isAdding ? '添加收货地址' : '我的收货地址',
          style: GoogleFonts.roboto(
            height: 1,
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          if (!isSelect && !isAdding)
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () {
                  if (mounted) {
                    setState(() => isDeleting = !isDeleting);
                  }
                },
                child: Text(
                  !isDeleting ? '管理' : '完成',
                  style: GoogleFonts.roboto(
                    height: 1,
                    fontSize: 14,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: !isAdding
          ? Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  color: ColorName.grayF8F8F8,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ScrollConfiguration(
                    behavior: NoBoundaryRippleBehavior(),
                    child: SmartRefresher(
                      controller: refreshController,
                      enablePullDown: true,
                      enablePullUp: false,
                      onRefresh: onRefresh,
                      child: ListView.separated(
                        itemCount: addresses.length,
                        itemBuilder: buildAddressItem,
                        separatorBuilder: (context, index) => const C(8),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: buildBottom(),
                ),
              ],
            )
          : Container(
              color: Colors.white,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 14, top: 10, right: 14),
              child: Column(
                children: [
                  buildInfo(_InfoType.name),
                  const C(14),
                  buildInfo(_InfoType.phone),
                  const C(14),
                  buildInfo(_InfoType.area),
                  const C(14),
                  buildInfo(_InfoType.fullAddress),
                  const C(48),
                  InkWell(
                    onTap: addAddress,
                    child: Container(
                      width: screenSize.width - 44,
                      height: 40,
                      alignment: Alignment.center,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(colors: [
                          Colors.orange,
                          Colors.deepOrange,
                        ]),
                      ),
                      child: Text(
                        '保存',
                        style: GoogleFonts.roboto(
                          height: 1,
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
    return WillPopScope(
      onWillPop: () async {
        if (isAdding) {
          reset();
          setState(() => isAdding = false);
          return false;
        }
        return true;
      },
      child: child,
    );
  }

  Widget buildAddressItem(BuildContext context, int index) {
    _Address address = addresses[index];
    return InkWell(
      onTap: isSelect ? () => exit(address.id) : null,
      child: Container(
        width: screenSize.width - 12,
        padding: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
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
            const C(12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenSize.width - 72,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(TextSpan(
                                children: [
                                  TextSpan(
                                    text: address.name,
                                    style: GoogleFonts.roboto(
                                      fontSize: 15,
                                      height: 16 / 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${address.phone}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 13,
                                      height: 14 / 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              )),
                              const C(6),
                              Text(
                                '${address.area} ${address.fullAddress}',
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  height: 14 / 13,
                                  color: ColorName.gray8A8A8A,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const C(8),
                        if (!isSelect)
                          Assets.images.editIcon.image(width: 16, height: 16),
                      ],
                    ),
                  ),
                  if (isDeleting) ...[
                    const C(12),
                    Container(height: 1, color: ColorName.grayBFBFBF),
                    const C(12),
                    InkWell(
                      onTap: () => deleteAddress(address.id),
                      child: Container(
                        width: screenSize.width - 60,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '删除',
                          style: GoogleFonts.roboto(
                            height: 1,
                            fontSize: 14,
                            color: ColorName.gray8A8A8A,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottom() {
    return !isSelect
        ? Container(
            width: screenSize.width,
            padding:
                const EdgeInsets.only(left: 10, top: 6, right: 10, bottom: 16),
            color: Colors.white,
            child: InkWell(
              onTap: () {
                if (mounted) {
                  setState(() => isAdding = true);
                }
              },
              child: Container(
                width: screenSize.width - 20,
                height: 40,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(colors: [
                    Colors.orange,
                    Colors.deepOrange,
                  ]),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 16, color: Colors.white),
                    const C(4),
                    Text(
                      '添加收货地址',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        height: 20 / 16,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const C(0);
  }

  Widget buildInfo(_InfoType type) {
    String title;
    switch (type) {
      case _InfoType.name:
        title = '收货人';
        break;
      case _InfoType.phone:
        title = '手机号码';
        break;
      case _InfoType.area:
        title = '所在地区';
        break;
      case _InfoType.fullAddress:
        title = '详细地址';
        break;
    }
    TextEditingController? controller;
    switch (type) {
      case _InfoType.name:
        controller = nameController;
        break;
      case _InfoType.phone:
        controller = phoneController;
        break;
      case _InfoType.area:
        break;
      case _InfoType.fullAddress:
        controller = fullAddressController;
        break;
    }
    String hint;
    switch (type) {
      case _InfoType.name:
        hint = '收货人姓名';
        break;
      case _InfoType.phone:
        hint = '收货人手机号';
        break;
      case _InfoType.area:
        hint = '省、市、区';
        break;
      case _InfoType.fullAddress:
        hint = '小区楼栋/乡村名称';
        break;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: type == _InfoType.fullAddress
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: type == _InfoType.fullAddress ? 16 : 0),
          child: Text(
            title,
            style: GoogleFonts.roboto(
              height: 1,
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        InkWell(
          onTap: type == _InfoType.area
              ? () async {
                  Result? result =
                      await CityPickers.showCityPicker(context: context);
                  if (result != null && mounted) {
                    setState(() => area =
                        '${result.provinceName} ${result.cityName} ${result.areaName}');
                  }
                }
              : null,
          child: Container(
            width: (screenSize.width - 28) * 3 / 4,
            height: type == _InfoType.fullAddress ? 96 : 48,
            alignment: type == _InfoType.fullAddress
                ? Alignment.topLeft
                : Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: ColorName.grayF8F8F8,
              borderRadius: BorderRadius.circular(10),
            ),
            child: type == _InfoType.area
                ? Text(
                    area == null ? hint : area!,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.normal,
                      color: area == null ? ColorName.gray8A8A8A : Colors.black,
                      height: 16 / 14,
                      fontSize: 14,
                    ),
                  )
                : TextField(
                    controller: controller,
                    maxLines: [_InfoType.name, _InfoType.phone].contains(type)
                        ? 1
                        : null,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      height: 16 / 14,
                      fontSize: 14,
                    ),
                    textInputAction: TextInputAction.next,
                    cursorColor: Colors.deepOrange,
                    decoration: InputDecoration(
                      hintText: hint,
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.roboto(
                        fontWeight: FontWeight.normal,
                        color: ColorName.gray8A8A8A,
                        height: 16 / 14,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> deleteAddress(String addressId) async {
    Response response = await DioClient.post(Api.deleteAddress, {
      'addressId': addressId,
    });
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Fluttertoast.showToast(msg: '删除成功');
        onRefresh();
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
      }
    }
  }

  Future<void> addAddress() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        area == null ||
        fullAddressController.text.isEmpty) {
      Fluttertoast.showToast(msg: '请填写全部地址信息');
      return;
    }
    Response response = await DioClient.post(Api.addAddress, {
      'name': nameController.text,
      'phone': phoneController.text,
      'area': area,
      'fullAddress': fullAddressController.text,
    });
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Fluttertoast.showToast(msg: '添加成功');
        if (mounted) {
          setState(() {
            isAdding = false;
            reset();
            onRefresh();
          });
        }
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
      }
    }
  }

  void reset() {
    nameController.clear();
    phoneController.clear();
    fullAddressController.clear();
    area = null;
  }

  void exit([String? id]) => Navigator.pop(context, id);
}
