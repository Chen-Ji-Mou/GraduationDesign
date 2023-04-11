import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/assets.gen.dart';
import 'package:graduationdesign/generate/colors.gen.dart';

class LiveHallScreen extends StatefulWidget {
  const LiveHallScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LiveHallState();
}

class _LiveHallState extends State<LiveHallScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          buildSearchBox(hint: '点击搜索直播间'),

        ],
      ),
    );
  }

  Widget buildSearchBox({required String hint}) {
    return InkWell(
      child: Container(
        height: 30,
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: ColorName.whiteF6F7F8,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.search
                .image(width: 16, height: 16, color: ColorName.greyB4B4B5),
            const C(8),
            Text(
              hint,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ColorName.greyB4B4B5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
