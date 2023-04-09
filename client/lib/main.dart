import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/platform/file_load_platform.dart';
import 'package:graduationdesign/platform/permission_platform.dart';
import 'package:graduationdesign/route.dart';
import 'package:graduationdesign/screen/splash_screen.dart';
import 'package:graduationdesign/sp_manager.dart';

void main() {
  runApp(const MyApp());
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<void> init() async {
    requestPermissionSuccess = await PermissionPlatform.requestPermission();
    loadFileSuccess = await FileLoadPlatform.loadFile();
    spInitSuccess = await SpManager.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return buildRoute();
        } else {
          return const SplashScreen();
        }
      },
    );
  }

  Widget buildRoute() {
    return MaterialApp(
      initialRoute: 'root',
      navigatorObservers: [routeObserver],
      onGenerateRoute: onGenerateRoute,
    );
  }
}
