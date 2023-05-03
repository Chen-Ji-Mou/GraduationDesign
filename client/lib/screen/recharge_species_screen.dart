import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/platform/alipay_platform.dart';

class RechargeSpeciesScreen extends StatefulWidget {
  const RechargeSpeciesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RechargeSpeciesState();
}

class _RechargeSpeciesState extends State<RechargeSpeciesScreen> {
  final List<_Option> options = [
    _Option(quantity: 60, price: 6),
    _Option(quantity: 180, price: 18),
    _Option(quantity: 300, price: 30),
    _Option(quantity: 500, price: 50),
    _Option(quantity: 1000, price: 100),
    _Option(quantity: 2000, price: 200),
  ];

  late Size screenSize;

  int balance = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void initState() {
    super.initState();
    refreshBalance();
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
          '充值金币',
          style: GoogleFonts.roboto(
            color: Colors.black.withOpacity(0.9),
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(left: 10, right: 10),
        color: Colors.white.withOpacity(0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const C(20),
            Row(
              children: [
                Text(
                  '余额: $balance金币',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    height: 16 / 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.9),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, 'details'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '明细',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.normal,
                              color: Colors.black.withOpacity(0.9),
                            ),
                          ),
                          Assets.images.right.image(width: 12, height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const C(30),
            Container(
              constraints: BoxConstraints(
                maxHeight: (screenSize.width - 40) / 3 / 0.9 * 2 + 20,
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: options.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () => recharge(options[index]),
                  child: Container(
                    width: (screenSize.width - 40) / 3,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6,),
                    decoration: BoxDecoration(
                      color: ColorName.yellowFFB52D.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        options[index].icon,
                        const C(8),
                        Text(
                          '${options[index].quantity}金币',
                          style: GoogleFonts.roboto(
                            height: 1,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.black.withOpacity(0.9),
                          ),
                        ),
                        const C(16),
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorName.yellowFFB52D.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '¥ ${options[index].price}',
                            style: GoogleFonts.roboto(
                              height: 1,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const C(16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '什么是金币',
                  style: GoogleFonts.roboto(
                    height: 1,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.black.withOpacity(0.9),
                  ),
                ),
                const C(8),
                Text(
                  '1、 金币是直播定制APP平台推出的虚拟货币，目前仅支持通过充值获得',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: ColorName.gray76787A,
                  ),
                ),
                const C(8),
                Text(
                  '2、 金币目前可用于直播打赏，后续功能会逐步开发完善',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: ColorName.gray76787A,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> recharge(_Option option) async {
    bool paySuccess = await AlipayPlatform.payV2(option.price);
    if (paySuccess) {
      Fluttertoast.showToast(msg: '支付成功');
      await Future.wait([
        DioClient.post(Api.rechargeAccount, {'amount': option.quantity}),
        DioClient.post(
            Api.addDetail, {'income': option.quantity, 'expenditure': 0}),
      ]);
      refreshBalance();
    } else {
      Fluttertoast.showToast(msg: '支付失败，请重试');
    }
  }
}

class _Option {
  final Widget icon = Assets.images.species.image(width: 24, height: 24);
  final int quantity;
  final int price;

  _Option({required this.quantity, required this.price});
}
