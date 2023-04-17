import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/platform/file_load_platform.dart';
import 'package:graduationdesign/platform/permission_platform.dart';
import 'package:graduationdesign/route.dart';
import 'package:graduationdesign/screen/splash_screen.dart';
import 'package:graduationdesign/sp_manager.dart';
import 'package:graduationdesign/user_context.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  runApp(const MyApp());
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<void> init() async {
    requestPermissionSuccess = await PermissionPlatform.requestPermission();
    loadFileSuccess = await FileLoadPlatform.loadFile();
    spInitSuccess = await SpManager.init();
    getUserInfoSuccess = await UserContext.getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return buildRoute();
        } else {
          return const SplashScreen();
        }
      },
    );
  }

  Widget buildRoute() {
    return RefreshConfiguration(
      // 配置默认头部指示器
      headerBuilder: () => const WaterDropHeader(),
      // 配置默认底部指示器
      footerBuilder: () => const ClassicFooter(),
      // Viewport不满一屏时,禁用上拉加载更多功能
      hideFooterWhenNotFull: true,
      // 可以通过惯性滑动触发加载更多
      enableBallisticLoad: true,
      child: MaterialApp(
        initialRoute: 'root',
        navigatorObservers: [routeObserver],
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
