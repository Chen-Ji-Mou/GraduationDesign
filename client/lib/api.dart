import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:graduationdesign/sp_manager.dart';

class DioClient {
  DioClient._internal();

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(milliseconds: 6000),
      receiveTimeout: const Duration(milliseconds: 6000),
      baseUrl: "http://${Api.host}:${Api.port}",
    ),
  )..interceptors.add(_ApiInterceptor());

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
    debugPrint('[ApiInterceptor] DioRequest: url ${options.uri}');
    if (!_ignoreAuthPaths.contains(options.path)) {
      String? token = SpManager.getString('token');
      options.headers['token'] = token;
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        '[ApiInterceptor] DioResponse: url ${response.realUri} code ${response.statusCode} data ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    debugPrint(
        '[ApiInterceptor] DioError: url ${err.requestOptions.uri} message: ${err.response?.statusMessage}');
    handler.next(err);
  }
}

final List<String> _ignoreAuthPaths = [
  Api.login,
  Api.register,
  Api.sendEmailVerificationCode,
  Api.verifyEmailVerificationCode,
  Api.changePwd,
  Api.verifyUserToken,
  Api.getLives,
  Api.enterLive,
  Api.exitLive,
  Api.downloadCover,
  Api.getUserInfo,
  Api.downloadAvatar,
  Api.getGifts,
  Api.getVideos,
  Api.downloadVideo,
  Api.downloadLicense,
  Api.getComments,
  Api.getVideoCommentCount,
  Api.getVideoFavoriteCount,
  Api.downloadProductCover,
  Api.getLiveProducts,
];

class Api {
  Api._internal();

  static const host = '81.71.161.128';
  static const port = '8088';

  static const String login = "/user/login";

  static const String register = "/user/register";

  static const String sendEmailVerificationCode =
      "/user/sendEmailVerificationCode";

  static const String verifyEmailVerificationCode =
      "/user/verifyEmailVerificationCode";

  static const String changePwd = "/user/changePwd";

  static const String verifyUserToken = "/user/verifyUserToken";

  static const String applyLive = "/live/apply";

  static const String startLive = "/live/start";

  static const String stopLive = "/live/stop";

  static const String verifyUserHasLive = "/live/verifyUserHasLive";

  static const String getLives = "/live/getLives";

  static const String enterLive = "/live/enterLive";

  static const String exitLive = "/live/exitLive";

  static const String uploadCover = "/live/uploadCover";

  static const String downloadCover = "/live/downloadCover";

  static const String getUserInfo = "/person/getUserInfo";

  static const String getOwnInfo = "/person/getOwnInfo";

  static const String uploadAvatar = "/person/uploadAvatar";

  static const String downloadAvatar = "/person/downloadAvatar";

  static const String getGifts = "/gift/getGifts";

  static const String sendGift = "/gift/sendGift";

  static const String getGift = "/gift/getGift";

  static const String getUserBag = "/bag/getUserBag";

  static const String getGiftNumber = "/bag/getGiftNumber";

  static const String addBag = "/bag/addBag";

  static const String reduceBag = "/bag/reduceBag";

  static const String createAccount = "/account/createAccount";

  static const String rechargeAccount = "/account/rechargeAccount";

  static const String spendAccount = "/account/spendAccount";

  static const String getAccount = "/account/getAccount";

  static const String addDetail = "/detail/addDetail";

  static const String getDetail = "/detail/getDetail";

  static const String getTotalIncome = "/detail/getTotalIncome";

  static const String getTotalExpenditure = "/detail/getTotalExpenditure";

  static const String getVideos = "/video/getVideos";

  static const String uploadVideo = "/video/uploadVideo";

  static const String downloadVideo = "/video/downloadVideo";

  static const String updateShareCount = "/video/updateShareCount";

  static const String uploadLicense = "/enterprise/uploadLicense";

  static const String downloadLicense = "/enterprise/downloadLicense";

  static const String authentication = "/enterprise/authentication";

  static const String verifyUserHasAuthenticated =
      "/enterprise/verifyUserHasAuthenticated";

  static const String addAddress = "/address/addAddress";

  static const String getAddresses = "/address/getAddresses";

  static const String updateAddress = "/address/updateAddress";

  static const String deleteAddress = "/address/deleteAddress";

  static const String addCart = "/cart/addCart";

  static const String getCarts = "/cart/getCarts";

  static const String deleteCart = "/cart/deleteCart";

  static const String addChat = "/chat/addChat";

  static const String getChatList = "/chat/getChatList";

  static const String getChat = "/chat/getChat";

  static const String addComment = "/comment/addComment";

  static const String getComments = "/comment/getComments";

  static const String getVideoCommentCount = "/comment/getVideoCommentCount";

  static const String addFavorite = "/favorite/addFavorite";

  static const String getVideoFavoriteCount = "/favorite/getVideoFavoriteCount";

  static const String getUserFavorites = "/favorite/getUserFavorites";

  static const String deleteFavorite = "/favorite/deleteFavorite";

  static const String verifyVideoHasOwnFavorite = "/favorite/verifyVideoHasOwnFavorite";

  static const String addOrder = "/order/addOrder";

  static const String getUserOrders = "/order/getUserOrders";

  static const String getEnterpriseOrders = "/order/getEnterpriseOrders";

  static const String updateOrderStatus = "/order/updateOrderStatus";

  static const String addProduct = "/product/addProduct";

  static const String getEnterpriseProducts = "/product/getEnterpriseProducts";

  static const String getLiveProducts = "/product/getLiveProducts";

  static const String updateProduct = "/product/updateProduct";

  static const String deleteProduct = "/product/deleteProduct";

  static const String uploadProductCover = "/product/uploadCover";

  static const String downloadProductCover = "/product/downloadCover";

  static const String addRefund = "/refund/addRefund";

  static const String getUserRefunds = "/refund/getUserRefunds";

  static const String getEnterpriseRefunds = "/refund/getEnterpriseRefunds";

  static const String updateRefundStatus = "/refund/updateRefundStatus";
}
