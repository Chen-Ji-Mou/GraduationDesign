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
            onPressed: () => Navigator.pushNamed(context, 'login'),
            child: const Text('登录'),
          ),
        ],
      ),
    );
  }
}