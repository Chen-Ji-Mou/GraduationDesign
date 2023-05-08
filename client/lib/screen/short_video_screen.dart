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
import 'package:graduationdesign/user_context.dart';
import 'package:graduationdesign/widget/video_widget.dart';
import 'package:like_button/like_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';

typedef _SuccessCallback<T> = void Function(List<T> videos);

class ShortVideoScreen extends StatefulWidget {
  const ShortVideoScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShortVideoState();
}

class _ShortVideoState extends State<ShortVideoScreen>
    with AutomaticKeepAliveClientMixin {
  final RefreshController refreshController = RefreshController();
  final ValueNotifier<int> curPageNotifier = ValueNotifier(0);

  late PageController pageController;

  final List<_Video> videos = [];
  final int pageSize = 1;

  int curPageNum = 0;
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
    }, errorCall: () {
      if (mounted) {
        setState(() => loading = false);
      }
    });
  }

  void getVideos({
    required _SuccessCallback<_Video> successCall,
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
      refreshController.refreshCompleted();
    }, errorCall: () {
      if (mounted) {
        setState(() => loading = false);
      }
      refreshController.refreshFailed();
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    refreshController.dispose();
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
              controller: refreshController,
              enablePullDown: videos.isEmpty,
              enablePullUp: false,
              onRefresh: onRefresh,
              child: videos.isNotEmpty
                  ? PageView.builder(
                      controller: pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: videos.length + 1,
                      onPageChanged: onPageChanged,
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
          if (videos.isNotEmpty)
            _ControllerView(
              videos: videos,
              curPageNotifier: curPageNotifier,
            )
          else
            const C(0),
        ],
      ),
    );
  }

  void onPageChanged(int index) {
    curPageNotifier.value = index;
    if (index == videos.length) {
      curPageNum++;
      getVideos(successCall: (result) {
        if (mounted && result.isNotEmpty) {
          setState(() => videos.addAll(result));
        } else if (result.isEmpty) {
          curPageNum--;
          pageController.animateToPage(
            index - 1,
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
          );
        }
      });
    }
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
  bool isOwnLiked = false;

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
    if (UserContext.isLogin) {
      Response response =
          await DioClient.get(Api.verifyVideoHasOwnFavorite, {'videoId': id});
      if (response.statusCode == 200 && response.data != null) {
        isOwnLiked = response.data['code'] == 200;
      }
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

  final ValueNotifier<int> favoriteCount = ValueNotifier(0);

  late _Video video;
  late Size screenSize;

  int curIndex = 0;
  bool isLoadMore = false;

  @override
  void initState() {
    super.initState();
    curPageNotifier.addListener(onPageChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
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
    isLoadMore = curPageNotifier.value == videos.length;
    if (isLoadMore) {
      return const C(0);
    } else {
      video = videos[curIndex];
      favoriteCount.value = video.favoriteCount;
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
                    bool result = isLiked;
                    UserContext.awaitLogin(context);
                    if (UserContext.isLogin) {
                      result = isLiked
                          ? await removeFavorite()
                          : await addFavorite();
                      video.isOwnLiked = result;
                      result ? favoriteCount.value++ : favoriteCount.value--;
                    }
                    return result;
                  },
                ),
                const C(24),
                buildCommentButton(
                  onTap: showCommentBottomSheet,
                ),
                const C(24),
                buildShareButton(
                  onTap: () {
                    UserContext.checkLoginCallback(context, () async {
                      await Share.share(
                        '这里有一个很有趣的视频快来查收哦\n${video.videoUrl}\n——直播电商定制APP',
                      );
                      int result = await updateShareCount();
                      if (mounted) {
                        setState(() => video.shareCount = result);
                      }
                    });
                  },
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
            ? const DefaultAvatarWidget(size: 56)
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

  Future<bool?> showCommentBottomSheet() async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentBottomSheet(
        screenSize: screenSize,
        videoId: video.id,
      ),
    );
  }

  Future<int> updateShareCount() async {
    Response response =
        await DioClient.post(Api.updateShareCount, {'videoId': video.id});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        return response.data['data'];
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
        return video.shareCount;
      }
    } else {
      return video.shareCount;
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

class _Comment {
  final String id;
  final String userId;
  final String videoId;
  final String content;
  final int timestamp;
  late String date;
  late String userName;
  late String? userAvatarUrl;

  _Comment(this.id, this.userId, this.videoId, this.content, this.timestamp);

  void setDate() {
    date = DateTime.fromMillisecondsSinceEpoch(timestamp)
        .toLocal()
        .toString()
        .substring(0, 16);
  }

  Future<void> getUserInfo() async {
    Response response =
        await DioClient.get(Api.getUserInfo, {'userId': userId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        userName = map['name'];
        userAvatarUrl = map['avatarUrl'] != null
            ? 'http://${Api.host}:${Api.port}/person/downloadAvatar?fileName=${map['avatarUrl']}'
            : null;
      }
    }
  }
}

class _CommentBottomSheet extends StatefulWidget {
  const _CommentBottomSheet({
    Key? key,
    required this.screenSize,
    required this.videoId,
  }) : super(key: key);

  final Size screenSize;
  final String videoId;

  @override
  State<StatefulWidget> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<_CommentBottomSheet> {
  Size get screenSize => widget.screenSize;

  String get videoId => widget.videoId;

  final RefreshController refreshController = RefreshController();
  final List<_Comment> comments = [];
  final int pageSize = 10;

  int curPageNum = 0;

  @override
  void initState() {
    super.initState();
    getComments(successCall: (result) {
      if (mounted) {
        setState(() => comments.addAll(result));
      }
    });
  }

  void getComments({
    required _SuccessCallback<_Comment> successCall,
    VoidCallback? errorCall,
  }) {
    DioClient.get(Api.getComments, {
      'videoId': videoId,
      'pageNum': curPageNum,
      'pageSize': pageSize,
    }).then((response) async {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          List<_Comment> result = [];
          for (var comment in response.data['data']) {
            _Comment item = _Comment(
              comment['id'],
              comment['userId'],
              comment['videoId'],
              comment['content'],
              comment['timestamp'],
            )..setDate();
            result.add(item);
          }
          await Future.wait(result.map((e) => e.getUserInfo()));
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
    getComments(successCall: (result) {
      if (mounted) {
        setState(() => comments
          ..clear()
          ..addAll(result));
      }
      refreshController.refreshCompleted();
    }, errorCall: () {
      refreshController.refreshFailed();
    });
  }

  void onLoading() {
    curPageNum++;
    getComments(successCall: (result) {
      if (mounted && result.isNotEmpty) {
        setState(() => comments.addAll(result));
      } else if (result.isEmpty) {
        curPageNum--;
      }
      refreshController.loadComplete();
    }, errorCall: () {
      curPageNum--;
      refreshController.loadFailed();
    });
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHeader(),
          Container(
            width: screenSize.width,
            height: 14,
            color: ColorName.grayF4F5F9,
          ),
          buildCommentList(),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        const C(16),
        InkWell(
          onTap: exit,
          child: const Icon(
            Icons.close,
            size: 24,
            color: ColorName.black333333,
          ),
        ),
        Container(
          height: 48,
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: screenSize.width / 2 - 56),
          child: Text(
            '评论',
            style: GoogleFonts.roboto(
              height: 1.2,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorName.black333333,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCommentList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const C(12),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            '所有评论',
            style: GoogleFonts.roboto(
              height: 1,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ColorName.black333333,
            ),
          ),
        ),
        SizedBox(
          height: screenSize.height - 196,
          child: Stack(
            children: [
              ScrollConfiguration(
                behavior: NoBoundaryRippleBehavior(),
                child: SmartRefresher(
                  controller: refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onRefresh: onRefresh,
                  onLoading: onLoading,
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: buildCommentItem,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: InkWell(
                  onTap: showInputBottomSheet,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: screenSize.width,
                        height: 1,
                        color: ColorName.grayE1E1E1,
                      ),
                      Container(
                        width: screenSize.width,
                        height: 46,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        child: Row(
                          children: [
                            const C(10),
                            Container(
                              width: screenSize.width * 0.8,
                              height: 34,
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              clipBehavior: Clip.antiAlias,
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: ColorName.grayF5F5F5,
                                borderRadius: BorderRadius.circular(23),
                              ),
                              child: Text(
                                '添加你的评论',
                                style: GoogleFonts.roboto(
                                  height: 1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: ColorName.gray999999,
                                ),
                              ),
                            ),
                            const C(12),
                            Assets.images.send.image(
                              width: 24,
                              height: 24,
                              color: ColorName.blue48A4EB,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCommentItem(BuildContext context, int index) {
    _Comment comment = comments[index];
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: comment.userAvatarUrl == null
                ? const DefaultAvatarWidget(size: 36)
                : CachedNetworkImage(
                    imageUrl: comment.userAvatarUrl!,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
          ),
          const C(16),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.userName,
                style: GoogleFonts.roboto(
                  height: 1.2,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: ColorName.black333333,
                ),
              ),
              Text(
                comment.date,
                style: GoogleFonts.roboto(
                  height: 1.2,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: ColorName.gray999999,
                ),
              ),
              const C(14),
              Text(
                comment.content,
                style: GoogleFonts.roboto(
                  height: 1.2,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: ColorName.black333333,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showInputBottomSheet() {
    UserContext.checkLoginCallback(context, () {
      InputBottomSheet.show(
        context,
        screenSize: screenSize,
        onInputComplete: addComment,
        builder: (inputController, onEditingComplete) {
          return Container(
            width: screenSize.width,
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                const C(10),
                Container(
                  width: screenSize.width * 0.8,
                  height: 34,
                  padding: const EdgeInsets.only(left: 16),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: ColorName.grayF5F5F5,
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: TextField(
                    controller: inputController,
                    autofocus: true,
                    maxLines: 1,
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    textInputAction: TextInputAction.send,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '请输入评论内容',
                      hintStyle: GoogleFonts.roboto(
                        fontWeight: FontWeight.normal,
                        color: ColorName.gray999999,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                const C(12),
                InkWell(
                  onTap: onEditingComplete,
                  child: Assets.images.send.image(
                    width: 24,
                    height: 24,
                    color: ColorName.blue48A4EB,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Future<void> addComment(String content) async {
    Response response = await DioClient.post(
        Api.addComment, {'videoId': videoId, 'content': content});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        onRefresh();
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
      }
    }
  }

  void exit() => Navigator.pop(context);
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
