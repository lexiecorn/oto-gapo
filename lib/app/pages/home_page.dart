import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/connectivity/bloc/connectivity_cubit.dart';
import 'package:otogapo/app/modules/connectivity/bloc/connectivity_state.dart';
import 'package:otogapo/app/modules/profile/profile_page.dart';
import 'package:otogapo/app/pages/home_body.dart';
import 'package:otogapo/app/pages/settings_page.dart';
import 'package:otogapo/app/pages/social_feed_page.dart';
import 'package:otogapo/app/widgets/connectivity_banner.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/widgets/announcement_popup_dialog.dart';
import 'package:otogapo/app/modules/version_check/widgets/version_check_wrapper.dart';
import 'package:otogapo/app/modules/version_check/bloc/version_check_cubit.dart';
import 'package:otogapo/app/modules/version_check/bloc/version_check_state.dart';
import 'package:otogapo/services/version_check_service.dart';
import 'package:otogapo/bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage(name: 'HomePageRouter')
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  // static const String routeName = '/home';

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Changed from 0 to 2 to default to Social Feed
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const String _lastTabKey = 'last_selected_tab';
  bool _hasShownLoginAnnouncements = false;

  @override
  void initState() {
    super.initState();
    _loadLastSelectedTab();
    // Set initial status bar style
    _updateStatusBarStyle();
    // Check and show login announcements
    _checkAndShowLoginAnnouncements();
  }

  Future<void> _checkAndShowLoginAnnouncements() async {
    // Wait a bit for the page to fully load
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted || _hasShownLoginAnnouncements) return;

    try {
      // Fetch login announcements
      final pbService = PocketBaseService();
      final announcements = await pbService.getLoginAnnouncements();

      if (!mounted) return;

      if (announcements.isNotEmpty) {
        debugPrint('HomePage - Showing ${announcements.length} login announcements');

        _hasShownLoginAnnouncements = true;

        // Show the announcements
        await AnnouncementPopupDialog.showLoginAnnouncements(context, announcements, pbService.getAnnouncementImageUrl);
      } else {
        debugPrint('HomePage - No login announcements to show');
      }
    } catch (e) {
      debugPrint('HomePage - Error showing login announcements: $e');
    }
  }

  final List<Widget> _widgetOptions = <Widget>[
    Container(width: double.infinity, padding: EdgeInsets.zero, child: const HomeBody()),
    const ProfilePage(),
    const SocialFeedPage(),
    const SettingsPage(),
  ];

  final List<String> _pageTitles = ['OTOGAPO', 'My Profile', 'Social Feed', 'Settings'];

  final List<IconData> _pageIcons = [
    Icons.tire_repair,
    Icons.person_rounded,
    Icons.dynamic_feed_rounded,
    Icons.settings_rounded,
  ];

  final List<String> _pageLabels = ['Otogapo', 'Profile', 'Feed', 'Settings'];

  Future<void> _loadLastSelectedTab() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTab = prefs.getInt(_lastTabKey);
    if (lastTab != null && lastTab != _selectedIndex) {
      setState(() {
        _selectedIndex = lastTab;
      });
      // Update status bar style after loading saved tab
      _updateStatusBarStyle();
    }
  }

  Future<void> _saveLastSelectedTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastTabKey, index);
  }

  void _onItemTapped(int index) {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _selectedIndex = index;
    });

    // Update status bar style based on selected tab
    _updateStatusBarStyle();

    // Save selected tab
    _saveLastSelectedTab(index);
  }

  void _updateStatusBarStyle() {
    if (_selectedIndex == 2) {
      // Social Feed: Black status bar with white icons
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    } else {
      // Other pages: Default system status bar
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VersionCheckCubit>();
    final service = VersionCheckService(
      sharedPreferences: getIt<SharedPreferences>(),
    );

    return BlocBuilder<VersionCheckCubit, VersionCheckState>(
      builder: (context, versionState) {
        return VersionCheckWrapper(
          cubit: cubit,
          service: service,
          child: PopScope(
            // onWillPop: () async => false,
            canPop: false,
            child: Scaffold(
              // backgroundColor: Colors.grey.shade100,
              // backgroundColor: Colors.grey.shade100
              // ,
              appBar: _selectedIndex == 1 || _selectedIndex == 2
                  ? null // No AppBar for Profile and Social Feed pages
                  : PreferredSize(
                      preferredSize: Size.fromHeight(kToolbarHeight),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Connectivity Banner
                          const ConnectivityBanner(),
                          // AppBar
                          Flexible(
                            child: AppBar(
                              title: _selectedIndex == 0
                                  ? Image.asset('assets/images/logo_sm.jpg', height: 40, fit: BoxFit.contain)
                                  : Text(
                                      _pageTitles.elementAt(_selectedIndex),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                              centerTitle: true,
                              backgroundColor: Colors.black,
                              elevation: 0,
                              actions: _selectedIndex == 3
                                  ? [
                                      IconButton(
                                        icon: const Icon(Icons.refresh, color: Colors.white),
                                        onPressed: () {
                                          // Optionally: trigger a refresh in SettingsPage
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.help_outline, color: Colors.white),
                                        onPressed: () {
                                          // Optionally: show help dialog
                                        },
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                        ],
                      ),
                    ),
              body: _selectedIndex == 1 || _selectedIndex == 2
                  ? Stack(
                      children: [
                        // Page content - starts from top
                        _widgetOptions.elementAt(_selectedIndex),
                        // Connectivity Banner overlays on top
                        Positioned(top: 0, left: 0, right: 0, child: const ConnectivityBanner()),
                      ],
                    )
                  : _widgetOptions.elementAt(_selectedIndex),
              bottomNavigationBar: _buildBottomNavigationBar(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Animate(
      effects: const [
        SlideEffect(
          begin: Offset(0, 1),
          end: Offset.zero,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        ),
        FadeEffect(delay: Duration(milliseconds: 200), duration: Duration(milliseconds: 600)),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
              builder: (context, connectivityState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_pageIcons.length, (index) => _buildNavItem(index, connectivityState)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, ConnectivityState connectivityState) {
    final isSelected = _selectedIndex == index;
    final showBadge = _shouldShowBadge(index, connectivityState);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Animate(
        effects: [
          ScaleEffect(
            delay: Duration(milliseconds: index * 100),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
          ),
        ],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 20.w : 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [Colors.amber[700]!, Colors.amber[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.amber[300]!.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _pageIcons[index],
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    size: isSelected ? 26 : 24,
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 8.w),
                    Text(
                      _pageLabels[index],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ],
              ),
              // Notification Badge
              if (showBadge)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(duration: 1000.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowBadge(int index, ConnectivityState connectivityState) {
    // Show badge on settings if offline or has pending actions
    if (index == 3 && connectivityState.hasPendingActions) {
      return true;
    }
    // Can add more badge logic here (e.g., unread notifications)
    return false;
  }
}
