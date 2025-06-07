import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo_core/otogapo_core.dart';

class OpstechTabBar extends StatelessWidget {
  const OpstechTabBar({
    required TabController tabController,
    required this.tabs,
    super.key,
  }) : _tabController = tabController;

  final List<Widget> tabs;
  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: const Color(0xFFf8faf7),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: PreferredSize(
          preferredSize: const Size.fromHeight(47),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                // indicatorColor: OpstechColors.blue,
                indicator: UnderlineTabIndicator(
                  borderSide: const BorderSide(
                    color: OpstechColors.blue,
                  ),
                  insets: EdgeInsets.fromLTRB(100.w, 0, 100.w, 0),
                ),
                tabs: tabs,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
