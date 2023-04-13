import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
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
      data: const TabItem(icon: Icons.home, title: '首页'),
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
      data: const TabItem(icon: Icons.person, title: '我的'),
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
              showBottomSheet();
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

  Future<void> showBottomSheet() async {
    await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.cancel,
                size: 28,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            const C(20),
            Row(
              children: [
                Container(
                  width: (screenSize.width - 32) / 4,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorName.redEC008E,
                        ),
                        child: Assets.images.live.image(
                          width: 30,
                          height: 30,
                        ),
                      ),
                      const C(12),
                      Text(
                        '直播',
                        style: GoogleFonts.roboto(
                          height: 1,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: (screenSize.width - 32) / 4,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorName.redF14336,
                        ),
                        child: Assets.images.shortVideo.image(
                          width: 30,
                          height: 30,
                        ),
                      ),
                      const C(12),
                      Text(
                        '短视频',
                        style: GoogleFonts.roboto(
                          height: 1,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _BottomTab {
  final _TabType type;
  final TabItem data;

  _BottomTab({required this.type, required this.data});
}
