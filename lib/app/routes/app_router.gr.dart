// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i8;
import 'package:otogapo/app/modules/profile/profile_page.dart' as _i4;
import 'package:otogapo/app/modules/signin/signin_page.dart' as _i5;
import 'package:otogapo/app/modules/signup/signup_page.dart' as _i6;
import 'package:otogapo/app/pages/home_body.dart' as _i1;
import 'package:otogapo/app/pages/home_page.dart' as _i2;
import 'package:otogapo/app/pages/splash_page.dart' as _i7;
import 'package:otogapo/app/widgets/intro.dart' as _i3;

abstract class $AppRouter extends _i8.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i8.PageFactory> pagesMap = {
    HomeBodyRouter.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.HomeBody(),
      );
    },
    HomePageRouter.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.HomePage(),
      );
    },
    IntroPageRouter.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.IntroPage(),
      );
    },
    ProfilePageRouter.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.ProfilePage(),
      );
    },
    SigninPageRouter.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.SigninPage(),
      );
    },
    SignupPageRouter.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.SignupPage(),
      );
    },
    SplashPageRouter.name: (routeData) {
      return _i8.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.SplashPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.HomeBody]
class HomeBodyRouter extends _i8.PageRouteInfo<void> {
  const HomeBodyRouter({List<_i8.PageRouteInfo>? children})
      : super(
          HomeBodyRouter.name,
          initialChildren: children,
        );

  static const String name = 'HomeBodyRouter';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}

/// generated route for
/// [_i2.HomePage]
class HomePageRouter extends _i8.PageRouteInfo<void> {
  const HomePageRouter({List<_i8.PageRouteInfo>? children})
      : super(
          HomePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'HomePageRouter';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}

/// generated route for
/// [_i3.IntroPage]
class IntroPageRouter extends _i8.PageRouteInfo<void> {
  const IntroPageRouter({List<_i8.PageRouteInfo>? children})
      : super(
          IntroPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'IntroPageRouter';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}

/// generated route for
/// [_i4.ProfilePage]
class ProfilePageRouter extends _i8.PageRouteInfo<void> {
  const ProfilePageRouter({List<_i8.PageRouteInfo>? children})
      : super(
          ProfilePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'ProfilePageRouter';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}

/// generated route for
/// [_i5.SigninPage]
class SigninPageRouter extends _i8.PageRouteInfo<void> {
  const SigninPageRouter({List<_i8.PageRouteInfo>? children})
      : super(
          SigninPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SigninPageRouter';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}

/// generated route for
/// [_i6.SignupPage]
class SignupPageRouter extends _i8.PageRouteInfo<void> {
  const SignupPageRouter({List<_i8.PageRouteInfo>? children})
      : super(
          SignupPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SignupPageRouter';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}

/// generated route for
/// [_i7.SplashPage]
class SplashPageRouter extends _i8.PageRouteInfo<void> {
  const SplashPageRouter({List<_i8.PageRouteInfo>? children})
      : super(
          SplashPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SplashPageRouter';

  static const _i8.PageInfo<void> page = _i8.PageInfo<void>(name);
}
