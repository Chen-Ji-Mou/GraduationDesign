import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/api.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/user_context.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class _Favorite {
  final String id;
  final String videoId;
  final int timestamp;
  late String videoUrl;
  late int favoriteCount;

  _Favorite(this.id, this.videoId, this.timestamp);

  Future<void> getVideoInfo() async {
    Response response =
        await DioClient.get(Api.getVideoInfo, {'videoId': videoId});
    if (response.statusCode == 200 && response.data != null) {
      if (response.data['code'] == 200) {
        Map<String, dynamic> map = response.data['data'];
        videoUrl =
            'http://${Api.host}:${Api.port}/video/downloadVideo?fileName=${map['fileName']}';
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
}

class MyFavoriteScreen extends StatefulWidget {
  const MyFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyFavoriteState();
}

class _MyFavoriteState extends State<MyFavoriteScreen>
    with AutomaticKeepAliveClientMixin {
  final RefreshController refreshController = RefreshController();
  final double aspectRatio = 168 / 216;
  final List<_Favorite> favorites = [];
  final int pageSize = 6;

  late Size screenSize;
  late double itemWidth;
  late double itemHeight;

  int curPageNum = 0;
  bool isLastPage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
    itemWidth = (screenSize.width - 39) / 2;
    itemHeight = itemWidth / aspectRatio;
  }

  @override
  void initState() {
    super.initState();
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

  void onLoading() {
    if (!isLastPage) {
      curPageNum++;
    }
    getFavorites(successCall: (result) {
      if (mounted && result.isNotEmpty) {
        setState(() => favorites.addAll(result));
      }
      refreshController.loadComplete();
    }, errorCall: () {
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
    super.build(context);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: screenSize.width,
            height: 48,
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: Text(
              '收藏夹',
              style: GoogleFonts.roboto(
                height: 1,
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: NoBoundaryRippleBehavior(),
              child: SmartRefresher(
                controller: refreshController,
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: onRefresh,
                onLoading: onLoading,
                child: favorites.isNotEmpty
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 7,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: favorites.length,
                        itemBuilder: buildFavoriteItem,
                      )
                    : const _FavoriteEmptyWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFavoriteItem(BuildContext context, int index) {
    _Favorite favorite = favorites[index];
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, 'favoriteDetail', arguments: index),
      onLongPress: () => deleteFavorite(favorite),
      child: Container(
        width: itemWidth,
        height: itemHeight,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: ColorName.gray8A8A8A,
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
              child: SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: FutureBuilder(
                  future: generateVideoThumbnailData(favorite.videoUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data != null) {
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    } else if (snapshot.connectionState ==
                            ConnectionState.done &&
                        snapshot.data == null) {
                      return Assets.images.imgThumbnailLoadFailed.image(
                        fit: BoxFit.cover,
                      );
                    } else {
                      return const LoadingWidget();
                    }
                  },
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Assets.images.like.image(
                    width: 20,
                    height: 20,
                    color: Colors.white,
                  ),
                  const C(4),
                  Text(
                    favorite.favoriteCount.toString(),
                    style: GoogleFonts.roboto(
                      height: 1,
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Future<Uint8List?> generateVideoThumbnailData(String videoUrl) async {
    return await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: itemWidth.toInt(),
      maxHeight: itemHeight.toInt(),
      quality: 80,
    );
  }

  Future<void> deleteFavorite(_Favorite favorite) async {
    bool result = await showDeleteConfirmAlert();
    if (result) {
      Response response = await DioClient.post(
          Api.deleteFavorite, {'videoId': favorite.videoId});
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['code'] == 200) {
          Fluttertoast.showToast(msg: '删除成功');
          if (mounted) {
            setState(() => favorites.remove(favorite));
          }
        } else {
          Fluttertoast.showToast(msg: response.data['msg']);
        }
      }
    }
  }

  Future<bool> showDeleteConfirmAlert() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('提示'),
            content: const Text('是否要删除此收藏，删除后不可恢复'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确定'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  bool get wantKeepAlive => UserContext.isLogin;
}

class _FavoriteEmptyWidget extends StatelessWidget {
  const _FavoriteEmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.imgFavoriteEmpty.image(fit: BoxFit.cover),
          Text(
            '当前收藏夹为空',
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
