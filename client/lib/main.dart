import 'package:flutter/material.dart';
import 'package:graduationdesign/platform/initial_platform.dart';
import 'package:graduationdesign/platform/permission_platform.dart';
import 'package:graduationdesign/route.dart';
import 'package:graduationdesign/screen/home_screen.dart';
import 'package:graduationdesign/screen/pull_stream_screen.dart';
import 'package:graduationdesign/screen/push_stream_screen.dart';
import 'package:graduationdesign/common.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'home',
      navigatorObservers: [routeObserver],
      onGenerateRoute: onGenerateRoute,
    );
  }
}
