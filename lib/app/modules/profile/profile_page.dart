import 'package:auto_route/auto_route.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/pages/car_widget.dart';
import 'package:otogapo/app/pages/id_card.dart';
import 'package:otogapo/app/pages/current_user_account_page.dart';

@RoutePage(
  name: 'ProfilePageRouter',
)
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
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

          return ListView(
            padding: EdgeInsets.only(
              top: 50.sp,
              left: 8,
              right: 8,
              bottom: 20,
            ),
            children: [
              FutureBuilder<Widget>(
                future: _userProfileCard(state),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Error loading profile');
                  } else if (snapshot.hasData) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CurrentUserAccountPage(),
                          ),
                        );
                      },
                      child: snapshot.data,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              SizedBox(height: 12.sp),
              CarWidget(state: state),
            ],
          );
        },
      ),
    );
  }

  Future<Widget> _userProfileCard(ProfileState state) async {
    String imagePath;

    // Check if user has a profile image URL stored and it's a gs:// link
    if (state.user.profile_image != null && state.user.profile_image!.startsWith('gs://')) {
      try {
        // Get the download URL from the gs:// URI
        final ref = FirebaseStorage.instance.refFromURL(state.user.profile_image!);
        imagePath = await ref.getDownloadURL();
      } catch (e) {
        // If it fails, use a default placeholder image
        imagePath = 'assets/images/alex.png'; // Using a local asset as fallback
      }
    } else if (state.user.profile_image != null && state.user.profile_image!.isNotEmpty) {
      // It might be a pre-fetched HTTPS URL or a local asset path
      imagePath = state.user.profile_image!;
    } else {
      // No profile_image field, or it's empty. Use a default placeholder.
      imagePath = 'assets/images/alex.png';
    }

    return IdCard(
      imagePath: imagePath,
      name: '${state.user.firstName} ${state.user.lastName}',
      dob: DateFormat('MMM dd, yyyy').format(state.user.dateOfBirth.toDate()),
      idNumber: state.user.memberNumber,
      membersNum: state.user.memberNumber,
      car: state.user.vehicle.isNotEmpty ? state.user.vehicle.first.make : 'No Vehicle',
      licenseNum: state.user.driversLicenseNumber ?? '',
      licenseNumExpr: state.user.driversLicenseExpirationDate,
      restrictionCode: state.user.driversLicenseRestrictionCode,
      emergencyContact: state.user.emergencyContactNumber,
    )
        .animate()
        .slideY(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 500),
        )
        .shimmer(
          duration: const Duration(milliseconds: 800),
        )
        .fadeIn(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 500),
        );
  }
}
