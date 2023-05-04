import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/mixin/lifecycle_observer.dart';
import 'package:graduationdesign/user_context.dart';
import 'package:image_picker/image_picker.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({Key? key, this.onUserLogout}) : super(key: key);

  final VoidCallback? onUserLogout;

  @override
  State<StatefulWidget> createState() => _PersonState();
}

class _PersonState extends State<PersonScreen>
    with LifecycleObserver, AutomaticKeepAliveClientMixin {
  VoidCallback? get onUserLogout => widget.onUserLogout;

  bool get isEnterprise => UserContext.isEnterprise;

  late Size screenSize;

  int balance = 0;
  int income = 0;
  int expenditure = 0;
  bool exiting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void onResume() {
    if (UserContext.isLogin && !exiting) {
      refreshBalance();
      refreshIncome();
      refreshExpenditure();
      UserContext.refreshUser().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
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

  void refreshIncome() {
    DioClient.get(Api.getTotalIncome).then((response) {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          if (mounted) {
            setState(() => income = response.data['data']);
          }
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
        }
      }
    });
  }

  void refreshExpenditure() {
    DioClient.get(Api.getTotalExpenditure).then((response) {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          if (mounted) {
            setState(() => expenditure = response.data['data']);
          }
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      alignment: Alignment.center,
      color: ColorName.whiteF5F6F7,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              const C(26),
              buildAvatar(),
              const C(26),
              Text(
                UserContext.name,
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorName.black35405A,
                ),
              ),
              Text(
                UserContext.email,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColorName.grayB2B6C0,
                ),
              ),
              const C(24),
              buildStatusBar(),
              const C(48),
              buildOptionList(),
            ],
          ),
          Positioned(
            top: 20,
            right: 24,
            child: InkWell(
              onTap: logout,
              child: Assets.images.logoutIcon.image(
                width: 24,
                height: 24,
                color: ColorName.black35405A,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAvatar() {
    return InkWell(
      onTap: uploadAvatar,
      child: Stack(
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorName.gray969696.withOpacity(0.3),
                  offset: const Offset(10, 20),
                  blurRadius: 10,
                ),
              ],
            ),
            child: UserContext.avatarUrl.isEmpty
                ? const DefaultAvatarWidget(
                    width: 109,
                    height: 109,
                    iconSize: 64,
                  )
                : CachedNetworkImage(
                    imageUrl: UserContext.avatarUrl,
                    width: 109,
                    height: 109,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const LoadingWidget(),
                  ),
          ),
          if (isEnterprise)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: ColorName.yellowFFB52D,
                  shape: BoxShape.circle,
                ),
                child: Assets.images.authIcon.image(
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildStatusBar() {
    return Container(
      width: screenSize.width * 315 / 375,
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: ColorName.gray969696.withOpacity(0.3),
            offset: const Offset(10, 20),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildStatusBarItem(
            number: balance,
            title: '余额',
            onTap: () => Navigator.pushNamed(context, 'recharge'),
          ),
          buildStatusBarItem(
            number: income,
            title: '总充值',
            onTap: () => Navigator.pushNamed(context, 'details'),
          ),
          buildStatusBarItem(
            number: expenditure,
            title: '总消费',
            onTap: () => Navigator.pushNamed(context, 'details'),
          ),
        ],
      ),
    );
  }

  Widget buildStatusBarItem({
    required int number,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number.toString(),
            style: GoogleFonts.robotoCondensed(
              fontSize: 20,
              height: 21 / 20,
              fontWeight: FontWeight.bold,
              color: ColorName.yellowFFB52D,
            ),
          ),
          const C(2),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 12,
              height: 18 / 12,
              fontWeight: FontWeight.w500,
              color: ColorName.black35405A,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOptionList() {
    return Container(
      width: screenSize.width * 315 / 375,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: ColorName.gray969696.withOpacity(0.3),
            offset: const Offset(10, 20),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildOptionListItem(
            icon: Assets.images.orderIcon.provider(),
            title: '我的订单',
          ),
          const Divider(height: 1, indent: 8),
          if (!isEnterprise) ...[
            buildOptionListItem(
              onTap: () async {
                bool? result =
                    await Navigator.pushNamed(context, 'enterpriseAuth');
                if (result == true) {
                  Fluttertoast.showToast(msg: '认证商家成功');
                  await UserContext.refreshUser();
                  if (mounted) {
                    setState(() {});
                  }
                }
              },
              icon: Assets.images.authIcon.provider(),
              title: '商家认证',
            ),
          ] else ...[
            buildOptionListItem(
              icon: Assets.images.productIcon.provider(),
              title: '我的产品',
            ),
          ],
        ],
      ),
    );
  }

  Widget buildOptionListItem({
    required ImageProvider icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Image(
              image: icon,
              width: 24,
              height: 24,
              color: ColorName.yellowFFB52D,
            ),
            const C(8),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 14,
                height: 24 / 14,
                fontWeight: FontWeight.w500,
                color: ColorName.black35405A,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> uploadAvatar() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    String? imagePath = image?.path;
    if (imagePath != null) {
      DioClient.post(Api.uploadAvatar, {
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
            await UserContext.refreshUser();
            if (mounted) {
              setState(() {});
            }
          } else {
            Fluttertoast.showToast(msg: response.data['msg']);
          }
        }
      });
    }
  }

  Future<void> logout() async {
    exiting = true;
    bool isConfirm = await showAlert();
    if (isConfirm) {
      bool isLogout = await UserContext.onUserLogout();
      if (isLogout) {
        Fluttertoast.showToast(msg: '已退出登录');
        onUserLogout?.call();
      }
    } else {
      exiting = false;
    }
  }

  Future<bool> showAlert() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('提示'),
            content: const Text('是否要退出当前账号？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('是的'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('点错了'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  bool get wantKeepAlive => UserContext.isLogin;
}
