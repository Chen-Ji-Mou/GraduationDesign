import 'package:flutter/material.dart';
import 'package:graduationdesign/push_stream_view.dart';

class PushStreamScreen extends StatelessWidget {
  const PushStreamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('推流界面')),
      body: const PushStreamViewWidget(),
    );
  }
}