import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/platform_param_keys.dart';

class PushStreamViewWidget extends StatelessWidget {
  const PushStreamViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AndroidView(
      viewType: 'pushStreamView',
      creationParams: {
        PlatformParamKeys.path:
            'rtmp://81.71.161.128:1935/live/1',
      },
      creationParamsCodec: StandardMessageCodec(),
    );
  }
}
