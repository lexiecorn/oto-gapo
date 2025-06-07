// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:otogapo/app/modules/profile/profile_page.dart' as _i3;
import 'package:otogapo/app/modules/signin/signin_page.dart' as _i4;
import 'package:otogapo/app/modules/signup/signup_page.dart' as _i5;
import 'package:otogapo/app/pages/home_page.dart' as _i1;
import 'package:otogapo/app/pages/splash_page.dart' as _i6;
import 'package:otogapo/app/widgets/intro.dart' as _i2;

abstract class $AppRouter extends _i7.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i7.PageFactory> pagesMap = {
    HomePageRouter.name: (routeData) {
      return _i7.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.HomePage(),
      );
    },
    IntroPageRouter.name: (routeData) {
      return _i7.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.IntroPage(),
      );
    },
    ProfilePageRouter.name: (routeData) {
      return _i7.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.ProfilePage(),
      );
    },
    SigninPageRouter.name: (routeData) {
      return _i7.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.SigninPage(),
      );
    },
    SignupPageRouter.name: (routeData) {
      return _i7.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.SignupPage(),
      );
    },
    SplashPageRouter.name: (routeData) {
      return _i7.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.SplashPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.HomePage]
class HomePageRouter extends _i7.PageRouteInfo<void> {
  const HomePageRouter({List<_i7.PageRouteInfo>? children})
      : super(
          HomePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'HomePageRouter';

  static const _i7.PageInfo<void> page = _i7.PageInfo<void>(name);
}

/// generated route for
/// [_i2.IntroPage]
class IntroPageRouter extends _i7.PageRouteInfo<void> {
  const IntroPageRouter({List<_i7.PageRouteInfo>? children})
      : super(
          IntroPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'IntroPageRouter';

  static const _i7.PageInfo<void> page = _i7.PageInfo<void>(name);
}

/// generated route for
/// [_i3.ProfilePage]
class ProfilePageRouter extends _i7.PageRouteInfo<void> {
  const ProfilePageRouter({List<_i7.PageRouteInfo>? children})
      : super(
          ProfilePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'ProfilePageRouter';

  static const _i7.PageInfo<void> page = _i7.PageInfo<void>(name);
}

/// generated route for
/// [_i4.SigninPage]
class SigninPageRouter extends _i7.PageRouteInfo<void> {
  const SigninPageRouter({List<_i7.PageRouteInfo>? children})
      : super(
          SigninPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SigninPageRouter';

  static const _i7.PageInfo<void> page = _i7.PageInfo<void>(name);
}

/// generated route for
/// [_i5.SignupPage]
class SignupPageRouter extends _i7.PageRouteInfo<void> {
  const SignupPageRouter({List<_i7.PageRouteInfo>? children})
      : super(
          SignupPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SignupPageRouter';

  static const _i7.PageInfo<void> page = _i7.PageInfo<void>(name);
}

/// generated route for
/// [_i6.SplashPage]
class SplashPageRouter extends _i7.PageRouteInfo<void> {
  const SplashPageRouter({List<_i7.PageRouteInfo>? children})
      : super(
          SplashPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SplashPageRouter';

  static const _i7.PageInfo<void> page = _i7.PageInfo<void>(name);
}
