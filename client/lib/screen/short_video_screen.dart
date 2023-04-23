import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/widget/video_widget.dart';
import 'package:like_button/like_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef _SuccessCallback = void Function(List<_Video> videos);

class ShortVideoScreen extends StatefulWidget {
  const ShortVideoScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShortVideoState();
}

class _ShortVideoState extends State<ShortVideoScreen>
    with AutomaticKeepAliveClientMixin {
  final RefreshController controller = RefreshController();
  final Completer<bool> initialCompleter = Completer<bool>();

  late PageController pageController;

  final List<_Video> videos = [];
  final int pageSize = 6;

  int curPageNum = 0;
  bool isLastPage = false;
  int curIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 1.0);
    getVideos(successCall: (result) {
      if (mounted) {
        setState(() => videos
          ..addAll(result)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)));
      }
      initialCompleter.complete(videos.isNotEmpty);
    }, errorCall: () {
      initialCompleter.complete(false);
    });
  }

  void getVideos({
    required _SuccessCallback successCall,
    VoidCallback? errorCall,
  }) {
    DioClient.get(Api.getVideos, {
      'pageNum': curPageNum,
      'pageSize': pageSize,
    }).then((response) async {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          List<_Video> result = [];
          for (var video in response.data['data']) {
            _Video item = _Video(
              video['id'],
              video['userId'],
              video['fileName'],
              video['timestamp'],
            )..setVideoUrl();
            result.add(item);
          }
          await Future.wait(result.map((e) => e.setAvatarUrl()));
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
    getVideos(successCall: (result) {
      if (mounted) {
        setState(() => videos
          ..clear()
          ..addAll(result)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)));
      }
      controller.refreshCompleted();
    }, errorCall: () {
      controller.refreshCompleted();
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      alignment: Alignment.center,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ScrollConfiguration(
            behavior: NoBoundaryRippleBehavior(),
            child: SmartRefresher(
              controller: controller,
              enablePullDown: true,
              enablePullUp: false,
              onRefresh: onRefresh,
              child: videos.isNotEmpty
                  ? PageView.builder(
                      controller: pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: videos.length + (isLastPage ? 0 : 1),
                      onPageChanged: (index) {
                        curIndex = index;
                        if (index == videos.length) {
                          curPageNum++;
                          getVideos(successCall: (result) {
                            if (mounted) {
                              setState(() => videos
                                ..addAll(result)
                                ..sort((a, b) =>
                                    a.timestamp.compareTo(b.timestamp)));
                            }
                          });
                        }
                      },
                      itemBuilder: (context, index) {
                        if (index == videos.length) {
                          return const C(0);
                        } else {
                          return VideoWidget(videoUrl: videos[index].url);
                        }
                      },
                    )
                  : Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 64),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Assets.images.noMerchants.image(fit: BoxFit.cover),
                          Text(
                            '当前没有任何短视频发布',
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
          FutureBuilder(
            future: initialCompleter.future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == true) {
                return buildControlView();
              } else {
                return const C(0);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildControlView() {
    _Video video = videos[curIndex];
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          right: 9,
          top: MediaQuery.of(context).size.height * 329 / 812,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: video.avatarUrl == null
                    ? Assets.images.personDefault.image(
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl:
                            'http://${Api.host}:${Api.port}/person/downloadAvatar?fileName=${video.avatarUrl}',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
              ),
              const C(24),
              LikeButton(
                onTap: (isLiked) => Fluttertoast.showToast(msg: '功能还未开发，敬请期待'),
                size: 36,
                circleColor: const CircleColor(
                  start: ColorName.redEC008E,
                  end: ColorName.redFC6767,
                ),
                bubblesColor: const BubblesColor(
                  dotPrimaryColor: ColorName.redF958A3,
                  dotSecondaryColor: ColorName.redFF6FA2,
                ),
                likeBuilder: (bool isLiked) {
                  return Assets.images.like.image(
                    width: 36,
                    height: 36,
                    color: isLiked
                        ? ColorName.redF14336
                        : Colors.white.withOpacity(0.9),
                  );
                },
              ),
              const C(24),
              InkWell(
                onTap: () => Fluttertoast.showToast(msg: '功能还未开发，敬请期待'),
                child: Assets.images.comment.image(
                  width: 36,
                  height: 36,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const C(24),
              InkWell(
                onTap: () => Fluttertoast.showToast(msg: '功能还未开发，敬请期待'),
                child: Assets.images.share.image(
                  width: 36,
                  height: 36,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _Video {
  final String id;
  final String userId;
  final String fileName;
  final int timestamp;
  late String url;
  late String? avatarUrl;

  _Video(this.id, this.userId, this.fileName, this.timestamp);

  void setVideoUrl() {
    url =
        'http://${Api.host}:${Api.port}/video/downloadVideo?fileName=$fileName';
  }

  Future<void> setAvatarUrl() async {
    Response response =
        await DioClient.get(Api.getUserInfo, {'userId': userId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        avatarUrl = map['avatarUrl'];
      }
    }
  }
}
