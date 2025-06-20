import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
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
    const Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    SettingsPage(),
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
            _selectedIndex == 3 ? 'Settings' : 'Otogapo',
            style: TextStyle(
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
                    icon: Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      // Optionally: trigger a refresh in SettingsPage
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.white),
                    onPressed: () {
                      // Optionally: show help dialog
                    },
                  ),
                ]
              : [],
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Business',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
              backgroundColor: Colors.black,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
