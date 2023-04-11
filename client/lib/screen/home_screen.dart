import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/screen/live_hall_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<String> tabTitles = ['直播', '视频'];

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabTitles.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: TabBar(
              controller: tabController,
              labelColor: ColorName.redF63C77,
              labelStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              unselectedLabelColor: ColorName.black686868,
              unselectedLabelStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              tabs: tabTitles
                  .map((value) => Tab(height: 34, text: value))
                  .toList(),
              indicator: CustomTabIndicator(
                tabController: tabController,
                borderSide:
                    const BorderSide(width: 2, color: ColorName.redF63C77),
              ),
            ),
          ),
          const C(4),
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [LiveHallScreen(), LiveHallScreen()],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTabIndicator extends Decoration {
  final TabController? tabController;
  final double indicatorBottom; // 调整指示器下边距
  final double indicatorWidth; // 指示器宽度

  const CustomTabIndicator({
    // 设置下标高度、颜色
    this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
    this.tabController,
    this.indicatorBottom = 0.0,
    this.indicatorWidth = 4,
  });

  /// The color and weight of the horizontal line drawn below the selected tab.
  final BorderSide borderSide;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _UnderlinePainter(
      this,
      onChanged,
      tabController?.animation,
      indicatorWidth,
    );
  }

  Rect _indicatorRectFor(Rect indicator, TextDirection textDirection) {
    /// 自定义固定宽度
    double w = indicatorWidth;
    //中间坐标
    double centerWidth = (indicator.left + indicator.right) / 2;
    return Rect.fromLTWH(
      //距离左边距
      tabController?.animation == null ? centerWidth - w / 2 : centerWidth - 1,
      // 距离上边距
      indicator.bottom - borderSide.width - indicatorBottom,
      w,
      borderSide.width,
    );
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRect(_indicatorRectFor(rect, textDirection));
  }
}

class _UnderlinePainter extends BoxPainter {
  Animation<double>? animation;
  double indicatorWidth;

  _UnderlinePainter(this.decoration, VoidCallback? onChanged, this.animation,
      this.indicatorWidth)
      : super(onChanged);

  final CustomTabIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    // 以offset坐标为左上角 size为宽高的矩形
    final Rect rect = offset & configuration.size!;
    final TextDirection textDirection = configuration.textDirection!;
    // 返回tab矩形
    final Rect indicator = decoration._indicatorRectFor(rect, textDirection)
      ..deflate(decoration.borderSide.width / 2.0);
    // 圆角画笔
    final Paint paint = decoration.borderSide.toPaint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
    if (animation != null) {
      num x = animation!.value; // 变化速度 0-0.5-1-1.5-2...
      num d = x - x.truncate(); // 获取这个数字的小数部分
      num? y;
      if (d < 0.5) {
        y = 2 * d;
      } else if (d > 0.5) {
        y = 1 - 2 * (d - 0.5);
      } else {
        y = 1;
      }
      canvas.drawRRect(
          RRect.fromRectXY(
              Rect.fromCenter(
                  center: indicator.centerLeft,
                  // 这里控制最长为多长
                  width: indicatorWidth * 6 * y + indicatorWidth,
                  height: indicatorWidth),
              // 圆角
              2,
              2),
          paint);
    } else {
      canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
    }
  }
}
