import 'package:flutter/material.dart';
import 'package:graduationdesign/screen/apply_live_screen.dart';
import 'package:graduationdesign/screen/push_stream_screen.dart';

class InitiateLiveScreen extends StatefulWidget {
  const InitiateLiveScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InitiateLiveState();
}

class _InitiateLiveState extends State<InitiateLiveScreen> {
  late Future future;

  @override
  void initState() {
    super.initState();
    // TODO 接口获取用户对应的直播间id
    future = Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // TODO 如果没有直播间id则表示未申请过直播间，进行申请；否则跳转推流页面
          // return const PushStreamScreen(liveId: 1234567);
          return const ApplyLiveScreen();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
