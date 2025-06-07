import 'package:flutter/material.dart';
import 'package:otogapo_core/otogapo_core.dart';

class OpstechAppBar extends StatelessWidget {
  const OpstechAppBar({
    this.apptitle = const SizedBox.shrink(),
    this.leading,
    this.myAction,
    super.key,
  });

  final Widget apptitle;
  final Widget? leading;
  final List<Widget>? myAction;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: OpstechColors.white,
      title: apptitle,
      leading: leading ??
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                Icons.menu,
                color: OpstechColors.black,
              ),
            ),
          ),
      // actions: myAction,
      actions: myAction,
    );
  }
}
