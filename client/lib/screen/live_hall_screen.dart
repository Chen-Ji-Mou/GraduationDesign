import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef _SuccessCallback = void Function(List<_Live> lives);
typedef _ErrorCallback = void Function();

class LiveHallScreen extends StatefulWidget {
  const LiveHallScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LiveHallState();
}

class _LiveHallState extends State<LiveHallScreen>
    with AutomaticKeepAliveClientMixin {
  final RefreshController controller = RefreshController();
  final double aspectRatio = 168 / 216;
  final int pageSize = 6;

  late Size screenSize;
  late double itemWidth;
  late double itemHeight;

  int curPageNum = 0;
  List<_Live> lives = [];

  @override
  void initState() {
    super.initState();
    requestLives(successCall: (result) {
      if (mounted) {
        setState(() => lives.addAll(result));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
    itemWidth = (screenSize.width - 39) / 2;
    itemHeight = itemWidth / aspectRatio;
  }

  void requestLives({
    required _SuccessCallback successCall,
    _ErrorCallback? errorCall,
  }) {
    DioClient.get(Api.getLives, {
      'pageNum': curPageNum,
      'pageSize': pageSize,
    }).then((response) async {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          List<_Live> result = [];
          for (var live in response.data['data']) {
            if (live['status'] == true) {
              result.add(_Live(
                live['id'],
                live['userId'],
                live['status'],
                live['number'],
                live['coverUrl'],
              ));
            }
          }
          await Future.wait(result.map((e) => e.transformBlogger()));
          successCall.call(result);
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
          errorCall?.call();
        }
      } else {
        errorCall?.call();
      }
    });
  }

  void onRefresh() {
    curPageNum = 0;
    requestLives(successCall: (result) {
      if (mounted) {
        setState(() => lives
          ..clear()
          ..addAll(result));
      }
      controller.refreshCompleted();
    }, errorCall: () {
      controller.refreshCompleted();
    });
  }

  void onLoading() {
    curPageNum++;
    requestLives(successCall: (result) {
      if (mounted && result.isNotEmpty) {
        setState(() => lives.addAll(result));
      }
      controller.loadComplete();
    }, errorCall: () {
      controller.loadComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const C(6),
          Expanded(
            child: ScrollConfiguration(
              behavior: NoBoundaryRippleBehavior(),
              child: SmartRefresher(
                controller: controller,
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: onRefresh,
                onLoading: onLoading,
                child: lives.isNotEmpty
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 7,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: lives.length,
                        itemBuilder: (context, index) =>
                            buildLiveItem(lives[index]),
                      )
                    : Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Assets.images.noMerchants.image(fit: BoxFit.cover),
                            Text(
                              '当前没有直播间正在直播',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: ColorName.black686868.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBox({required String hint}) {
    return InkWell(
      child: Container(
        height: 30,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: ColorName.whiteF6F7F8,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.search
                .image(width: 16, height: 16, color: ColorName.grayB4B4B5),
            const C(8),
            Text(
              hint,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorName.grayB4B4B5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLiveItem(_Live live) {
    return InkWell(
      onTap: () => itemClick(live),
      child: Container(
        width: itemWidth,
        height: itemHeight,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: live.coverUrl == null
                ? Assets.images.cover.provider()
                : CachedNetworkImageProvider(
                    'http://${Api.host}:${Api.port}/live/downloadCover?fileName=${live.coverUrl}'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 10,
              bottom: 10,
              child: Text(
                live.blogger,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  height: 12 / 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    live.number.toString(),
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      height: 12 / 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Text(
                      '在看',
                      style: GoogleFonts.roboto(
                        height: 1,
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void itemClick(_Live live) {
    Navigator.pushNamed(context, 'enterLive', arguments: live.id);
  }

  @override
  bool get wantKeepAlive => true;
}

class _Live {
  final String id;
  String blogger;
  bool status;
  int number;
  String? coverUrl;

  _Live(this.id, this.blogger, this.status, this.number, this.coverUrl);

  Future<void> transformBlogger() async {
    Response response =
        await DioClient.get(Api.getUserInfo, {'userId': blogger});
    if (response.statusCode == 200) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        blogger = map['name'];
      }
    }
  }
}
