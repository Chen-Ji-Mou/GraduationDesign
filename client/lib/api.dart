import 'dart:async';
import 'package:dio/dio.dart';
import 'package:graduationdesign/sp_manager.dart';

class DioClient {
  DioClient._internal();

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(milliseconds: 6000),
      receiveTimeout: const Duration(milliseconds: 6000),
      baseUrl: "http://${Api._host}:${Api._port}",
    ),
  );

  static Future<void> init() async {
    _dio.interceptors.add(_ApiInterceptor());
  }

  static Future<Response> get(String url,
      [Map<String, dynamic>? queryParameters]) async {
    return await _dio.get(url, queryParameters: queryParameters);
  }

  static Future<Response> post(String url,
      [Map<String, dynamic>? queryParameters]) async {
    FormData? formData;
    if (queryParameters != null) {
      formData = FormData.fromMap(queryParameters);
    }
    return await _dio.post(url, data: formData);
  }
}

class _ApiInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_ignoreAuthPaths.contains(options.path)) {
      String? token = SpManager.getString('token');
      options.headers['token'] = token;
    }
    handler.next(options);
  }
}

final List<String> _ignoreAuthPaths = [
  Api.login,
  Api.register,
  Api.sendEmailVerificationCode,
  Api.verifyEmailVerificationCode,
  Api.changePwd,
  Api.getLives,
  Api.getLiveBloggerInfo,
];

class Api {
  Api._internal();

  static const _host = '81.71.161.128';
  static const _port = '8088';

  static const String login = "/user/login";

  static const String register = "/user/register";

  static const String sendEmailVerificationCode =
      "/user/sendEmailVerificationCode";

  static const String verifyEmailVerificationCode =
      "/user/verifyEmailVerificationCode";

  static const String changePwd = "/user/changePwd";

  static const String applyLive = "/live/apply";

  static const String startLive = "/live/start";

  static const String stopLive = "/live/stop";

  static const String verifyUserHasLive = "/live/verifyUserHasLive";

  static const String getLives = "/live/getLives";

  static const String enterLive = "/live/enterLive";

  static const String exitLive = "/live/exitLive";

  static const String getLiveBloggerInfo = "/person/getLiveBloggerInfo";

  static const String getOwnInfo = "/person/getOwnInfo";
}
