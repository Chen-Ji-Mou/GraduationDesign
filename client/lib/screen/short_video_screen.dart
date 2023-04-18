import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/widget/video_widget.dart';
import 'package:like_button/like_button.dart';

class ShortVideoScreen extends StatefulWidget {
  const ShortVideoScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShortVideoState();
}

class _ShortVideoState extends State<ShortVideoScreen>
    with AutomaticKeepAliveClientMixin {
  late PageController pageController;

  final List<_Video> videos = [];
  final int pageSize = 5;
  final int nextPageTrigger = 2;

  int pageNum = 0;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 1.0);
    getVideos();
  }

  void getVideos() {
    DioClient.get(Api.getVideos, {
      'pageNum': pageNum,
      'pageSize': pageSize,
    }).then((response) {
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
          isLastPage = result.length < pageSize;
          if (mounted) {
            setState(() => videos.addAll(result));
          }
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
        }
      }
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
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              if (index == videos.length - nextPageTrigger) {
                getVideos();
              }
              return VideoWidget(videoUrl: videos[index].url);
            },
          ),
          Positioned(
            right: 9,
            top: MediaQuery.of(context).size.height * 369 / 812,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Assets.images.personDefault.image(
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const C(24),
                LikeButton(
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
                Assets.images.comment.image(
                  width: 36,
                  height: 36,
                  color: Colors.white.withOpacity(0.9),
                ),
                const C(24),
                Assets.images.share.image(
                  width: 36,
                  height: 36,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),
        ],
      ),
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

  _Video(this.id, this.userId, this.fileName, this.timestamp);

  void setVideoUrl() {
    url =
        'http://${Api.host}:${Api.port}/video/downloadVideo?fileName=$fileName';
  }
}
