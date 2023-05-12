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
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

class CommentBottomSheet extends StatefulWidget {
  const CommentBottomSheet({
    Key? key,
    required this.screenSize,
    required this.videoId,
  }) : super(key: key);

  final Size screenSize;
  final String videoId;

  static Future<bool?> show(
    BuildContext context, {
    required Size screenSize,
    required String videoId,
  }) async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentBottomSheet(
        screenSize: screenSize,
        videoId: videoId,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  Size get screenSize => widget.screenSize;

  String get videoId => widget.videoId;

  final RefreshController refreshController = RefreshController();
  final List<_Comment> comments = [];
  final int pageSize = 10;

  int curPageNum = 0;
  bool isLastPage = false;

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
    required RequestSuccessCallback<_Comment> successCall,
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
    if (!isLastPage) {
      curPageNum++;
    }
    getComments(successCall: (result) {
      if (mounted && result.isNotEmpty) {
        setState(() => comments.addAll(result));
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
          const C(8),
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
          height: screenSize.height * 2 / 3,
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
