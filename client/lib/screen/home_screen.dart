import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/platform/initial_platform.dart';
import 'package:graduationdesign/platform/permission_platform.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        PermissionPlatform.requestPermission(),
        InitialPlatform.initial(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return buildContent();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget buildContent() {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          toolbarHeight: 1,
          backgroundColor: Colors.black.withOpacity(0.8),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, 'initiateLive'),
                child: const Text('发起直播'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  'watchLive',
                  arguments: 1234567, // 直播间id 7位
                ),
                child: const Text('进入直播间'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, 'login'),
                child: const Text('登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
