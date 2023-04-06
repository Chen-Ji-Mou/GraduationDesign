import 'package:flutter/material.dart';
import 'package:graduationdesign/screen/pull_stream_screen.dart';

class WatchLiveScreen extends StatefulWidget {
  const WatchLiveScreen({
    Key? key,
    required this.liveId,
  }) : super(key: key);

  final int liveId;

  @override
  State<StatefulWidget> createState() => _WatchLiveState();
}

class _WatchLiveState extends State<WatchLiveScreen> {
  int get liveId => widget.liveId;

  @override
  Widget build(BuildContext context) {
    return PullStreamScreen(liveId: liveId);
  }
}
