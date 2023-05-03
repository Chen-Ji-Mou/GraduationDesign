import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/sp_manager.dart';

bool getUserInfoSuccess = false;
bool userAccountCreateSuccess = false;
bool userHasAuthenticated = false;

class UserContext {
  UserContext._internal();

  static String? _name;
  static String? _email;
  static String? _avatarUrl;
  static String? _enterpriseId;

  static String get name => _name ?? '';

  static String get email => _email ?? '';

  static String get avatarUrl => _avatarUrl ?? '';

  static String get enterpriseId => _enterpriseId ?? '';

  static bool get isEnterprise => _enterpriseId != null;

  static bool get isLogin => SpManager.getString('token') != null;

  static Future<bool> getUserInfo() async {
    Response response = await DioClient.get(Api.getOwnInfo);
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        _name = map['name'];
        _email = map['email'];
        _avatarUrl = map['avatarUrl'];
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<bool> _createUserAccount() async {
    Response response = await DioClient.post(Api.createAccount);
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<bool> _verifyUserHasAuthenticated() async {
    Response response = await DioClient.get(Api.verifyUserHasAuthenticated);
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        _enterpriseId = response.data['data'];
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static Future<bool> onUserLogin(String token) async {
    bool tokenSaveSuccess = await SpManager.setString('token', token);
    if (tokenSaveSuccess == true) {
      getUserInfoSuccess = await getUserInfo();
      userAccountCreateSuccess = await _createUserAccount();
      userHasAuthenticated = await _verifyUserHasAuthenticated();
    }
    return tokenSaveSuccess &&
        getUserInfoSuccess &&
        userAccountCreateSuccess &&
        userHasAuthenticated;
  }

  static Future<bool> onUserLogout() async {
    bool result = await SpManager.remove('token');
    _name = null;
    _email = null;
    return result;
  }

  static Future<bool> awaitLogin(BuildContext context) async {
    if (!isLogin) {
      bool? isLogin = await _toLoginScreen(context);
      return true == isLogin;
    } else {
      return true;
    }
  }

  static Future<void> checkLoginCallback(
      BuildContext context, VoidCallback callback) async {
    if (!isLogin) {
      bool? isLogin = await _toLoginScreen(context);
      if (true == isLogin) {
        callback.call();
      }
    } else {
      callback.call();
    }
  }

  static Future<bool?> _toLoginScreen(BuildContext context) async {
    return await Navigator.pushNamed<bool?>(context, 'login');
  }
}
