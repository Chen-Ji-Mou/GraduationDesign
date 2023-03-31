import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}