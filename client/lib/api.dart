import 'package:dio/dio.dart';

class DioClient {
  DioClient._internal();

  static final Dio _dio = Dio();

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

class Api {
  Api._internal();

  static const host = '81.71.161.128';
  static const port = '8088';

  static const String login = "http://$host:$port/user/login";
  static const String register = "http://$host:$port/user/register";
  static const String sendEmailVerificationCode =
      "http://$host:$port/user/sendEmailVerificationCode";
  static const String verifyEmailVerificationCode =
      "http://$host:$port/user/verifyEmailVerificationCode";
  static const String changePwd = "http://$host:$port/user/changePwd";
}
