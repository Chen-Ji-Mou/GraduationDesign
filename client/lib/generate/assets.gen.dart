/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/arrow-left.png
  AssetGenImage get arrowLeft =>
      const AssetGenImage('assets/images/arrow-left.png');

  /// File path: assets/images/back.png
  AssetGenImage get back => const AssetGenImage('assets/images/back.png');

  /// File path: assets/images/cover-text.png
  AssetGenImage get coverText =>
      const AssetGenImage('assets/images/cover-text.png');

  /// File path: assets/images/cover.png
  AssetGenImage get cover => const AssetGenImage('assets/images/cover.png');

  /// File path: assets/images/gift-box.png
  AssetGenImage get giftBox =>
      const AssetGenImage('assets/images/gift-box.png');

  /// File path: assets/images/heart.png
  AssetGenImage get heart => const AssetGenImage('assets/images/heart.png');

  /// File path: assets/images/home.png
  AssetGenImage get home => const AssetGenImage('assets/images/home.png');

  /// File path: assets/images/like.png
  AssetGenImage get like => const AssetGenImage('assets/images/like.png');

  /// File path: assets/images/love.png
  AssetGenImage get love => const AssetGenImage('assets/images/love.png');

  /// File path: assets/images/search.png
  AssetGenImage get search => const AssetGenImage('assets/images/search.png');

  /// File path: assets/images/send.png
  AssetGenImage get send => const AssetGenImage('assets/images/send.png');

  /// File path: assets/images/star.png
  AssetGenImage get star => const AssetGenImage('assets/images/star.png');

  /// File path: assets/images/success-mark.png
  AssetGenImage get successMark =>
      const AssetGenImage('assets/images/success-mark.png');

  /// File path: assets/images/user.png
  AssetGenImage get user => const AssetGenImage('assets/images/user.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        arrowLeft,
        back,
        coverText,
        cover,
        giftBox,
        heart,
        home,
        like,
        love,
        search,
        send,
        star,
        successMark,
        user
      ];
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider() => AssetImage(_assetName);

  String get path => _assetName;

  String get keyName => _assetName;
}
