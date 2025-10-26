import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo_core/otogapo_core.dart';

class PickerSideBar extends StatefulWidget {
  const PickerSideBar({
    super.key,
  });

  @override
  State<PickerSideBar> createState() => _PickerSideBarState();
}

class _PickerSideBarState extends State<PickerSideBar> {
  final String pkgInfo =
      FlavorConfig.instance.variables['pkgInfoVersion'].toString();

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
                              onPressed: () =>
                                  Scaffold.of(context).closeDrawer(),
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
                            (context.read<AuthBloc>().state.user?.data['email']
                                    as String?) ??
                                '',
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
                      onPressed: () async {
                        // Show confirmation dialog
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text(
                                  'Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Logout'),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldLogout == true && context.mounted) {
                          final authBloc = context.read<AuthBloc>();

                          // Add logout event
                          authBloc.add(SignoutRequestedEvent());

                          // Wait for the logout to complete
                          await authBloc.stream
                              .firstWhere(
                            (state) =>
                                state.authStatus == AuthStatus.unauthenticated,
                            orElse: () => authBloc.state,
                          )
                              .timeout(
                            const Duration(seconds: 3),
                            onTimeout: () {
                              debugPrint('Logout timeout - forcing navigation');
                              return authBloc.state;
                            },
                          );

                          debugPrint(
                              'Logout completed, navigating to signin page');

                          // Navigate directly to signin page after logout completes
                          if (context.mounted) {
                            AutoRouter.of(context)
                                .replaceAll([const SigninPageRouter()]);
                          }
                        }
                      },
                      icon: Icon(
                        Icons.logout,
                        size: 100.sp,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Show confirmation dialog
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text(
                                  'Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Logout'),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldLogout == true && context.mounted) {
                          final authBloc = context.read<AuthBloc>();

                          // Add logout event
                          authBloc.add(SignoutRequestedEvent());

                          // Wait for the logout to complete
                          await authBloc.stream
                              .firstWhere(
                            (state) =>
                                state.authStatus == AuthStatus.unauthenticated,
                            orElse: () => authBloc.state,
                          )
                              .timeout(
                            const Duration(seconds: 3),
                            onTimeout: () {
                              debugPrint('Logout timeout - forcing navigation');
                              return authBloc.state;
                            },
                          );

                          debugPrint(
                              'Logout completed, navigating to signin page');

                          // Navigate directly to signin page after logout completes
                          if (context.mounted) {
                            AutoRouter.of(context)
                                .replaceAll([const SigninPageRouter()]);
                          }
                        }
                      },
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
