import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduationdesign/common.dart';
import 'package:graduationdesign/generate/colors.gen.dart';
import 'package:graduationdesign/platform/file_load_platform.dart';
import 'package:graduationdesign/platform/permission_platform.dart';
import 'package:graduationdesign/sp_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<String> tabs = ['tab1', 'tab2'];

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          TabBar(
            controller: tabController,
            tabs: tabs.map((value) => Tab(height: 44, text: value)).toList(),
            indicatorColor: Colors.redAccent,
            indicatorWeight: 2,
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.black87,
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children:
              tabs.map((value) => Center(child: Text(value))).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
