import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/profile/profile_page.dart';
import 'package:otogapo/app/pages/home_body.dart';
import 'package:otogapo/app/pages/settings_page.dart';
import 'package:otogapo/app/pages/social_feed_page.dart';

@RoutePage(
  name: 'HomePageRouter',
)
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  // static const String routeName = '/home';

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Changed from 0 to 2 to default to Social Feed
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final List<Widget> _widgetOptions = <Widget>[
    Container(
      width: double.infinity,
      padding: EdgeInsets.zero,
      child: const HomeBody(),
    ),
    const ProfilePage(),
    const SocialFeedPage(),
    const SettingsPage(),
  ];

  final List<String> _pageTitles = [
    'OTOGAPO',
    'Profile',
    'Social Feed',
    'Settings',
  ];

  final List<IconData> _pageIcons = [
    Icons.tire_repair,
    Icons.person_rounded,
    Icons.dynamic_feed_rounded,
    Icons.settings_rounded,
  ];

  final List<String> _pageLabels = [
    'Otogapo',
    'Profile',
    'Feed',
    'Settings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // onWillPop: () async => false,
      canPop: false,
      child: Scaffold(
        // backgroundColor: Colors.grey.shade100,
        // backgroundColor: Colors.grey.shade100
        // ,
        appBar: AppBar(
          title: Text(
            _pageTitles.elementAt(_selectedIndex),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
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
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
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
        FadeEffect(
          delay: Duration(milliseconds: 200),
          duration: Duration(milliseconds: 600),
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                _pageIcons.length,
                _buildNavItem,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _selectedIndex == index;
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
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20.w : 12.w,
            vertical: 10.h,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Colors.amber[700]!,
                      Colors.amber[500]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.amber[300]!.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _pageIcons[index],
                color: isSelected ? Colors.white : Colors.grey[600],
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
        ),
      ),
    );
  }
}
