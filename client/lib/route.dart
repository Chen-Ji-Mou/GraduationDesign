import 'package:flutter/material.dart';
import 'package:graduationdesign/root_node.dart';
import 'package:graduationdesign/screen/account_details_screen.dart';
import 'package:graduationdesign/screen/recharge_species_screen.dart';
import 'package:graduationdesign/screen/route_not_found_screen.dart';
import 'package:graduationdesign/screen/start_live_screen.dart';
import 'package:graduationdesign/screen/login_screen.dart';
import 'package:graduationdesign/screen/register_screen.dart';
import 'package:graduationdesign/screen/retrieve_pwd_screen.dart';
import 'package:graduationdesign/screen/enter_live_screen.dart';

RouteObserver<Route<dynamic>> routeObserver = RouteObserver<Route<dynamic>>();

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  String? routeName = routeBefore(settings);
  switch (routeName) {
    case 'root':
      return MaterialPageRoute<void>(builder: (_) => const RootNode());
    case 'login':
      return MaterialPageRoute<bool?>(builder: (_) => const LoginScreen());
    case 'retrievePwd':
      return MaterialPageRoute<void>(builder: (_) => const RetrievePwdScreen());
    case 'register':
      return MaterialPageRoute<void>(builder: (_) => const RegisterScreen());
    case 'startLive':
      return MaterialPageRoute<void>(builder: (_) => const StartLiveScreen());
    case 'enterLive':
      return MaterialPageRoute<void>(
          builder: (_) =>
              EnterLiveScreen(liveId: settings.arguments as String));
    case 'recharge':
      return MaterialPageRoute<void>(
          builder: (_) => const RechargeSpeciesScreen());
    case 'details':
      return MaterialPageRoute<void>(
          builder: (_) => const AccountDetailsScreen());
    default:
      return MaterialPageRoute<void>(
          builder: (_) => const RouteNotFoundScreen());
  }
}

String? routeBefore(RouteSettings settings) {
  String? routeName = settings.name;
  if (needCheckLoginRoutes.contains(routeName)) {
    return 'login';
  }
  return routeName;
}

List<String> needCheckLoginRoutes = [];
