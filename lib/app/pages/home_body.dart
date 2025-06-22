import 'package:auto_route/auto_route.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/pages/announcements.dart';
import 'package:otogapo/app/widgets/CarouselViewFromFirebase.dart';

@RoutePage(
  name: 'HomeBodyRouter',
)
class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  HomeBodyState createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  late Reference storageRef;
  String userProfile = '';

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
      print('Home Body - AuthBloc state: ${authBloc.state}');
      print('Home Body - AuthBloc user UID: ${authBloc.state.user?.uid}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          if (currentAuthUser != null && state.user.uid.isNotEmpty && state.user.uid != currentAuthUser.uid) {
            print('Home Body - User mismatch detected!');
            print('Home Body - Auth user UID: ${currentAuthUser.uid}');
            print('Home Body - Profile user UID: ${state.user.uid}');
            print('Home Body - Force clearing profile for new user');
            context.read<ProfileCubit>().forceClear();
            Future.delayed(const Duration(milliseconds: 100), () {
              context.read<ProfileCubit>().getProfile(uid: currentAuthUser.uid);
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
                      final uid = context.read<AuthBloc>().state.user!.uid;
                      context.read<ProfileCubit>().getProfile(uid: uid);
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
                height: 220.h,
                child: const CarouselViewFromFirebase(),
              ),

              // Announcements Widget takes the remaining space
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: const AnnouncementsWidget(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Future<Widget> _userProfileCard(ProfileState state) async {
  //   final storaProfilegeref = storage.ref().child('users/${state.user.uid}/images/profile.png');
  //   final downloadUrlProfile = await storaProfilegeref.getDownloadURL();
  //   return IdCard(
  //     imagePath: downloadUrlProfile,
  //     name: '${state.user.firstName} ${state.user.lastName}',
  //     dob: DateFormat('MMM dd, yyyy').format(state.user.dateOfBirth.toDate()),
  //     idNumber: state.user.memberNumber,
  //     membersNum: state.user.memberNumber,
  //     car: state.user.vehicle.first.make,
  //     licenseNum: state.user.driversLicenseNumber ?? '',
  //     licenseNumExpr: state.user.driversLicenseExpirationDate,
  //     restrictionCode: state.user.driversLicenseRestrictionCode,
  //     emergencyContact: state.user.emergencyContactNumber,
  //   )
  //       .animate()
  //       .slideY(
  //         delay: const Duration(milliseconds: 100),
  //         duration: const Duration(milliseconds: 500),
  //       )
  //       .shimmer(
  //         duration: const Duration(milliseconds: 800),
  //       )
  //       .fadeIn(
  //         delay: const Duration(milliseconds: 100),
  //         duration: const Duration(milliseconds: 500),
  //       );
  // }
}
