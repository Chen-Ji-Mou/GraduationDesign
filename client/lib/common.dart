import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:lottie/lottie.dart';

double toolbarHeight = 0;

void afterRender(VoidCallback callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) => callback);
}

Future<void> waitRender() {
  final Completer<void> completer = Completer<void>();
  afterRender(() => completer.complete());
  return completer.future;
}

class C extends StatelessWidget {
  const C(this.size, {Key? key}) : super(key: key);

  final double? size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size);
  }
}

extension StandardExt<T> on T {
  R let<R>(R Function(T) block) {
    return block(this);
  }

  T also<R>(Function(T) block) {
    block(this);
    return this;
  }
}

String mapToJsonString(Map<String, dynamic> map) => json.encode(map);

/// 验证身份证号是否合法
bool verifyCardId(String cardId) {
  const Map city = {
    11: "北京",
    12: "天津",
    13: "河北",
    14: "山西",
    15: "内蒙古",
    21: "辽宁",
    22: "吉林",
    23: "黑龙江",
    31: "上海",
    32: "江苏",
    33: "浙江",
    34: "安徽",
    35: "福建",
    36: "江西",
    37: "山东",
    41: "河南",
    42: "湖北",
    43: "湖南",
    44: "广东",
    45: "广西",
    46: "海南",
    50: "重庆",
    51: "四川",
    52: "贵州",
    53: "云南",
    54: "西藏",
    61: "陕西",
    62: "甘肃",
    63: "青海",
    64: "宁夏",
    65: "新疆",
    71: "台湾",
    81: "香港",
    82: "澳门",
    91: "国外",
  };
  bool pass = true;

  RegExp cardReg = RegExp(
      r'^\d{6}(18|19|20)?\d{2}(0[1-9]|1[012])(0[1-9]|[12]\d|3[01])\d{3}(\d|X)$');
  if (cardId.isEmpty || !cardReg.hasMatch(cardId)) {
    return false;
  }
  if (city[int.parse(cardId.substring(0, 2))] == null) {
    return false;
  }
  // 18位身份证需要验证最后一位校验位，15位不检测了，现在也没15位的了
  if (cardId.length == 18) {
    List numList = cardId.split('');
    //∑(ai×Wi)(mod 11)
    //加权因子
    List factor = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
    //校验位
    List parity = [1, 0, 'X', 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    int ai = 0;
    int wi = 0;
    for (var i = 0; i < 17; i++) {
      ai = int.parse(numList[i]);
      wi = factor[i];
      sum += ai * wi;
    }
    if (parity[sum % 11].toString() != numList[17]) {
      pass = false;
    }
  } else {
    pass = false;
  }
  return pass;
}

bool verifyEmail(String email) {
  String rule =
      '^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$';
  return RegExp(rule).hasMatch(email);
}

class NoBoundaryRippleBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Theme.of(context).colorScheme.secondary,
      showTrailing: false,
      showLeading: false,
      child: child,
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/anim/loading.json',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({Key? key, this.onRetry}) : super(key: key);

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.error.image(fit: BoxFit.cover),
          const C(24),
          ElevatedButton(
            onPressed: () => onRetry?.call(),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
}
