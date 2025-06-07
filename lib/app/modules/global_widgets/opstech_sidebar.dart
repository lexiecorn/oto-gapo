import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo_core/otogapo_core.dart';

class PickerSideBar extends StatefulWidget {
  const PickerSideBar({
    super.key,
  });

  @override
  State<PickerSideBar> createState() => _PickerSideBarState();
}

class _PickerSideBarState extends State<PickerSideBar> {
  final String pkgInfo = FlavorConfig.instance.variables['pkgInfoVersion'].toString();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              SizedBox(
                height: 450.sp,
                child: DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/logo_horizontal.png',
                                height: 150.sp,
                              ),
                            ],
                          ),
                          Builder(
                            builder: (context) => IconButton(
                              onPressed: () => Scaffold.of(context).closeDrawer(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: OpstechColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: OpstechColors.green,
                  ),
                ),
                title: Text(
                  'Picking',
                  style: OpstechTextTheme.heading3.copyWith(
                    color: OpstechColors.green,
                  ),
                ),
                onTap: () {},
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 30.w,
              vertical: 30.w,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: [
                      // Text(pkgInfo),
                      Icon(Icons.person_outline, size: 100.sp),
                      SizedBox(
                        width: 70.sp,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.read<AuthBloc>().state.user?.email ?? '',
                            style: OpstechTextTheme.heading4,
                          ),
                          Text(
                            pkgInfo,
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.read<AuthBloc>().add(SignoutRequestedEvent()),
                      icon: Icon(
                        Icons.logout,
                        size: 100.sp,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.read<AuthBloc>().add(SignoutRequestedEvent()),
                      child: Text(
                        'Logout',
                        style: OpstechTextTheme.heading3.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
