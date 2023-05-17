import 'package:flutter/material.dart';
import 'package:graduationdesign/root_node.dart';
import 'package:graduationdesign/screen/account_details_screen.dart';
import 'package:graduationdesign/screen/address_screen.dart';
import 'package:graduationdesign/screen/enterprise_auth_screen.dart';
import 'package:graduationdesign/screen/my_favorite_detail_screen.dart';
import 'package:graduationdesign/screen/order_screen.dart';
import 'package:graduationdesign/screen/product_screen.dart';
import 'package:graduationdesign/screen/recharge_species_screen.dart';
import 'package:graduationdesign/screen/route_not_found_screen.dart';
import 'package:graduationdesign/screen/start_live_screen.dart';
import 'package:graduationdesign/screen/login_screen.dart';
import 'package:graduationdesign/screen/register_screen.dart';
import 'package:graduationdesign/screen/retrieve_pwd_screen.dart';
import 'package:graduationdesign/screen/enter_live_screen.dart';
import 'package:graduationdesign/screen/start_record_screen.dart';

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
    case 'startRecord':
      return MaterialPageRoute<bool?>(
          builder: (_) => const StartRecordScreen());
    case 'enterpriseAuth':
      return MaterialPageRoute<bool?>(
          builder: (_) => const EnterpriseAuthScreen());
    case 'product':
      return MaterialPageRoute<void>(builder: (_) => const ProductScreen());
    case 'address':
      return MaterialPageRoute<String?>(
          builder: (_) => AddressScreen(isSelect: settings.arguments as bool));
    case 'order':
      return MaterialPageRoute<void>(builder: (_) => const OrderScreen());
    case 'favoriteDetail':
      return MaterialPageRoute<void>(
          builder: (_) =>
              MyFavoriteDetailScreen(initialIndex: settings.arguments as int));
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
