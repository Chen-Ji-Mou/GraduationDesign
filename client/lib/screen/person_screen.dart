import 'package:flutter/material.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PersonState();
}

class _PersonState extends State<PersonScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}