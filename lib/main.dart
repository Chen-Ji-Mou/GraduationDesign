import 'package:flutter/material.dart';
import 'package:graduationdesign/pull_stream_screen.dart';
import 'package:graduationdesign/push_stream_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  //判断是否有权限
  void checkPermission() async {
    Permission permission = Permission.locationAlways;
    PermissionStatus status = await permission.status;
    debugPrint('检测权限$status');
    if (status.isGranted) {
      //权限通过
    } else if (status.isDenied) {
      //权限拒绝， 需要区分IOS和Android，二者不一样
      requestPermission(permission);
    } else if (status.isPermanentlyDenied) {
      //权限永久拒绝，且不在提示，需要进入设置界面
      openAppSettings();
    } else if (status.isRestricted) {
      //活动限制（例如，设置了家长///控件，仅在iOS以上受支持。
      openAppSettings();
    } else {
      //第一次申请
      requestPermission(permission);
    }
  }

  //申请权限
  void requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    debugPrint('权限状态$status');
    if (!status.isGranted) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const PushStreamScreen();
            })),
            child: const Text('推流界面'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const PullStreamScreen();
            })),
            child: const Text('拉流界面'),
          )
        ],
      ),
    );
  }
}
