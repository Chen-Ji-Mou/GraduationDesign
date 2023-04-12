import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/sp_manager.dart';

class UserContext {
  UserContext._internal();

  static String? _name;
  static String? _email;

  static String get name => _name ?? '';
  static String get email => _email ?? '';
  static bool get isLogin => SpManager.getString('token') != null;

  static Future<bool> getUserInfo() async {
    Response response = await DioClient.get(Api.getOwnInfo);
    if (response.statusCode == 200) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        _name = map['name'];
        _email = map['email'];
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<bool> onUserLogin(String token) async {
    bool result1 = await SpManager.setString('token', token);
    bool result2 = await getUserInfo();
    return result1 && result2;
  }

  static Future<bool> onUserLogout() async {
    bool result = await SpManager.remove('token');
    _name = null;
    _email = null;
    return result;
  }

  static Future<bool> awaitLogin(BuildContext context) async {
    if (isLogin) {
      bool? isLogin = await _toLoginScreen(context);
      return true == isLogin;
    } else {
      return true;
    }
  }

  static Future<void> checkLoginCallback(
      BuildContext context, VoidCallback callback) async {
    if (isLogin) {
      bool? isLogin = await _toLoginScreen(context);
      if (true == isLogin) {
        callback.call();
      }
    } else {
      callback.call();
    }
  }

  static Future<bool?> _toLoginScreen(BuildContext context) async {
    return await Navigator.pushNamed(context, 'login');
  }
}