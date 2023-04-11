import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/screen/home_screen.dart';
import 'package:graduationdesign/screen/person_screen.dart';

enum _TabType { home, publish, person }

class RootNode extends StatefulWidget {
  const RootNode({Key? key}) : super(key: key);

  @override
  State<RootNode> createState() => _RootNodeState();
}

class _RootNodeState extends State<RootNode> {
  final List<_BottomTab> tabs = [
    _BottomTab(
      type: _TabType.home,
      data: const TabItem(icon: Icons.home),
    ),
    _BottomTab(
      type: _TabType.publish,
      data: TabItem(
        icon: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [
              ColorName.redEC008E,
              ColorName.redFC6767,
            ]),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 36),
        ),
      ),
    ),
    _BottomTab(
      type: _TabType.person,
      data: const TabItem(icon: Icons.person),
    ),
  ];

  late Size screenSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
    toolbarHeight = MediaQuery.of(context).padding.top;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: EdgeInsets.only(top: toolbarHeight),
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: tabs.map((tab) => buildBody(tab.type)).toList(),
          ),
        ),
        bottomNavigationBar: ConvexAppBar(
          activeColor: ColorName.redF63C77,
          backgroundColor: Colors.white,
          color: ColorName.black686868,
          style: TabStyle.fixedCircle,
          elevation: 1,
          items: tabs.map((tab) => tab.data).toList(),
          onTabNotify: (index) {
            var intercept = index == 1;
            if (intercept) {
              // TODO 弹出 BottomSheet 让用户选择是上传短视频还是开启直播
            }
            return !intercept;
          },
        ),
      ),
    );
  }

  Widget buildBody(_TabType type) {
    switch (type) {
      case _TabType.home:
        return const HomeScreen();
      case _TabType.publish:
        return const C(0);
      case _TabType.person:
        return const PersonScreen();
    }
  }
}

class _BottomTab {
  final _TabType type;
  final TabItem data;

  _BottomTab({required this.type, required this.data});
}
