import 'package:flutter/material.dart';
import 'package:graduationdesign/video_view.dart';

class PullStreamScreen extends StatelessWidget {
  const PullStreamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('拉流界面')),
      body: const VideoViewWidget(),
    );
  }
}