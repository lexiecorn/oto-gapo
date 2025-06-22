import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
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
    print('Intro Widget - initState called');
    _getProfile();
  }

  void _getProfile() {
    final uid = context.read<AuthBloc>().state.user!.uid;
    print('Intro Widget - Getting profile for UID: $uid');
    print('Intro Widget - AuthBloc state user: ${context.read<AuthBloc>().state.user}');
    print('Intro Widget - Current ProfileCubit state: ${context.read<ProfileCubit>().state}');

    // Force clear profile state first to prevent cached data issues
    print('Intro Widget - Force clearing profile state');
    context.read<ProfileCubit>().forceClear();

    // Add a small delay to ensure state is cleared
    Future.delayed(const Duration(milliseconds: 100), () {
      print('Intro Widget - Profile state cleared, calling getProfile');
      context.read<ProfileCubit>().getProfile(uid: uid);
      print('Intro Widget - getProfile called');
    });
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

      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          print('Intro Widget - Auth state listener triggered');
          print('Intro Widget - Auth status: ${authState.authStatus}');
          print('Intro Widget - Auth user: ${authState.user}');

          // Reset profile when auth state changes
          if (authState.authStatus == AuthStatus.authenticated && authState.user != null) {
            print('Intro Widget - Auth state changed, force clearing profile');
            context.read<ProfileCubit>().forceClear();

            // Add a small delay to ensure state is cleared
            Future.delayed(const Duration(milliseconds: 100), () {
              _getProfile();
            });
          }
        },
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            print('Intro Widget - Profile state listener triggered');
            print('Intro Widget - Profile status: ${state.profileStatus}');
          },
          builder: (context, state) {
            // Add debugging
            print('Intro Widget - Profile Status: ${state.profileStatus}');
            print('Intro Widget - User Member Number: "${state.user.memberNumber}"');
            print('Intro Widget - User First Name: "${state.user.firstName}"');
            print('Intro Widget - User Last Name: "${state.user.lastName}"');
            print('Intro Widget - User UID: "${state.user.uid}"');
            print('Intro Widget - User Membership Type: ${state.user.membership_type}');

            // Check if the current authenticated user is different from the profile user
            final currentAuthUser = context.read<AuthBloc>().state.user;
            if (currentAuthUser != null && state.user.uid.isNotEmpty && state.user.uid != currentAuthUser.uid) {
              print('Intro Widget - User mismatch detected!');
              print('Intro Widget - Auth user UID: ${currentAuthUser.uid}');
              print('Intro Widget - Profile user UID: ${state.user.uid}');
              print('Intro Widget - Force clearing profile for new user');
              context.read<ProfileCubit>().forceClear();
              Future.delayed(const Duration(milliseconds: 100), () {
                _getProfile();
              });
            }

            // Handle different profile states
            if (state.profileStatus == ProfileStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.profileStatus == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.profileStatus == ProfileStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error loading profile: ${state.error.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _getProfile(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Debug display for development
            if (state.user.firstName.isEmpty && state.user.lastName.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'User data appears to be empty',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('UID: ${state.user.uid}'),
                    Text('Member Number: "${state.user.memberNumber}"'),
                    Text('Membership Type: ${state.user.membership_type}'),
                    Text('First Name: "${state.user.firstName}"'),
                    Text('Last Name: "${state.user.lastName}"'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _getProfile(),
                      child: const Text('Reload Profile'),
                    ),
                  ],
                ),
              );
            }

            // Use a fallback for empty member number
            final displayMemberNumber = state.user.memberNumber.isNotEmpty ? state.user.memberNumber : 'Member';

            return Container(
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
                                    displayMemberNumber,
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
      ),
    );
  }
}
