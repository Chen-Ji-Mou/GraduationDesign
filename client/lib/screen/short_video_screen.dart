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
  final ValueNotifier<int> curPageNotifier = ValueNotifier(0);

  late PageController pageController;

  final List<_Video> videos = [];
  final int pageSize = 2;

  int curPageNum = 0;
  bool isLastPage = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 1.0);
    loading = true;
    getVideos(successCall: (result) {
      if (mounted) {
        setState(() {
          videos.addAll(result);
          loading = false;
        });
      }
      initialCompleter.complete(videos.isNotEmpty);
    }, errorCall: () {
      if (mounted) {
        setState(() => loading = false);
      }
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
              video['shareCount'],
            )..setVideoUrl();
            result.add(item);
          }
          await Future.wait([
            Future.wait(result.map((e) => e.setAvatarUrl())),
            Future.wait(result.map((e) => e.setFavoriteCount())),
            Future.wait(result.map((e) => e.setCommentCount())),
            Future.wait(result.map((e) => e.verifyOwnLiked())),
          ]);
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
    if (mounted) {
      setState(() => loading = true);
    }
    curPageNum = 0;
    getVideos(successCall: (result) {
      if (mounted) {
        setState(() {
          videos
            ..clear()
            ..addAll(result);
          loading = false;
        });
      }
      controller.refreshCompleted();
    }, errorCall: () {
      if (mounted) {
        setState(() => loading = false);
      }
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
              enablePullDown: videos.isEmpty,
              enablePullUp: false,
              onRefresh: onRefresh,
              child: videos.isNotEmpty
                  ? PageView.builder(
                      controller: pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: videos.length + (isLastPage ? 0 : 1),
                      onPageChanged: (index) {
                        curPageNotifier.value = index;
                        if (index == videos.length) {
                          curPageNum++;
                          getVideos(successCall: (result) {
                            if (mounted && result.isNotEmpty) {
                              setState(() => videos.addAll(result));
                            } else if (result.isEmpty) {
                              setState(() {
                                pageController.animateToPage(
                                  index - 1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              });
                            }
                          });
                        }
                      },
                      itemBuilder: (context, index) {
                        if (index == videos.length) {
                          return Container(
                            color: Colors.black,
                            alignment: Alignment.center,
                            child: const C(1),
                          );
                        } else {
                          return VideoWidget(videoUrl: videos[index].videoUrl);
                        }
                      },
                    )
                  : loading
                      ? const _VideoLoadingWidget()
                      : const _VideoEmptyWidget(),
            ),
          ),
          FutureBuilder(
            future: initialCompleter.future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == true) {
                return _ControllerView(
                  videos: videos,
                  curPageNotifier: curPageNotifier,
                );
              } else {
                return const C(0);
              }
            },
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
  int shareCount;
  late String videoUrl;
  late String? avatarUrl;
  late int favoriteCount;
  late int commentCount;
  late bool isOwnLiked;

  _Video(this.id, this.userId, this.fileName, this.timestamp, this.shareCount);

  void setVideoUrl() {
    videoUrl =
        'http://${Api.host}:${Api.port}/video/downloadVideo?fileName=$fileName';
  }

  Future<void> setAvatarUrl() async {
    Response response =
        await DioClient.get(Api.getUserInfo, {'userId': userId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        avatarUrl = map['avatarUrl'] != null
            ? 'http://${Api.host}:${Api.port}/person/downloadAvatar?fileName=${map['avatarUrl']}'
            : null;
      }
    }
  }

  Future<void> setFavoriteCount() async {
    Response response =
        await DioClient.get(Api.getVideoFavoriteCount, {'videoId': id});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        favoriteCount = response.data['data'];
      }
    }
  }

  Future<void> setCommentCount() async {
    Response response =
        await DioClient.get(Api.getVideoCommentCount, {'videoId': id});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        commentCount = response.data['data'];
      }
    }
  }

  Future<void> verifyOwnLiked() async {
    Response response =
        await DioClient.get(Api.verifyVideoHasOwnFavorite, {'videoId': id});
    if (response.statusCode == 200 && response.data != null) {
      isOwnLiked = response.data['code'] == 200;
    }
  }
}

class _ControllerView extends StatefulWidget {
  const _ControllerView({
    Key? key,
    required this.videos,
    required this.curPageNotifier,
  }) : super(key: key);

  final List<_Video> videos;
  final ValueNotifier<int> curPageNotifier;

  @override
  State<StatefulWidget> createState() => _ControllerViewState();
}

class _ControllerViewState extends State<_ControllerView> {
  List<_Video> get videos => widget.videos;

  ValueNotifier<int> get curPageNotifier => widget.curPageNotifier;

  late ValueNotifier<int> favoriteCount;
  late _Video video;

  int curIndex = 0;
  bool isLoadMore = false;

  @override
  void initState() {
    super.initState();
    curPageNotifier.addListener(onPageChanged);
    favoriteCount =
        ValueNotifier(videos.isNotEmpty ? videos[curIndex].favoriteCount : 0);
  }

  @override
  void dispose() {
    curPageNotifier.removeListener(onPageChanged);
    super.dispose();
  }

  void onPageChanged() {
    if (mounted) {
      setState(() => curIndex = curPageNotifier.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '[$runtimeType] build curPageNotifier.value ${curPageNotifier.value}');
    debugPrint('[$runtimeType] build videos.length ${videos.length}');
    debugPrint('[$runtimeType] build curIndex $curIndex');
    isLoadMore = curPageNotifier.value == videos.length;
    if (isLoadMore) {
      return const C(0);
    } else {
      video = videos[curIndex];
      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: 9,
            top: MediaQuery.of(context).size.height * 300 / 812,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildAvatar(),
                const C(24),
                buildLikeButton(
                  onTap: (isLiked) async {
                    bool result =
                        isLiked ? await removeFavorite() : await addFavorite();
                    video.isOwnLiked = result;
                    result ? favoriteCount.value++ : favoriteCount.value--;
                    return result;
                  },
                ),
                const C(24),
                buildCommentButton(
                  onTap: () => Fluttertoast.showToast(msg: '功能还未开发，敬请期待'),
                ),
                const C(24),
                buildShareButton(
                  onTap: () => Fluttertoast.showToast(msg: '功能还未开发，敬请期待'),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget buildAvatar({VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: video.avatarUrl == null
            ? const DefaultAvatarWidget(
                width: 56,
                height: 56,
                iconSize: 32,
              )
            : CachedNetworkImage(
                imageUrl: video.avatarUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget buildLikeButton({Future<bool?> Function(bool isLiked)? onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LikeButton(
          onTap: onTap,
          size: 36,
          isLiked: video.isOwnLiked,
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
              color: isLiked ? ColorName.redF14336 : Colors.white,
            );
          },
        ),
        const C(2),
        _FavoriteCountWidget(favoriteCount: favoriteCount),
      ],
    );
  }

  Widget buildCommentButton({VoidCallback? onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Assets.images.comment.image(
            width: 36,
            height: 36,
            color: Colors.white,
          ),
        ),
        const C(2),
        Text(
          video.commentCount.toString(),
          style: GoogleFonts.roboto(
            fontSize: 13,
            height: 16 / 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget buildShareButton({VoidCallback? onTap}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Assets.images.share.image(
            width: 36,
            height: 36,
            color: Colors.white,
          ),
        ),
        const C(2),
        Text(
          video.shareCount.toString(),
          style: GoogleFonts.roboto(
            fontSize: 13,
            height: 16 / 13,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<bool> addFavorite() async {
    Response response =
        await DioClient.post(Api.addFavorite, {'videoId': video.id});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        return true;
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> removeFavorite() async {
    Response response =
        await DioClient.post(Api.deleteFavorite, {'videoId': video.id});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        return false;
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
        return true;
      }
    } else {
      return true;
    }
  }
}

class _FavoriteCountWidget extends StatefulWidget {
  const _FavoriteCountWidget({
    Key? key,
    required this.favoriteCount,
  }) : super(key: key);

  final ValueNotifier<int> favoriteCount;

  @override
  State<StatefulWidget> createState() => _FavoriteCountState();
}

class _FavoriteCountState extends State<_FavoriteCountWidget> {
  ValueNotifier<int> get favoriteCount => widget.favoriteCount;

  @override
  void initState() {
    super.initState();
    favoriteCount.addListener(favoriteCountChanged);
  }

  @override
  void dispose() {
    favoriteCount.removeListener(favoriteCountChanged);
    super.dispose();
  }

  void favoriteCountChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      favoriteCount.value.toString(),
      style: GoogleFonts.roboto(
        fontSize: 13,
        height: 16 / 13,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _VideoEmptyWidget extends StatelessWidget {
  const _VideoEmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _VideoLoadingWidget extends StatelessWidget {
  const _VideoLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.videoLoading.image(fit: BoxFit.cover),
          Text(
            '正在加载中，请稍后...',
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
