import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/screen/pull_stream_screen.dart';

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

  @override
  void dispose() {
    DioClient.post(Api.exitLive, {'liveId': liveId});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response>(
      future: DioClient.post(Api.enterLive, {'liveId': liveId}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data?.statusCode == 200) {
            return PullStreamScreen(liveId: liveId);
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
