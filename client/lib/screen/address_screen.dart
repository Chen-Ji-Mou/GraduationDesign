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

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddressState();
}

class _AddressState extends State<AddressScreen> {
  final RefreshController refreshController = RefreshController();
  final List<_Address> addresses = [];

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
          '我的收货地址',
          style: GoogleFonts.roboto(
            height: 1,
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 12),
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
        ],
      ),
      body: Container(
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
    );
  }

  Widget buildAddressItem(BuildContext context, int index) {
    _Address address = addresses[index];
    return Container(
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
                      Assets.images.editIcon.image(width: 16, height: 16),
                    ],
                  ),
                ),
                if (isEditing) ...[
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
}
