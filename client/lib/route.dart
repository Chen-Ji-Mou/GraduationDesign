import 'package:flutter/material.dart';
import 'package:graduationdesign/screen/home_screen.dart';
import 'package:graduationdesign/screen/initiate_live_screen.dart';
import 'package:graduationdesign/screen/watch_live_screen.dart';

RouteObserver<Route<void>> routeObserver = RouteObserver<Route<void>>();

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  String? routeName = routeBefore(settings);
  return MaterialPageRoute(builder: (context) {
    /// 注意：如果路由的形式为: '/a/b/c'
    /// 那么系统将依次检索 '/' -> '/a' -> '/a/b' -> '/a/b/c'
    /// 为了避免这种检索方式，所以路由使用 'xxx' 形式
    switch (routeName) {
      case 'home':
        return const HomeScreen();
      case 'initiateLive':
        return const InitiateLiveScreen();
      case 'watchLive':
        return WatchLiveScreen(liveId: settings.arguments as int);
      default:
        return const Scaffold(
          body: Center(
            child: Text("页面不存在"),
          ),
        );
    }
  });
}

String? routeBefore(RouteSettings settings) {
  String? routeName = settings.name;
  if (needCheckRoutes.contains(routeName)) {
    // TODO 检验用户是否登录进行拦截
    return null;
  }
  return routeName;
}

List<String> needCheckRoutes = [];
