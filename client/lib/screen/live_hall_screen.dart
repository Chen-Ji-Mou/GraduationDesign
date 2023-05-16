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

class _Live {
  final String id;
  final String userId;
  bool status;
  int number;
  String? coverUrl;
  late String userName;
  late String? userAvatarUrl;

  _Live(this.id, this.userId, this.status, this.number, this.coverUrl);

  void setCoverUrl() {
    if (coverUrl != null) {
      coverUrl =
          'http://${Api.host}:${Api.port}/live/downloadCover?fileName=$coverUrl';
    }
  }

  Future<void> getUserInfo() async {
    Response response =
        await DioClient.get(Api.getUserInfo, {'userId': userId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        userName = map['name'];
        userAvatarUrl = map['avatarUrl'] != null
            ? 'http://${Api.host}:${Api.port}${Api.downloadAvatar}?fileName=${map['avatarUrl']}'
            : null;
      }
    }
  }
}

class LiveHallScreen extends StatefulWidget {
  const LiveHallScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LiveHallState();
}

class _LiveHallState extends State<LiveHallScreen>
    with AutomaticKeepAliveClientMixin {
  final RefreshController refreshController = RefreshController();
  final double aspectRatio = 168 / 216;
  final List<_Live> lives = [];
  final int pageSize = 6;

  late Size screenSize;
  late double itemWidth;
  late double itemHeight;

  int curPageNum = 0;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    getLives(successCall: (result) {
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

  void getLives({
    required RequestSuccessCallback<_Live> successCall,
    VoidCallback? errorCall,
  }) {
    DioClient.get(Api.getLives, {
      'pageNum': curPageNum,
      'pageSize': pageSize,
    }).then((response) async {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          List<_Live> result = [];
          for (var live in response.data['data']) {
            result.add(_Live(
              live['id'],
              live['userId'],
              live['status'],
              live['number'],
              live['coverUrl'],
            )..setCoverUrl());
          }
          await Future.wait(result.map((e) => e.getUserInfo()));
          isLastPage = result.length < pageSize;
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
    getLives(successCall: (result) {
      if (mounted) {
        setState(() => lives
          ..clear()
          ..addAll(result));
      }
      refreshController.refreshCompleted();
    }, errorCall: () {
      refreshController.refreshFailed();
    });
  }

  void onLoading() {
    if (!isLastPage) {
      curPageNum++;
    }
    getLives(successCall: (result) {
      if (mounted && result.isNotEmpty) {
        setState(() => lives.addAll(result));
      }
      refreshController.loadComplete();
    }, errorCall: () {
      refreshController.loadFailed();
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
                controller: refreshController,
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
                        itemBuilder: buildLiveItem,
                      )
                    : const _LiveEmptyWidget(),
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

  Widget buildLiveItem(BuildContext context, int index) {
    _Live live = lives[index];
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, 'enterLive', arguments: live.id),
      child: Container(
        width: itemWidth,
        height: itemHeight,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: ColorName.gray969696.withOpacity(0.3),
              offset: const Offset(2, 4),
              blurRadius: 3,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                width: itemWidth,
                height: itemHeight * 4 / 5,
                color: live.coverUrl == null ? Colors.black : null,
                child: live.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: live.coverUrl!,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            if (live.status)
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  height: 20,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ColorName.gray8A8A8A.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Assets.images.liveNumberIcon.image(),
                      ),
                      const C(4),
                      Text(
                        '${live.number}观看',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const C(8),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 20,
              top: itemHeight * 4 / 5 - 14,
              child: Container(
                width: 28,
                height: 28,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: live.userAvatarUrl == null
                    ? const DefaultAvatarWidget(size: 28)
                    : CachedNetworkImage(
                        imageUrl: live.userAvatarUrl!,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Positioned(
              left: 10,
              top: itemHeight * 4 / 5 + 14,
              child: Text(
                live.userName,
                style: GoogleFonts.roboto(
                  height: 1.4,
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _LiveEmptyWidget extends StatelessWidget {
  const _LiveEmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.imgLiveEmpty.image(fit: BoxFit.cover),
          Text(
            '当前没有直播间信息',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorName.black686868.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
