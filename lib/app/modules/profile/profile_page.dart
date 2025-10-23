import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/modules/profile_progress/bloc/profile_progress_cubit.dart';
import 'package:otogapo/app/pages/car_widget.dart';
import 'package:otogapo/app/widgets/profile_completion_card_wrapper.dart';

// Vehicle photos carousel widget with auto-scroll and infinite loop
class _VehiclePhotosCarousel extends StatefulWidget {
  const _VehiclePhotosCarousel({required this.state});

  final ProfileState state;

  @override
  State<_VehiclePhotosCarousel> createState() => _VehiclePhotosCarouselState();
}

class _VehiclePhotosCarouselState extends State<_VehiclePhotosCarousel> {
  List<String> _getPhotoUrls() {
    if (widget.state.vehicles.isEmpty) return [];
    final vehicle = widget.state.vehicles.first;
    final photos = vehicle.photos ?? [];
    final pocketbaseUrl = FlavorConfig.instance.variables['pocketbaseUrl'] as String;

    return photos.where((p) => p.isNotEmpty).map((filename) {
      if (filename.startsWith('http')) {
        return filename;
      }
      return '$pocketbaseUrl/api/files/vehicles/${vehicle.id}/$filename';
    }).toList();
  }

  void _showImageLightbox(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            ),
            body: Stack(
              children: [
                // Full-screen tap detector for closing
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.transparent,
                  ),
                ),
                // Image viewer
                Center(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: GestureDetector(
                      onTap: () {}, // Prevent closing when tapping the image
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoUrls = _getPhotoUrls();
    if (photoUrls.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 180.h,
      padding: EdgeInsets.symmetric(
        vertical: 6.sp,
      ), // Removed horizontal padding for full width
      child: CarouselSlider.builder(
        itemCount: photoUrls.length,
        itemBuilder: (context, index, realIndex) {
          return Container(
            width: 200.w,
            padding: EdgeInsets.only(bottom: 16.w),
            margin: EdgeInsets.only(
              right: 2.w,
            ), // Further reduced spacing
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16.r),
              child: InkWell(
                onTap: () => _showImageLightbox(context, photoUrls[index]),
                borderRadius: BorderRadius.circular(16.r),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    photoUrls[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: 180.h,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: false,
          viewportFraction: 0.55, // Increased to show more of each image, making them appear closer
          enableInfiniteScroll: true,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}

// Import the private widget - Fixed container with scrollable content inside
class _CarWidgetSpecsOnlyFixed extends StatelessWidget {
  const _CarWidgetSpecsOnlyFixed({required this.state, required this.onRefresh});

  final ProfileState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? [Colors.black, Colors.grey.shade900] : [Colors.white, Colors.grey.shade100],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.sp),
          child: CarWidget(state: state),
        ),
      ),
    );
  }
}

@RoutePage(name: 'ProfilePageRouter')
class ProfilePage extends StatefulWidget {
  const ProfilePage({this.userId, super.key});

  /// Optional userId to view another user's profile. If null, shows current user's profile
  final String? userId;

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
    _pageAnimationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _pageAnimationController, curve: Curves.easeOut));

    // Start animation
    _pageAnimationController.forward();

    // Initialize profile data when page loads
    _initializeProfile();
  }

  void _initializeProfile() {
    if (widget.userId != null) {
      // Viewing another user's profile
      print('Profile Page - Loading profile for user: ${widget.userId}');
      context.read<ProfileCubit>().getProfileByUserId(widget.userId!);
    } else {
      // Viewing own profile
      final currentAuthUser = context.read<AuthBloc>().state.user;
      if (currentAuthUser != null) {
        print('Profile Page - Initializing profile for authenticated user: ${currentAuthUser.id}');
        context.read<ProfileCubit>().getProfile();
      } else {
        print('Profile Page - No authenticated user found');
      }
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
    // Determine if viewing own profile or another user's profile
    final currentAuthUser = context.read<AuthBloc>().state.user;
    final isViewingOwnProfile =
        widget.userId == null || (currentAuthUser != null && widget.userId == currentAuthUser.id);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: null,
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {},
            builder: (context, state) {
              // Add debugging
              print('Profile Page - Profile Status: ${state.profileStatus}');
              print('Profile Page - User Member Number: "${state.user.memberNumber}"');
              print('Profile Page - User First Name: "${state.user.firstName}"');
              print('Profile Page - User Last Name: "${state.user.lastName}"');
              print('Profile Page - User Membership Type: ${state.user.membership_type}');
              print('Profile Page - User UID: "${state.user.uid}"');

              // Only check for mismatch if viewing own profile
              if (isViewingOwnProfile &&
                  currentAuthUser != null &&
                  state.user.uid.isNotEmpty &&
                  state.user.uid != currentAuthUser.id) {
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

              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Hero image card - FIXED AT TOP (no spacing)
                    CarWidgetImageCard(state: state),
                    // Profile Completion Card (only show for own profile, once a week) - FIXED
                    if (isViewingOwnProfile)
                      Padding(
                        padding: EdgeInsets.only(left: 8, right: 8, bottom: 4.h),
                        child: const ProfileCompletionCardWrapper(),
                      ),
                    SizedBox(height: 12.h),
                    // Vehicle photos carousel - FIXED
                    if (state.vehicles.isNotEmpty) _VehiclePhotosCarousel(state: state),
                    SizedBox(height: 12.h),
                    // Container with scrollable content inside - CONTAINER STAYS FIXED
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: _CarWidgetSpecsOnlyFixed(
                          state: state,
                          onRefresh: () async {
                            // Add a subtle animation when refreshing
                            _pageAnimationController.reset();
                            _pageAnimationController.forward();

                            // Refresh the profile data
                            if (isViewingOwnProfile) {
                              context.read<ProfileCubit>().getProfile();
                            } else {
                              context.read<ProfileCubit>().getProfileByUserId(widget.userId!);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
              gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.8), Colors.purple.withOpacity(0.8)]),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ).animate().fadeIn(duration: 600.ms).scale(duration: 400.ms, curve: Curves.easeOutBack),
          SizedBox(height: 24.sp),
          // Simple loading text
          Text(
            'Loading Profile...',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500, color: Colors.grey[600]),
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
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
            child: Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
          ).animate().fadeIn(duration: 600.ms).scale(duration: 400.ms, curve: Curves.easeOutBack),
          SizedBox(height: 24.sp),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.red[400]),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          SizedBox(height: 8.sp),
          Text(
            'Please try again later',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
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

  // Removed unused methods: _buildLoadingCard, _buildErrorCard, _userProfileCard
  // User details are now displayed in CarWidget
}
