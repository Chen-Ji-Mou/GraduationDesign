import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/platform/initial_platform.dart';
import 'package:graduationdesign/platform/permission_platform.dart';
import 'package:graduationdesign/screen/home_screen.dart';
import 'package:graduationdesign/screen/pull_stream_screen.dart';
import 'package:graduationdesign/screen/push_stream_screen.dart';
import 'package:graduationdesign/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        PermissionPlatform.requestPermission(),
        InitialPlatform.initial(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            routes: {
              '/home': (BuildContext context) => const HomeScreen(),
              '/pushStream': (BuildContext context) => const PushStreamScreen(),
              '/pullStream': (BuildContext context) => const PullStreamScreen(),
            },
            initialRoute: '/home',
            navigatorObservers: [routeObserver],
          );
        } else {
          return const BlankPlaceholder();
        }
      },
    );
  }
}
