import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:graduationdesign/common.dart';

class VideoWidget extends StatefulWidget {
  const VideoWidget({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  final String videoUrl;

  @override
  State<StatefulWidget> createState() => _VideoState();
}

class _VideoState extends State<VideoWidget>
    with AutomaticKeepAliveClientMixin<VideoWidget> {
  String get videoUrl => widget.videoUrl;

  late BetterPlayerController controller;

  bool isDisposing = false;

  @override
  void initState() {
    super.initState();
    var dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl,
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: true,
        preCacheSize: 1 * 1024 * 1024,
        maxCacheSize: 20 * 1024 * 1024,
        maxCacheFileSize: 20 * 1024 * 1024,
        key: videoUrl,
      ),
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 2000,
        maxBufferMs: 10000,
        bufferForPlaybackMs: 1000,
        bufferForPlaybackAfterRebufferMs: 2000,
      ),
    );
    var config = BetterPlayerConfiguration(
      autoPlay: true,
      looping: true,
      fit: BoxFit.contain,
      playerVisibilityChangedBehavior: onVisibilityChanged,
      placeholder: const LoadingWidget(),
      showPlaceholderUntilPlay: true,
    );
    controller = BetterPlayerController(config);
    controller.setupDataSource(dataSource);
    controller.setControlsEnabled(false);
  }

  @override
  void dispose() {
    isDisposing = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double aspectRatio = calculateAspectRatio(context);
    controller.setOverriddenAspectRatio(aspectRatio);
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: BetterPlayer(
        key: Key(UniqueKey().toString()),
        controller: controller,
      ),
    );
  }

  void onVisibilityChanged(double visibleFraction) async {
    final bool? isPlaying = controller.isPlaying();
    final bool? initialized = controller.isVideoInitialized();
    if (visibleFraction >= 0.6) {
      if (initialized == true && isPlaying == false && !isDisposing) {
        controller.play();
      }
    } else {
      if (initialized == true && isPlaying == true && !isDisposing) {
        controller.pause();
      }
    }
  }

  double calculateAspectRatio(BuildContext context) =>
      MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;

  @override
  bool get wantKeepAlive => true;
}
