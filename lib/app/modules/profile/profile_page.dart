import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/modules/profile_progress/bloc/profile_progress_cubit.dart';
import 'package:otogapo/app/pages/car_widget.dart';
import 'package:otogapo/app/pages/current_user_account_page.dart';
import 'package:otogapo/app/pages/id_card.dart';
import 'package:otogapo/app/widgets/profile_completion_card.dart';

@RoutePage(
  name: 'ProfilePageRouter',
)
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  // Removed Firebase Storage - now using PocketBase for file storage
  String userProfile = '';

  final ScrollController _announcementScrolllController = ScrollController();
  late AnimationController _pageAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _announcementScrolllController.addListener(() {
      setState(() {});
    });

    // Simplified animation controller
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Start animation
    _pageAnimationController.forward();

    // Initialize profile data when page loads
    _initializeProfile();
  }

  void _initializeProfile() {
    final currentAuthUser = context.read<AuthBloc>().state.user;
    if (currentAuthUser != null) {
      print('Profile Page - Initializing profile for authenticated user: ${currentAuthUser.id}');
      context.read<ProfileCubit>().getProfile();
    } else {
      print('Profile Page - No authenticated user found');
    }
  }

  void _updateProfileProgress(User user) {
    // Update profile progress whenever user data changes
    context.read<ProfileProgressCubit>().calculateCompletion(user);
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          // Add debugging
          print('Profile Page - Profile Status: ${state.profileStatus}');
          print('Profile Page - User Member Number: "${state.user.memberNumber}"');
          print('Profile Page - User First Name: "${state.user.firstName}"');
          print('Profile Page - User Last Name: "${state.user.lastName}"');
          print('Profile Page - User Membership Type: ${state.user.membership_type}');
          print('Profile Page - User UID: "${state.user.uid}"');

          // Check if the current authenticated user is different from the profile user
          final currentAuthUser = context.read<AuthBloc>().state.user;
          if (currentAuthUser != null && state.user.uid.isNotEmpty && state.user.uid != currentAuthUser.id) {
            print('Profile Page - User mismatch detected!');
            print('Profile Page - Auth user UID: ${currentAuthUser.id}');
            print('Profile Page - Profile user UID: ${state.user.uid}');
            print('Profile Page - Force clearing profile for new user');
            context.read<ProfileCubit>().forceClear();
            // Immediately fetch profile without artificial delay
            context.read<ProfileCubit>().getProfile();
          }

          if (state.profileStatus == ProfileStatus.initial) {
            // Show loading screen while initializing
            return _buildLoadingScreen();
          } else if (state.profileStatus == ProfileStatus.loading) {
            return _buildLoadingScreen();
          } else if (state.profileStatus == ProfileStatus.error) {
            return _buildErrorScreen();
          }

          // Debug display for development
          if (state.user.firstName.isEmpty && state.user.lastName.isEmpty) {
            return _buildEmptyUserScreen(context, state);
          }

          // Update profile progress
          _updateProfileProgress(state.user);

          return RefreshIndicator(
            onRefresh: () async {
              // Add a subtle animation when refreshing
              _pageAnimationController.reset();
              _pageAnimationController.forward();

              // Refresh the profile data
              context.read<ProfileCubit>().getProfile();
            },
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                padding: EdgeInsets.only(
                  top: 20.sp,
                  left: 8,
                  right: 8,
                  bottom: 20,
                ),
                children: [
                  // Profile Completion Card
                  const ProfileCompletionCard(),
                  // Profile Card with enhanced animation
                  FutureBuilder<Widget>(
                    future: _userProfileCard(state),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingCard();
                      } else if (snapshot.hasError) {
                        return _buildErrorCard();
                      } else if (snapshot.hasData) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
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
                  // Car Widget with animation
                  CarWidget(state: state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simple loading icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.8),
                  Colors.purple.withOpacity(0.8),
                ],
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 40,
            ),
          ).animate().fadeIn(duration: 600.ms).scale(duration: 400.ms, curve: Curves.easeOutBack),
          SizedBox(height: 24.sp),
          // Simple loading text
          Text(
            'Loading Profile...',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simple error icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[400],
            ),
          ).animate().fadeIn(duration: 600.ms).scale(duration: 400.ms, curve: Curves.easeOutBack),
          SizedBox(height: 24.sp),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red[400],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          SizedBox(height: 8.sp),
          Text(
            'Please try again later',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildEmptyUserScreen(BuildContext context, ProfileState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Colors.orange[400],
          ).animate().fadeIn(duration: 600.ms).scale(duration: 400.ms, curve: Curves.easeOutBack),
          SizedBox(height: 16.sp),
          Text(
            'User data appears to be empty',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          SizedBox(height: 8.sp),
          Text('UID: ${state.user.uid}').animate().fadeIn(delay: 300.ms, duration: 600.ms),
          Text('Member Number: "${state.user.memberNumber}"').animate().fadeIn(delay: 400.ms, duration: 600.ms),
          Text('Membership Type: ${state.user.membership_type}').animate().fadeIn(delay: 500.ms, duration: 600.ms),
          Text('First Name: "${state.user.firstName}"').animate().fadeIn(delay: 600.ms, duration: 600.ms),
          Text('Last Name: "${state.user.lastName}"').animate().fadeIn(delay: 700.ms, duration: 600.ms),
          SizedBox(height: 16.sp),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileCubit>().getProfile();
            },
            child: const Text('Reload Profile'),
          ).animate().fadeIn(delay: 800.ms, duration: 600.ms).scale(delay: 900.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.sp),
      child: Container(
        height: 120,
        padding: EdgeInsets.all(16.sp),
        child: Row(
          children: [
            // Simple skeleton for profile image
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(40.r),
              ),
            ).animate().fadeIn(duration: 600.ms),
            SizedBox(width: 16.w),
            // Simple skeleton for text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.sp),
      child: Container(
        height: 120,
        padding: EdgeInsets.all(16.sp),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 40,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                'Error loading profile card',
                style: TextStyle(
                  color: Colors.red[400],
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Future<Widget> _userProfileCard(ProfileState state) async {
    String imagePath;

    // Check if user has a profile image URL stored
    if (state.user.profileImage != null && state.user.profileImage!.isNotEmpty) {
      // For PocketBase, profile images are typically file names that need to be converted to URLs
      // Format: https://your-pocketbase-url/api/files/collection_id/record_id/filename
      if (state.user.profileImage!.startsWith('http')) {
        // It's already a full URL
        imagePath = state.user.profileImage!;
      } else {
        // It's a filename, construct the PocketBase file URL
        final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;
        imagePath = '$pocketbaseUrl/api/files/users/${state.user.uid}/${state.user.profileImage}';
      }
    } else {
      // No profileImage field, or it's empty. Use a default placeholder.
      imagePath = 'assets/images/alex.png';
    }

    return IdCard(
      imagePath: imagePath,
      name: '${state.user.firstName} ${state.user.lastName}',
      dob: state.user.birthDate != null ? DateFormat('MMM dd, yyyy').format(state.user.birthDate!) : 'N/A',
      idNumber: state.user.memberNumber,
      membersNum: state.user.memberNumber,
      car: state.vehicles.isNotEmpty ? state.vehicles.first.make : 'No Vehicle',
      licenseNum: state.user.driversLicenseNumber ?? '',
      licenseNumExpr: state.user.driversLicenseExpirationDate,
      restrictionCode: state.user.driversLicenseRestrictionCode,
      emergencyContact: state.user.emergencyContactNumber,
    )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 0),
          duration: const Duration(milliseconds: 250),
        )
        .slideY(
          begin: 0.12,
          delay: const Duration(milliseconds: 50),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
  }
}
