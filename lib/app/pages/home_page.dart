import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/profile/profile_page.dart';
import 'package:otogapo/app/pages/home_body.dart';
import 'package:otogapo/app/pages/settings_page.dart';

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
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final List<Widget> _widgetOptions = <Widget>[
    Container(
      width: double.infinity,
      padding: EdgeInsets.zero,
      child: const HomeBody(),
    ),
    const ProfilePage(),
    const SettingsPage(),
  ];

  final List<String> _pageTitles = [
    'OTOGAPO',
    'Profile',
    'Settings',
  ];

  final List<IconData> _pageIcons = [
    Icons.home_rounded,
    Icons.person_rounded,
    Icons.settings_rounded,
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
            _selectedIndex == 2 ? 'Settings' : _pageTitles.elementAt(_selectedIndex),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          elevation: 0,
          actions: _selectedIndex == 2
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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber[600] : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _pageIcons[index],
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                _pageTitles[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
