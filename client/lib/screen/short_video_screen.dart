import 'package:flutter/material.dart';

class ShortVideoScreen extends StatefulWidget {
  const ShortVideoScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShortVideoState();
}

class _ShortVideoState extends State<ShortVideoScreen> {
  late PageController pageController;

  final List<_Video> videos = [];

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        allowImplicitScrolling: true,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return Container();
        },
      ),
    );
  }
}

class _Video {
  final String id;
  final String userId;
  final String fileName;
  final int timestamp;

  _Video(this.id, this.userId, this.fileName, this.timestamp);
}
