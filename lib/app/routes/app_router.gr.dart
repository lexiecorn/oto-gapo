// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i16;
import 'package:flutter/material.dart' as _i17;
import 'package:otogapo/app/modules/profile/profile_page.dart' as _i9;
import 'package:otogapo/app/modules/signin/signin_page.dart' as _i11;
import 'package:otogapo/app/modules/signup/signup_page.dart' as _i12;
import 'package:otogapo/app/pages/create_meeting_page.dart' as _i1;
import 'package:otogapo/app/pages/home_body.dart' as _i2;
import 'package:otogapo/app/pages/home_page.dart' as _i3;
import 'package:otogapo/app/pages/mark_attendance_page.dart' as _i5;
import 'package:otogapo/app/pages/meeting_details_page.dart' as _i6;
import 'package:otogapo/app/pages/meeting_qr_code_page.dart' as _i7;
import 'package:otogapo/app/pages/meetings_list_page.dart' as _i8;
import 'package:otogapo/app/pages/qr_scanner_page.dart' as _i10;
import 'package:otogapo/app/pages/splash_page.dart' as _i13;
import 'package:otogapo/app/pages/user_attendance_history_page.dart' as _i14;
import 'package:otogapo/app/pages/user_qr_code_page.dart' as _i15;
import 'package:otogapo/app/widgets/intro.dart' as _i4;
import 'package:otogapo/models/meeting.dart' as _i18;

abstract class $AppRouter extends _i16.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i16.PageFactory> pagesMap = {
    CreateMeetingPageRouter.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.CreateMeetingPage(),
      );
    },
    HomeBodyRouter.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.HomeBody(),
      );
    },
    HomePageRouter.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.HomePage(),
      );
    },
    IntroPageRouter.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.IntroPage(),
      );
    },
    MarkAttendancePageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<MarkAttendancePageRouterArgs>(
          orElse: () => MarkAttendancePageRouterArgs(
              meetingId: pathParams.getString('meetingId')));
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i5.MarkAttendancePage(
          meetingId: args.meetingId,
          key: args.key,
        ),
      );
    },
    MeetingDetailsPageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<MeetingDetailsPageRouterArgs>(
          orElse: () => MeetingDetailsPageRouterArgs(
              meetingId: pathParams.getString('meetingId')));
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i6.MeetingDetailsPage(
          meetingId: args.meetingId,
          key: args.key,
        ),
      );
    },
    MeetingQRCodePageRouter.name: (routeData) {
      final args = routeData.argsAs<MeetingQRCodePageRouterArgs>();
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.MeetingQRCodePage(
          meeting: args.meeting,
          key: args.key,
        ),
      );
    },
    MeetingsListPageRouter.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.MeetingsListPage(),
      );
    },
    ProfilePageRouter.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.ProfilePage(),
      );
    },
    QRScannerPageRouter.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.QRScannerPage(),
      );
    },
    SigninPageRouter.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i11.SigninPage(),
      );
    },
    SignupPageRouter.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i12.SignupPage(),
      );
    },
    SplashPageRouter.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i13.SplashPage(),
      );
    },
    UserAttendanceHistoryPageRouter.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i14.UserAttendanceHistoryPage(),
      );
    },
    UserQRCodePageRouter.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i15.UserQRCodePage(),
      );
    },
  };
}

/// generated route for
/// [_i1.CreateMeetingPage]
class CreateMeetingPageRouter extends _i16.PageRouteInfo<void> {
  const CreateMeetingPageRouter({List<_i16.PageRouteInfo>? children})
      : super(
          CreateMeetingPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'CreateMeetingPageRouter';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i2.HomeBody]
class HomeBodyRouter extends _i16.PageRouteInfo<void> {
  const HomeBodyRouter({List<_i16.PageRouteInfo>? children})
      : super(
          HomeBodyRouter.name,
          initialChildren: children,
        );

  static const String name = 'HomeBodyRouter';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i3.HomePage]
class HomePageRouter extends _i16.PageRouteInfo<void> {
  const HomePageRouter({List<_i16.PageRouteInfo>? children})
      : super(
          HomePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'HomePageRouter';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i4.IntroPage]
class IntroPageRouter extends _i16.PageRouteInfo<void> {
  const IntroPageRouter({List<_i16.PageRouteInfo>? children})
      : super(
          IntroPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'IntroPageRouter';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i5.MarkAttendancePage]
class MarkAttendancePageRouter
    extends _i16.PageRouteInfo<MarkAttendancePageRouterArgs> {
  MarkAttendancePageRouter({
    required String meetingId,
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          MarkAttendancePageRouter.name,
          args: MarkAttendancePageRouterArgs(
            meetingId: meetingId,
            key: key,
          ),
          rawPathParams: {'meetingId': meetingId},
          initialChildren: children,
        );

  static const String name = 'MarkAttendancePageRouter';

  static const _i16.PageInfo<MarkAttendancePageRouterArgs> page =
      _i16.PageInfo<MarkAttendancePageRouterArgs>(name);
}

class MarkAttendancePageRouterArgs {
  const MarkAttendancePageRouterArgs({
    required this.meetingId,
    this.key,
  });

  final String meetingId;

  final _i17.Key? key;

  @override
  String toString() {
    return 'MarkAttendancePageRouterArgs{meetingId: $meetingId, key: $key}';
  }
}

/// generated route for
/// [_i6.MeetingDetailsPage]
class MeetingDetailsPageRouter
    extends _i16.PageRouteInfo<MeetingDetailsPageRouterArgs> {
  MeetingDetailsPageRouter({
    required String meetingId,
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          MeetingDetailsPageRouter.name,
          args: MeetingDetailsPageRouterArgs(
            meetingId: meetingId,
            key: key,
          ),
          rawPathParams: {'meetingId': meetingId},
          initialChildren: children,
        );

  static const String name = 'MeetingDetailsPageRouter';

  static const _i16.PageInfo<MeetingDetailsPageRouterArgs> page =
      _i16.PageInfo<MeetingDetailsPageRouterArgs>(name);
}

class MeetingDetailsPageRouterArgs {
  const MeetingDetailsPageRouterArgs({
    required this.meetingId,
    this.key,
  });

  final String meetingId;

  final _i17.Key? key;

  @override
  String toString() {
    return 'MeetingDetailsPageRouterArgs{meetingId: $meetingId, key: $key}';
  }
}

/// generated route for
/// [_i7.MeetingQRCodePage]
class MeetingQRCodePageRouter
    extends _i16.PageRouteInfo<MeetingQRCodePageRouterArgs> {
  MeetingQRCodePageRouter({
    required _i18.Meeting meeting,
    _i17.Key? key,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          MeetingQRCodePageRouter.name,
          args: MeetingQRCodePageRouterArgs(
            meeting: meeting,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'MeetingQRCodePageRouter';

  static const _i16.PageInfo<MeetingQRCodePageRouterArgs> page =
      _i16.PageInfo<MeetingQRCodePageRouterArgs>(name);
}

class MeetingQRCodePageRouterArgs {
  const MeetingQRCodePageRouterArgs({
    required this.meeting,
    this.key,
  });

  final _i18.Meeting meeting;

  final _i17.Key? key;

  @override
  String toString() {
    return 'MeetingQRCodePageRouterArgs{meeting: $meeting, key: $key}';
  }
}

/// generated route for
/// [_i8.MeetingsListPage]
class MeetingsListPageRouter extends _i16.PageRouteInfo<void> {
  const MeetingsListPageRouter({List<_i16.PageRouteInfo>? children})
      : super(
          MeetingsListPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'MeetingsListPageRouter';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i9.ProfilePage]
class ProfilePageRouter extends _i16.PageRouteInfo<void> {
  const ProfilePageRouter({List<_i16.PageRouteInfo>? children})
      : super(
          ProfilePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'ProfilePageRouter';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i10.QRScannerPage]
class QRScannerPageRouter extends _i16.PageRouteInfo<void> {
  const QRScannerPageRouter({List<_i16.PageRouteInfo>? children})
      : super(
          QRScannerPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'QRScannerPageRouter';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i11.SigninPage]
class SigninPageRouter extends _i16.PageRouteInfo<void> {
  const SigninPageRouter({List<_i16.PageRouteInfo>? children})
      : super(
          SigninPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SigninPageRouter';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i12.SignupPage]
class SignupPageRouter extends _i16.PageRouteInfo<void> {
  const SignupPageRouter({List<_i16.PageRouteInfo>? children})
      : super(
          SignupPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SignupPageRouter';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i13.SplashPage]
class SplashPageRouter extends _i16.PageRouteInfo<void> {
  const SplashPageRouter({List<_i16.PageRouteInfo>? children})
      : super(
          SplashPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SplashPageRouter';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i14.UserAttendanceHistoryPage]
class UserAttendanceHistoryPageRouter extends _i16.PageRouteInfo<void> {
  const UserAttendanceHistoryPageRouter({List<_i16.PageRouteInfo>? children})
      : super(
          UserAttendanceHistoryPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'UserAttendanceHistoryPageRouter';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i15.UserQRCodePage]
class UserQRCodePageRouter extends _i16.PageRouteInfo<void> {
  const UserQRCodePageRouter({List<_i16.PageRouteInfo>? children})
      : super(
          UserQRCodePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'UserQRCodePageRouter';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}
