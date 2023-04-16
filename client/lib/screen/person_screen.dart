import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/mixin/lifecycle_observer.dart';
import 'package:graduationdesign/user_context.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({Key? key, this.onUserLogout}) : super(key: key);

  final VoidCallback? onUserLogout;

  @override
  State<StatefulWidget> createState() => _PersonState();
}

class _PersonState extends State<PersonScreen> with LifecycleObserver {
  VoidCallback? get onUserLogout => widget.onUserLogout;

  late Size screenSize;

  int balance = 0;
  int income = 0;
  int expenditure = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void onResume() {
    refreshBalance();
    refreshIncome();
    refreshExpenditure();
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
    return Container(
      alignment: Alignment.center,
      color: ColorName.whiteF5F6F7,
      child: Column(
        children: [
          const C(26),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ColorName.gray969696.withOpacity(0.3),
                  offset: const Offset(0, 20),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Assets.images.personDefault.image(
              width: 109,
              height: 109,
              fit: BoxFit.cover,
            ),
          ),
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
          Container(
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
                buildItem(
                  number: balance,
                  title: '余额',
                  onTap: () => Navigator.pushNamed(context, 'recharge'),
                ),
                buildItem(
                  number: income,
                  title: '总收入',
                  onTap: () => Navigator.pushNamed(context, 'details'),
                ),
                buildItem(
                  number: expenditure,
                  title: '总支出',
                  onTap: () => Navigator.pushNamed(context, 'details'),
                ),
              ],
            ),
          ),
          const C(26),
          InkWell(
            onTap: () async {
              bool isLogout = await UserContext.onUserLogout();
              if (isLogout) {
                Fluttertoast.showToast(msg: '已退出登录');
                onUserLogout?.call();
              }
            },
            child: Container(
              width: screenSize.width * 315 / 375,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '退出登录',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  height: 20 / 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem({
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
              color: ColorName.black35405A,
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
}
