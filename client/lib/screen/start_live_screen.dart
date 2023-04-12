import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/screen/apply_live_screen.dart';
import 'package:graduationdesign/screen/push_stream_screen.dart';

class StartLiveScreen extends StatefulWidget {
  const StartLiveScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StartLiveState();
}

class _StartLiveState extends State<StartLiveScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
      future: DioClient.get(Api.verifyUserHasLive),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data?.statusCode == 200) {
            if (snapshot.data?.data['code'] == 200) {
              return PushStreamScreen(liveId: snapshot.data?.data['data']);
            } else {
              return const ApplyLiveScreen();
            }
          } else {
            return ErrorWidget(onRetry: retry);
          }
        } else {
          return const LoadingWidget();
        }
      },
    );
  }

  void retry() {
    if (mounted) {
      setState(() {});
    }
  }
}
