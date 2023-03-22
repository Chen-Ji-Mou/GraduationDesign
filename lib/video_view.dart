import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/platform_param_keys.dart';

class VideoViewWidget extends StatelessWidget {
  const VideoViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AndroidView(
      viewType: 'videoView',
      creationParams: {
        PlatformParamKeys.path:
            'rtmp://81.71.161.128:1935/live/1',
        PlatformParamKeys.fillXY: 'false'
      },
      creationParamsCodec: StandardMessageCodec(),
    );
  }
}
