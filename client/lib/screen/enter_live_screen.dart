import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/screen/pull_stream_screen.dart';

class LiveInfo {
  final String id;
  final String userId;
  final bool status;
  final int number;
  late bool belongEnterprise;

  LiveInfo(this.id, this.userId, this.status, this.number);

  Future<void> verifyLiveBelongEnterprise() async {
    Response response = await DioClient.get(Api.verifyUserHasAuthenticated, {
      'userId': userId,
    });
    if (response.statusCode == 200 && response.data != null) {
      belongEnterprise = response.data['code'] == 200;
    }
  }
}

class EnterLiveScreen extends StatefulWidget {
  const EnterLiveScreen({
    Key? key,
    required this.liveId,
  }) : super(key: key);

  final String liveId;

  @override
  State<StatefulWidget> createState() => _EnterLiveState();
}

class _EnterLiveState extends State<EnterLiveScreen> {
  String get liveId => widget.liveId;

  LiveInfo? liveInfo;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    enterLive();
  }

  Future<void> enterLive() async {
    if (mounted) {
      setState(() => isLoading = true);
    }
    await DioClient.post(Api.enterLive, {'liveId': liveId});
    Response response =
        await DioClient.get(Api.getLiveInfo, {'liveId': liveId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        LiveInfo result =
            LiveInfo(map['id'], map['userId'], map['status'], map['number']);
        await result.verifyLiveBelongEnterprise();
        if (mounted) {
          setState(() {
            isLoading = false;
            liveInfo = result;
          });
        }
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } else {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    DioClient.post(Api.exitLive, {'liveId': liveId});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingWidget()
        : liveInfo != null
            ? PullStreamScreen(liveInfo: liveInfo!)
            : ErrorWidget(onRetry: enterLive);
  }
}
