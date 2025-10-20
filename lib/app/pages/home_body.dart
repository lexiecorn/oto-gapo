import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/widgets/carousel_view_from_pocketbase.dart';
import 'package:otogapo/app/widgets/otogapo_navigation_cards.dart';

@RoutePage(
  name: 'HomeBodyRouter',
)
class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  HomeBodyState createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody> {
  final ScrollController _announcementScrolllController = ScrollController();
  @override
  void initState() {
    super.initState();

    _announcementScrolllController.addListener(() {
      setState(() {});
    });

    // Add debugging for authenticated user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authBloc = context.read<AuthBloc>();
      print('Home Body - AuthBloc status: ${authBloc.state.authStatus}');
      print('Home Body - AuthBloc user UID: ${authBloc.state.user?.id}');
      if (authBloc.state.user != null) {
        print('Home Body - AuthBloc user email: ${authBloc.state.user!.data['email']}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              brightness: Brightness.dark,
            ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {},
          builder: (context, state) {
            // Add debugging
            print('Home Body - Profile Status: ${state.profileStatus}');
            print('Home Body - User Member Number: "${state.user.memberNumber}"');
            print('Home Body - User First Name: "${state.user.firstName}"');
            print('Home Body - User Last Name: "${state.user.lastName}"');
            print('Home Body - User Membership Type: ${state.user.membership_type}');
            print('Home Body - User UID: "${state.user.uid}"');

            // Check if the current authenticated user is different from the profile user
            final currentAuthUser = context.read<AuthBloc>().state.user;
            if (currentAuthUser != null && state.user.uid.isNotEmpty && state.user.uid != currentAuthUser.id) {
              print('Home Body - User mismatch detected!');
              print('Home Body - Auth user UID: ${currentAuthUser.id}');
              print('Home Body - Profile user UID: ${state.user.uid}');
              print('Home Body - Force clearing profile for new user');
              context.read<ProfileCubit>().forceClear();
              Future.delayed(const Duration(milliseconds: 100), () {
                context.read<ProfileCubit>().getProfile();
              });
            }

            if (state.profileStatus == ProfileStatus.initial) {
              return Container();
            } else if (state.profileStatus == ProfileStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state.profileStatus == ProfileStatus.error) {
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/error.png',
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Ooops!\nTry again',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                      ),
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
                      onPressed: () {
                        context.read<ProfileCubit>().getProfile();
                      },
                      child: const Text('Reload Profile'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Carousel occupies a fixed height
                Container(
                  color: Colors.black,
                  height: 290.h,
                  child: const CarouselViewFromPocketbase(),
                ),

                // Vertical spacing between gallery and navigation cards
                SizedBox(height: 16.h),

                // Navigation Cards take the remaining space
                const Expanded(
                  child: SingleChildScrollView(
                    child: OtogapoNavigationCards(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
