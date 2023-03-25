import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduationdesign/permission_platform.dart';
import 'package:graduationdesign/push_stream_view.dart';

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
      body: FutureBuilder<bool?>(
        future: PermissionPlatform.requestPushStreamPermission(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return const PushStreamViewWidget();
            } else {
              Fluttertoast.showToast(msg: '请同意权限申请');
              Navigator.pop(context);
              return Container();
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}