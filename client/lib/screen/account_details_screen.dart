import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/mixin/lifecycle_observer.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef _SuccessCallback = void Function(List<_Detail> details);
typedef _ErrorCallback = void Function();

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetailsScreen>
    with LifecycleObserver {
  final RefreshController controller = RefreshController();
  final int pageSize = 10;

  late Size screenSize;

  List<_Detail> details = [];
  int pageNum = 0;
  int balance = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void onResume() {
    getBalance();
    getDetails(successCall: (result) {
      if (mounted) {
        setState(() => details
          ..clear()
          ..addAll(result)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)));
      }
    });
  }

  void getBalance() {
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

  void getDetails({_SuccessCallback? successCall, _ErrorCallback? errorCall}) {
    DioClient.get(Api.getDetail, {
      'pageNum': pageNum,
      'pageSize': pageSize,
    }).then((response) {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          List<_Detail> result = [];
          for (var detail in response.data['data']) {
            _Detail item = _Detail(
              detail['id'],
              detail['income'],
              detail['expenditure'],
              detail['timestamp'],
            )..transformTimestamp();
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

  void onLoading() {
    pageNum++;
    getDetails(successCall: (result) {
      if (mounted) {
        setState(() => details
          ..addAll(result)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)));
      }
      controller.loadComplete();
    }, errorCall: () {
      controller.loadComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black.withOpacity(0.9),
        ),
        title: Text(
          '账户明细',
          style: GoogleFonts.roboto(
            color: Colors.black.withOpacity(0.9),
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.white.withOpacity(0.9),
        child: Column(
          children: [
            buildHeader(),
            Expanded(
              child: ScrollConfiguration(
                behavior: NoBoundaryRippleBehavior(),
                child: SmartRefresher(
                  controller: controller,
                  enablePullDown: false,
                  enablePullUp: true,
                  onLoading: onLoading,
                  child: ListView.builder(
                    itemCount: details.length,
                    itemBuilder: (context, index) => buildItem(index),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, 'recharge'),
      child: Container(
        width: screenSize.width,
        height: screenSize.height / 7,
        decoration: BoxDecoration(
          color: ColorName.yellowFFB52D.withOpacity(0.9),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 24,
              top: 36,
              child: Text(
                balance.toString(),
                style: GoogleFonts.roboto(
                  height: 1,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            Positioned(
              left: 24,
              top: 72,
              child: Text(
                '我的金币',
                style: GoogleFonts.roboto(
                  height: 1,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            Positioned(
              right: 24,
              top: 36,
              child: Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '充值',
                  style: GoogleFonts.roboto(
                    height: 1,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: ColorName.yellowFFB52D.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(int index) {
    _Detail detail = details[index];
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        top: 24,
        bottom: index == details.length - 1 ? 24 : 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.income == 0
                ? '送礼物消费${detail.expenditure}金币'
                : '充值获得${detail.income}金币',
            style: GoogleFonts.roboto(
              height: 1,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black.withOpacity(0.9),
            ),
          ),
          const C(6),
          Text(
            detail.date,
            style: GoogleFonts.roboto(
              height: 1,
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: ColorName.gray76787A,
            ),
          ),
        ],
      ),
    );
  }
}

class _Detail {
  final String id;
  final int income;
  final int expenditure;
  final int timestamp;
  late String date;

  _Detail(this.id, this.income, this.expenditure, this.timestamp);

  void transformTimestamp() {
    date = DateTime.fromMillisecondsSinceEpoch(timestamp)
        .toLocal()
        .toString()
        .substring(0, 16);
  }
}
