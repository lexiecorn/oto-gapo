import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/modules/profile/profile_page.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo_core/otogapo_core.dart';

@RoutePage(
  name: 'IntroPageRouter',
)
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();

    _getProfile();
  }

  void _getProfile() {
    final uid = context.read<AuthBloc>().state.user!.uid;
    context.read<ProfileCubit>().getProfile(uid: uid);
  }

  final colorizeColors = [
    Colors.red, Colors.red,
    Colors.red,
    // Colors.black,
    Colors.white,
    Colors.cyan,
  ];

  final colorizeTextStyle = TextStyle(
    fontSize: 250.sp,
    fontFamily: 'Horizon',
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), () {
      AutoRouter.of(context).replace(const HomePageRouter());
    });

    return Scaffold(
      // gradient background

      // transparent bottom navigation bar

      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          return state.user.memberNumber == 0.toString()
              ? const SizedBox()
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red,
                        Colors.black,
                      ], // Start and end colors
                      // occupy color 2/3 of the space
                      stops: [0.0, 0.7],
                      begin: Alignment.topLeft, // Direction of gradient
                      end: Alignment.bottomRight, // Direction of gradient
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Stack(
                            children: [
                              OpstechExtendedImageAsset(
                                img: 'assets/images/auto_gapo_badge.png',
                                width: 900.w,
                                height: 900.w,
                              ),

                              // center positioned
                              Positioned.fill(
                                child: Align(
                                  child: AnimatedTextKit(
                                    repeatForever: true,
                                    animatedTexts: [
                                      ColorizeAnimatedText(
                                        speed: const Duration(milliseconds: 1000),
                                        state.user.memberNumber,
                                        textStyle: colorizeTextStyle,
                                        colors: colorizeColors,
                                      ),
                                    ],
                                    onTap: () {
                                      print('Tap Event');
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .shimmer(
                                delay: const Duration(milliseconds: 500),
                                duration: const Duration(milliseconds: 1000),
                              )
                              .shimmer(
                                delay: const Duration(milliseconds: 1500),
                                duration: const Duration(milliseconds: 300),
                              )
                              .fadeIn(
                                delay: const Duration(milliseconds: 300),
                                duration: const Duration(milliseconds: 500),
                              ),
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CopyRight 2024 | Digitapps Studio',
                            style: TextStyle(
                              fontFamily: 'Horizon',
                              fontWeight: FontWeight.w100,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
