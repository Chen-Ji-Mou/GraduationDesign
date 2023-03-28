import 'package:flutter/material.dart';
import 'package:graduationdesign/pull_stream_screen.dart';
import 'package:graduationdesign/push_stream_screen.dart';
import 'package:graduationdesign/utils.dart';

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
      routes: {
        '/home': (BuildContext context) => const MyHomePage(title: 'Test'),
        '/pushStream': (BuildContext context) => const PushStreamScreen(),
        '/pullStream': (BuildContext context) => const PullStreamScreen(),
      },
      initialRoute: '/home',
      navigatorObservers: [routeObserver],
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
            onPressed: () => Navigator.pushNamed(context, '/pushStream'),
            child: const Text('推流界面'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/pullStream'),
            child: const Text('拉流界面'),
          )
        ],
      ),
    );
  }
}
