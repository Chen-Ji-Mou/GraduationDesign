import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/dialog/comment_bottom_sheet.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/widget/video_widget.dart';
import 'package:like_button/like_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';

class _Favorite {
  final String id;
  final String videoId;
  final int timestamp;
  late String videoUrl;
  late String authorId;
  late String? avatarUrl;
  late int favoriteCount;
  late int commentCount;
  late int shareCount;
  bool isOwnLiked = true;

  _Favorite(this.id, this.videoId, this.timestamp);

  Future<void> getVideoInfo() async {
    Response response =
        await DioClient.get(Api.getVideoInfo, {'videoId': videoId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        authorId = map['userId'];
        videoUrl =
            'http://${Api.host}:${Api.port}/video/downloadVideo?fileName=${map['fileName']}';
        shareCount = map['shareCount'];
      }
    }
  }

  Future<void> setAvatarUrl() async {
    Response response =
        await DioClient.get(Api.getUserInfo, {'userId': authorId});
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
        await DioClient.get(Api.getVideoFavoriteCount, {'videoId': videoId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        favoriteCount = response.data['data'];
      }
    }
  }

  Future<void> setCommentCount() async {
    Response response =
        await DioClient.get(Api.getVideoCommentCount, {'videoId': videoId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        commentCount = response.data['data'];
      }
    }
  }
}

class MyFavoriteDetailScreen extends StatefulWidget {
  const MyFavoriteDetailScreen({
    Key? key,
    required this.initialIndex,
  }) : super(key: key);

  final int initialIndex;

  @override
  State<StatefulWidget> createState() => _MyFavoriteDetailState();
}

class _MyFavoriteDetailState extends State<MyFavoriteDetailScreen> {
  int get initialIndex => widget.initialIndex;

  final RefreshController refreshController = RefreshController();

  late ValueNotifier<int> curPageNotifier;
  late PageController pageController;

  final List<_Favorite> favorites = [];
  final int pageSize = 1;

  int curPageNum = 0;

  @override
  void initState() {
    super.initState();
    curPageNum = initialIndex;
    curPageNotifier = ValueNotifier(curPageNum);
    pageController =
        PageController(initialPage: curPageNum, viewportFraction: 1.0);
    getFavorites(successCall: (result) {
      if (mounted) {
        setState(() => favorites.addAll(result));
      }
    });
  }

  void getFavorites({
    required RequestSuccessCallback<_Favorite> successCall,
    VoidCallback? errorCall,
  }) {
    DioClient.get(Api.getUserFavorites, {
      'pageNum': curPageNum,
      'pageSize': pageSize,
    }).then((response) async {
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          List<_Favorite> result = [];
          for (var favorite in response.data['data']) {
            _Favorite item = _Favorite(
              favorite['id'],
              favorite['videoId'],
              favorite['timestamp'],
            );
            result.add(item);
          }
          await Future.wait([
            Future.wait(result.map((e) => e.getVideoInfo())),
            Future.wait(result.map((e) => e.setFavoriteCount())),
            Future.wait(result.map((e) => e.setCommentCount())),
          ]);
          await Future.wait(result.map((e) => e.setAvatarUrl()));
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
    getFavorites(successCall: (result) {
      if (mounted) {
        setState(() => favorites
          ..clear()
          ..addAll(result));
      }
      refreshController.refreshCompleted();
    }, errorCall: () {
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
    return Scaffold(
      body: Container(
        color: Colors.black,
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: toolbarHeight),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ScrollConfiguration(
              behavior: NoBoundaryRippleBehavior(),
              child: SmartRefresher(
                controller: refreshController,
                enablePullDown: favorites.isEmpty,
                enablePullUp: false,
                onRefresh: onRefresh,
                child: PageView.builder(
                  controller: pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: favorites.length + 1,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    if (index == favorites.length) {
                      return Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: const C(1),
                      );
                    } else {
                      return VideoWidget(videoUrl: favorites[index].videoUrl);
                    }
                  },
                ),
              ),
            ),
            if (favorites.isNotEmpty)
              _ControllerView(
                favorites: favorites,
                curPageNotifier: curPageNotifier,
              )
            else
              const C(0),
            Positioned(
              left: 16,
              top: 12,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onPageChanged(int index) {
    curPageNotifier.value = index;
    if (index == favorites.length) {
      curPageNum++;
      getFavorites(successCall: (result) {
        if (mounted && result.isNotEmpty) {
          setState(() => favorites.addAll(result));
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
}

class _ControllerView extends StatefulWidget {
  const _ControllerView({
    Key? key,
    required this.favorites,
    required this.curPageNotifier,
  }) : super(key: key);

  final List<_Favorite> favorites;
  final ValueNotifier<int> curPageNotifier;

  @override
  State<StatefulWidget> createState() => _ControllerViewState();
}

class _ControllerViewState extends State<_ControllerView> {
  List<_Favorite> get favorites => widget.favorites;

  ValueNotifier<int> get curPageNotifier => widget.curPageNotifier;

  final ValueNotifier<int> favoriteCount = ValueNotifier(0);

  late _Favorite curFavorite;
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
    isLoadMore = curPageNotifier.value == favorites.length;
    if (isLoadMore) {
      return const C(0);
    } else {
      curFavorite = favorites[curIndex];
      favoriteCount.value = curFavorite.favoriteCount;
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
                    result =
                        isLiked ? await removeFavorite() : await addFavorite();
                    curFavorite.isOwnLiked = result;
                    result ? favoriteCount.value++ : favoriteCount.value--;
                    return result;
                  },
                ),
                const C(24),
                buildCommentButton(
                  onTap: () => CommentBottomSheet.show(
                    context,
                    screenSize: screenSize,
                    videoId: curFavorite.videoId,
                  ),
                ),
                const C(24),
                buildShareButton(
                  onTap: () async {
                    await Share.share(
                      '这里有一个很有趣的视频快来查收哦\n${curFavorite.videoUrl}\n——直播电商定制APP',
                    );
                    int result = await updateShareCount();
                    if (mounted) {
                      setState(() => curFavorite.shareCount = result);
                    }
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
        child: curFavorite.avatarUrl == null
            ? const DefaultAvatarWidget(size: 56)
            : CachedNetworkImage(
                imageUrl: curFavorite.avatarUrl!,
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
          isLiked: curFavorite.isOwnLiked,
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
          curFavorite.commentCount.toString(),
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
          curFavorite.shareCount.toString(),
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
        await DioClient.post(Api.addFavorite, {'videoId': curFavorite.id});
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
        await DioClient.post(Api.deleteFavorite, {'videoId': curFavorite.id});
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

  Future<int> updateShareCount() async {
    Response response =
        await DioClient.post(Api.updateShareCount, {'videoId': curFavorite.id});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        return response.data['data'];
      } else {
        Fluttertoast.showToast(msg: response.data['msg']);
        return curFavorite.shareCount;
      }
    } else {
      return curFavorite.shareCount;
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
