import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduationdesign/permission_platform.dart';
import 'package:graduationdesign/push_stream_widget.dart';
import 'package:graduationdesign/utils.dart';

class PushStreamScreen extends StatefulWidget {
  const PushStreamScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PushStreamState();
}

class _PushStreamState extends State<PushStreamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('推流界面')),
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Colors.black),
        child: FutureBuilder<bool?>(
          future: PermissionPlatform.requestPushStreamPermission(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == true) {
                return const PushStreamWidget();
              } else {
                Fluttertoast.showToast(msg: '请打开摄像头、录音和存储权限')
                    .then((_) => Navigator.pop(context));
                return const BlankPlaceholder();
              }
            } else {
              return const BlankPlaceholder();
            }
          },
        ),
      ),
    );
  }
}
