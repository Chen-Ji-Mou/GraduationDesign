import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/screen/home_screen.dart';
import 'package:graduationdesign/user_context.dart';

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
  DateTime? lastPressedTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
    toolbarHeight = MediaQuery.of(context).padding.top;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = DefaultTabController(
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
    return WillPopScope(
      onWillPop: () async {
        if (lastPressedTime == null ||
            DateTime.now().difference(lastPressedTime!) >
                const Duration(milliseconds: 1000)) {
          Fluttertoast.showToast(msg: '再次返回将会退出应用');
          lastPressedTime = DateTime.now();
          return false;
        }
        return true;
      },
      child: child,
    );
  }

  Widget buildBody(_TabType type) {
    switch (type) {
      case _TabType.home:
        return const HomeScreen();
      case _TabType.publish:
        return const C(0);
      case _TabType.person:
        return const LoadingWidget();
    }
  }

  Future<bool?> showBottomSheet() async {
    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheet(screenSize: screenSize),
    );
  }
}

class _BottomTab {
  final _TabType type;
  final TabItem data;

  _BottomTab({required this.type, required this.data});
}

enum _BottomSheetType { live, shortVideo }

extension _BottomSheetExt on _BottomSheetType {
  String get name {
    switch (this) {
      case _BottomSheetType.live:
        return '发起直播';
      case _BottomSheetType.shortVideo:
        return '录制短视频';
    }
  }

  Color get color {
    switch (this) {
      case _BottomSheetType.live:
        return ColorName.redEC008E;
      case _BottomSheetType.shortVideo:
        return ColorName.redF14336;
    }
  }

  ImageProvider get icon {
    switch (this) {
      case _BottomSheetType.live:
        return Assets.images.live.provider();
      case _BottomSheetType.shortVideo:
        return Assets.images.shortVideo.provider();
    }
  }
}

typedef _BottomSheetItemSelect = void Function(_BottomSheetType type);

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({
    Key? key,
    required this.screenSize,
  }) : super(key: key);

  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              buildItem(
                context,
                _BottomSheetType.live,
                onTap: (type) {
                  UserContext.checkLoginCallback(
                    context,
                    () => Navigator.pushNamed(context, 'startLive'),
                  );
                },
              ),
              buildItem(
                context,
                _BottomSheetType.shortVideo,
                onTap: (type) {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildItem(
    BuildContext context,
    _BottomSheetType type, {
    _BottomSheetItemSelect? onTap,
  }) {
    return InkWell(
      onTap: () => onTap?.call(type),
      child: Container(
        width: (screenSize.width - 32) / 4,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: type.color,
              ),
              child: Image(
                image: type.icon,
                width: 30,
                height: 30,
              ),
            ),
            const C(12),
            Text(
              type.name,
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
    );
  }
}
