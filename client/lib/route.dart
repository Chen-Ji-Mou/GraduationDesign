import 'package:flutter/material.dart';
import 'package:graduationdesign/root_node.dart';
import 'package:graduationdesign/screen/start_live_screen.dart';
import 'package:graduationdesign/screen/login_screen.dart';
import 'package:graduationdesign/screen/register_screen.dart';
import 'package:graduationdesign/screen/retrieve_pwd_screen.dart';
import 'package:graduationdesign/screen/enter_live_screen.dart';

RouteObserver<Route<void>> routeObserver = RouteObserver<Route<void>>();

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  String? routeName = routeBefore(settings);
  return MaterialPageRoute(builder: (context) {
    /// 注意：如果路由的形式为: '/a/b/c'
    /// 那么系统将依次检索 '/' -> '/a' -> '/a/b' -> '/a/b/c'
    /// 为了避免这种检索方式，所以路由使用 'xxx' 形式
    switch (routeName) {
      case 'root':
        return const RootNode();
      case 'login':
        return const LoginScreen();
      case 'retrievePwd':
        return const RetrievePwdScreen();
      case 'register':
        return const RegisterScreen();
      case 'startLive':
        return const StartLiveScreen();
      case 'enterLive':
        return EnterLiveScreen(liveId: settings.arguments as int);
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
  if (needCheckLoginRoutes.contains(routeName)) {
    return 'login';
  }
  return routeName;
}

List<String> needCheckLoginRoutes = [];
