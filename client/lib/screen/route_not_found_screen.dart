import 'package:flutter/material.dart';
import 'package:graduationdesign/generate/assets.gen.dart';

class RouteNotFoundScreen extends StatelessWidget {
  const RouteNotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Assets.images.notFound.image(fit: BoxFit.cover),
      ),
    );
  }
}