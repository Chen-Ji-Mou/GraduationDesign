import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/widget/push_stream_widget.dart';

class _FilterItem {
  final Filter filterType;
  final ImageProvider icon;
  final String title;

  _FilterItem({
    required this.filterType,
    required this.icon,
    required this.title,
  });
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    Key? key,
    required this.screenSize,
    required this.controller,
    this.isRecord = false,
  }) : super(key: key);

  final Size screenSize;
  final PushStreamController controller;
  final bool isRecord;

  static Future<bool?> show(
    BuildContext context, {
    required Size screenSize,
    required PushStreamController controller,
    bool isRecord = false,
  }) async {
    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        screenSize: screenSize,
        controller: controller,
        isRecord: isRecord,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  Size get screenSize => widget.screenSize;

  PushStreamController get controller => widget.controller;

  bool get isRecord => widget.isRecord;

  late List<_FilterItem> items = [
    if (isRecord) ...[
      _FilterItem(
        filterType: Filter.cancel,
        icon: Assets.images.filterDefault.provider(),
        title: '原图',
      ),
      _FilterItem(
        filterType: Filter.vintageTV,
        icon: Assets.images.filterDefault.provider(),
        title: '老式电视',
      ),
      _FilterItem(
        filterType: Filter.wave,
        icon: Assets.images.filterDefault.provider(),
        title: '波浪',
      ),
      _FilterItem(
        filterType: Filter.cartoon,
        icon: Assets.images.filterDefault.provider(),
        title: '卡通',
      ),
      _FilterItem(
        filterType: Filter.profound,
        icon: Assets.images.filterDefault.provider(),
        title: '深邃',
      ),
      _FilterItem(
        filterType: Filter.snow,
        icon: Assets.images.filterDefault.provider(),
        title: '雪花',
      ),
      _FilterItem(
        filterType: Filter.oldPhoto,
        icon: Assets.images.filterDefault.provider(),
        title: '旧照片',
      ),
      _FilterItem(
        filterType: Filter.lamoish,
        icon: Assets.images.filterDefault.provider(),
        title: 'Lamoish',
      ),
      _FilterItem(
        filterType: Filter.money,
        icon: Assets.images.filterDefault.provider(),
        title: '美元',
      ),
      _FilterItem(
        filterType: Filter.waterRipple,
        icon: Assets.images.filterDefault.provider(),
        title: '水波纹',
      ),
    ] else ...[
      _FilterItem(
        filterType: Filter.cancel,
        icon: Assets.images.filterDefault.provider(),
        title: '还原',
      ),
      _FilterItem(
        filterType: Filter.bigEye,
        icon: Assets.images.filterDefault.provider(),
        title: '大眼滤镜',
      ),
      _FilterItem(
        filterType: Filter.stick,
        icon: Assets.images.filterDefault.provider(),
        title: '兔耳滤镜',
      ),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenSize.width / 4 + 16,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Scrollbar(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: items.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => buildItem(items[index]),
          separatorBuilder: (context, index) => const C(10),
        ),
      ),
    );
  }

  Widget buildItem(_FilterItem item) {
    return InkWell(
      onTap: () async {
        await controller.selectFilter(item.filterType);
        exit();
      },
      child: Container(
        width: screenSize.width / 4,
        height: screenSize.width / 4,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: item.icon,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
            const C(8),
            Text(
              item.title,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 14 / 13,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void exit() => Navigator.pop(context);
}
