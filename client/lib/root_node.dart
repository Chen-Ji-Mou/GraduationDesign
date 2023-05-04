import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/screen/home_screen.dart';
import 'package:graduationdesign/screen/person_screen.dart';
import 'package:graduationdesign/user_context.dart';
import 'package:image_picker/image_picker.dart';

enum _TabType { home, favorite, publish, cart, person }

class RootNode extends StatefulWidget {
  const RootNode({Key? key}) : super(key: key);

  @override
  State<RootNode> createState() => _RootNodeState();
}

class _RootNodeState extends State<RootNode>
    with SingleTickerProviderStateMixin {
  final List<_BottomTab> tabs = [
    _BottomTab(
      type: _TabType.home,
      data: const TabItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        title: '首页',
      ),
    ),
    _BottomTab(
      type: _TabType.favorite,
      data: const TabItem(
        icon: Icons.favorite_border,
        activeIcon: Icons.favorite,
        title: '收藏',
      ),
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
      type: _TabType.cart,
      data: const TabItem(
        icon: Icons.shopping_cart_outlined,
        activeIcon: Icons.shopping_cart,
        title: '购物车',
      ),
    ),
    _BottomTab(
      type: _TabType.person,
      data: const TabItem(
        icon: Icons.person_outlined,
        activeIcon: Icons.person,
        title: '我的',
      ),
    ),
  ];

  late TabController tabController;
  late Size screenSize;

  DateTime? lastPressedTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
    toolbarHeight = MediaQuery.of(context).padding.top;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.only(top: toolbarHeight),
        child: TabBarView(
          controller: tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: tabs.map((tab) => buildBody(tab.type)).toList(),
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        controller: tabController,
        activeColor: ColorName.redF63C77,
        backgroundColor: Colors.white,
        color: ColorName.gray8A8A8A,
        style: TabStyle.fixedCircle,
        elevation: 1,
        items: tabs.map((tab) => tab.data).toList(),
        onTabNotify: bottomTabIntercept,
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
      case _TabType.favorite:
        return Container();
      case _TabType.publish:
        return const C(0);
      case _TabType.cart:
        return Container();
      case _TabType.person:
        return PersonScreen(
          onUserLogout: () => tabController.animateTo(_TabType.home.index),
        );
    }
  }

  bool bottomTabIntercept(int index) {
    var pass = true;
    if (index == _TabType.publish.index) {
      showBottomSheet();
      pass = false;
    } else if (index == _TabType.person.index) {
      if (!UserContext.isLogin) {
        UserContext.checkLoginCallback(context, () {
          if (UserContext.isLogin) {
            tabController.animateTo(_TabType.person.index);
          }
        });
      }
      pass = UserContext.isLogin;
    } else if ([_TabType.favorite.index, _TabType.cart.index].contains(index)) {
      Fluttertoast.showToast(msg: '功能还未开发，敬请期待');
      pass = false;
    }
    return pass;
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

enum _BottomSheetType { live, recordVideo, uploadVideo }

extension _BottomSheetExt on _BottomSheetType {
  String get name {
    switch (this) {
      case _BottomSheetType.live:
        return '发起直播';
      case _BottomSheetType.recordVideo:
        return '录制短视频';
      case _BottomSheetType.uploadVideo:
        return '上传短视频';
    }
  }

  Color get color {
    switch (this) {
      case _BottomSheetType.live:
        return ColorName.redEC008E;
      case _BottomSheetType.recordVideo:
        return ColorName.redF14336;
      case _BottomSheetType.uploadVideo:
        return ColorName.yellowFFB52D;
    }
  }

  ImageProvider get icon {
    switch (this) {
      case _BottomSheetType.live:
        return Assets.images.live.provider();
      case _BottomSheetType.recordVideo:
        return Assets.images.shortVideo.provider();
      case _BottomSheetType.uploadVideo:
        return Assets.images.uploadVideo.provider();
    }
  }
}

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
          const C(16),
          Row(
            children: [
              buildItem(
                context,
                _BottomSheetType.live,
                onTap: () {
                  UserContext.checkLoginCallback(
                    context,
                    () => Navigator.pushNamed(context, 'startLive'),
                  );
                },
              ),
              buildItem(
                context,
                _BottomSheetType.recordVideo,
                onTap: () {
                  UserContext.checkLoginCallback(
                    context,
                    () => Navigator.pushNamed(context, 'startRecord'),
                  );
                },
              ),
              buildItem(
                context,
                _BottomSheetType.uploadVideo,
                onTap: uploadVideo,
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
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

  Future<void> uploadVideo() async {
    var video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    String? videoPath = video?.path;
    if (videoPath != null) {
      DioClient.post(Api.uploadVideo, {
        'file': await MultipartFile.fromFile(
          videoPath,
          filename: videoPath.substring(
            videoPath.lastIndexOf('/') + 1,
          ),
        ),
      }).then((response) {
        if (response.statusCode == 200 && response.data != null) {
          if (response.data['code'] == 200) {
            Fluttertoast.showToast(msg: '上传成功');
          } else {
            Fluttertoast.showToast(msg: response.data['msg']);
          }
        }
      });
    }
  }
}
