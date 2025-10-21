// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:authentication_repository/authentication_repository.dart'
    as _i29;
import 'package:auto_route/auto_route.dart' as _i28;
import 'package:flutter/material.dart' as _i30;
import 'package:otogapo/app/modules/profile/profile_page.dart' as _i16;
import 'package:otogapo/app/modules/signin/signin_page.dart' as _i18;
import 'package:otogapo/app/modules/signup/signup_page.dart' as _i19;
import 'package:otogapo/app/pages/add_vehicle_award_page.dart' as _i1;
import 'package:otogapo/app/pages/announcements_list_page.dart' as _i2;
import 'package:otogapo/app/pages/attendance_calendar_page.dart' as _i3;
import 'package:otogapo/app/pages/car_details_page.dart' as _i4;
import 'package:otogapo/app/pages/create_meeting_page.dart' as _i5;
import 'package:otogapo/app/pages/create_post_page.dart' as _i6;
import 'package:otogapo/app/pages/hashtag_posts_page.dart' as _i7;
import 'package:otogapo/app/pages/home_body.dart' as _i8;
import 'package:otogapo/app/pages/home_page.dart' as _i9;
import 'package:otogapo/app/pages/mark_attendance_page.dart' as _i11;
import 'package:otogapo/app/pages/meeting_details_page.dart' as _i12;
import 'package:otogapo/app/pages/meeting_qr_code_page.dart' as _i13;
import 'package:otogapo/app/pages/meetings_list_page.dart' as _i14;
import 'package:otogapo/app/pages/post_detail_page.dart' as _i15;
import 'package:otogapo/app/pages/qr_scanner_page.dart' as _i17;
import 'package:otogapo/app/pages/social_feed_moderation_page.dart' as _i20;
import 'package:otogapo/app/pages/social_feed_page.dart' as _i21;
import 'package:otogapo/app/pages/splash_page.dart' as _i22;
import 'package:otogapo/app/pages/user_attendance_history_page.dart' as _i23;
import 'package:otogapo/app/pages/user_list_page.dart' as _i24;
import 'package:otogapo/app/pages/user_posts_page.dart' as _i25;
import 'package:otogapo/app/pages/user_qr_code_page.dart' as _i26;
import 'package:otogapo/app/pages/vehicle_awards_page.dart' as _i27;
import 'package:otogapo/app/widgets/intro.dart' as _i10;
import 'package:otogapo/models/meeting.dart' as _i31;

abstract class $AppRouter extends _i28.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i28.PageFactory> pagesMap = {
    AddVehicleAwardPageRouter.name: (routeData) {
      final args = routeData.argsAs<AddVehicleAwardPageRouterArgs>();
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i1.AddVehicleAwardPage(
          vehicle: args.vehicle,
          award: args.award,
          key: args.key,
        ),
      );
    },
    AnnouncementsListPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.AnnouncementsListPage(),
      );
    },
    AttendanceCalendarPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.AttendanceCalendarPage(),
      );
    },
    CarDetailsPageRouter.name: (routeData) {
      final args = routeData.argsAs<CarDetailsPageRouterArgs>();
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.CarDetailsPage(
          vehicle: args.vehicle,
          key: args.key,
        ),
      );
    },
    CreateMeetingPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.CreateMeetingPage(),
      );
    },
    CreatePostPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.CreatePostPage(),
      );
    },
    HashtagPostsPageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<HashtagPostsPageRouterArgs>(
          orElse: () => HashtagPostsPageRouterArgs(
              hashtag: pathParams.getString('hashtag')));
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.HashtagPostsPage(
          hashtag: args.hashtag,
          key: args.key,
        ),
      );
    },
    HomeBodyRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.HomeBody(),
      );
    },
    HomePageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.HomePage(),
      );
    },
    IntroPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.IntroPage(),
      );
    },
    MarkAttendancePageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<MarkAttendancePageRouterArgs>(
          orElse: () => MarkAttendancePageRouterArgs(
              meetingId: pathParams.getString('meetingId')));
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i11.MarkAttendancePage(
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
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i12.MeetingDetailsPage(
          meetingId: args.meetingId,
          key: args.key,
        ),
      );
    },
    MeetingQRCodePageRouter.name: (routeData) {
      final args = routeData.argsAs<MeetingQRCodePageRouterArgs>();
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i13.MeetingQRCodePage(
          meeting: args.meeting,
          key: args.key,
        ),
      );
    },
    MeetingsListPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i14.MeetingsListPage(),
      );
    },
    PostDetailPageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<PostDetailPageRouterArgs>(
          orElse: () =>
              PostDetailPageRouterArgs(postId: pathParams.getString('postId')));
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i15.PostDetailPage(
          postId: args.postId,
          key: args.key,
        ),
      );
    },
    ProfilePageRouter.name: (routeData) {
      final args = routeData.argsAs<ProfilePageRouterArgs>(
          orElse: () => const ProfilePageRouterArgs());
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i16.ProfilePage(
          userId: args.userId,
          key: args.key,
        ),
      );
    },
    QRScannerPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i17.QRScannerPage(),
      );
    },
    SigninPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i18.SigninPage(),
      );
    },
    SignupPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i19.SignupPage(),
      );
    },
    SocialFeedModerationPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i20.SocialFeedModerationPage(),
      );
    },
    SocialFeedPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i21.SocialFeedPage(),
      );
    },
    SplashPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i22.SplashPage(),
      );
    },
    UserAttendanceHistoryPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i23.UserAttendanceHistoryPage(),
      );
    },
    UserListPageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i24.UserListPage(),
      );
    },
    UserPostsPageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<UserPostsPageRouterArgs>(
          orElse: () =>
              UserPostsPageRouterArgs(userId: pathParams.getString('userId')));
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i25.UserPostsPage(
          userId: args.userId,
          key: args.key,
        ),
      );
    },
    UserQRCodePageRouter.name: (routeData) {
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i26.UserQRCodePage(),
      );
    },
    VehicleAwardsPageRouter.name: (routeData) {
      final args = routeData.argsAs<VehicleAwardsPageRouterArgs>();
      return _i28.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i27.VehicleAwardsPage(
          vehicle: args.vehicle,
          key: args.key,
        ),
      );
    },
  };
}

/// generated route for
/// [_i1.AddVehicleAwardPage]
class AddVehicleAwardPageRouter
    extends _i28.PageRouteInfo<AddVehicleAwardPageRouterArgs> {
  AddVehicleAwardPageRouter({
    required _i29.Vehicle vehicle,
    _i29.VehicleAward? award,
    _i30.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
          AddVehicleAwardPageRouter.name,
          args: AddVehicleAwardPageRouterArgs(
            vehicle: vehicle,
            award: award,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'AddVehicleAwardPageRouter';

  static const _i28.PageInfo<AddVehicleAwardPageRouterArgs> page =
      _i28.PageInfo<AddVehicleAwardPageRouterArgs>(name);
}

class AddVehicleAwardPageRouterArgs {
  const AddVehicleAwardPageRouterArgs({
    required this.vehicle,
    this.award,
    this.key,
  });

  final _i29.Vehicle vehicle;

  final _i29.VehicleAward? award;

  final _i30.Key? key;

  @override
  String toString() {
    return 'AddVehicleAwardPageRouterArgs{vehicle: $vehicle, award: $award, key: $key}';
  }
}

/// generated route for
/// [_i2.AnnouncementsListPage]
class AnnouncementsListPageRouter extends _i28.PageRouteInfo<void> {
  const AnnouncementsListPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          AnnouncementsListPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'AnnouncementsListPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i3.AttendanceCalendarPage]
class AttendanceCalendarPageRouter extends _i28.PageRouteInfo<void> {
  const AttendanceCalendarPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          AttendanceCalendarPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'AttendanceCalendarPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i4.CarDetailsPage]
class CarDetailsPageRouter
    extends _i28.PageRouteInfo<CarDetailsPageRouterArgs> {
  CarDetailsPageRouter({
    required _i29.Vehicle vehicle,
    _i30.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
          CarDetailsPageRouter.name,
          args: CarDetailsPageRouterArgs(
            vehicle: vehicle,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'CarDetailsPageRouter';

  static const _i28.PageInfo<CarDetailsPageRouterArgs> page =
      _i28.PageInfo<CarDetailsPageRouterArgs>(name);
}

class CarDetailsPageRouterArgs {
  const CarDetailsPageRouterArgs({
    required this.vehicle,
    this.key,
  });

  final _i29.Vehicle vehicle;

  final _i30.Key? key;

  @override
  String toString() {
    return 'CarDetailsPageRouterArgs{vehicle: $vehicle, key: $key}';
  }
}

/// generated route for
/// [_i5.CreateMeetingPage]
class CreateMeetingPageRouter extends _i28.PageRouteInfo<void> {
  const CreateMeetingPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          CreateMeetingPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'CreateMeetingPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i6.CreatePostPage]
class CreatePostPageRouter extends _i28.PageRouteInfo<void> {
  const CreatePostPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          CreatePostPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'CreatePostPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i7.HashtagPostsPage]
class HashtagPostsPageRouter
    extends _i28.PageRouteInfo<HashtagPostsPageRouterArgs> {
  HashtagPostsPageRouter({
    required String hashtag,
    _i30.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
          HashtagPostsPageRouter.name,
          args: HashtagPostsPageRouterArgs(
            hashtag: hashtag,
            key: key,
          ),
          rawPathParams: {'hashtag': hashtag},
          initialChildren: children,
        );

  static const String name = 'HashtagPostsPageRouter';

  static const _i28.PageInfo<HashtagPostsPageRouterArgs> page =
      _i28.PageInfo<HashtagPostsPageRouterArgs>(name);
}

class HashtagPostsPageRouterArgs {
  const HashtagPostsPageRouterArgs({
    required this.hashtag,
    this.key,
  });

  final String hashtag;

  final _i30.Key? key;

  @override
  String toString() {
    return 'HashtagPostsPageRouterArgs{hashtag: $hashtag, key: $key}';
  }
}

/// generated route for
/// [_i8.HomeBody]
class HomeBodyRouter extends _i28.PageRouteInfo<void> {
  const HomeBodyRouter({List<_i28.PageRouteInfo>? children})
      : super(
          HomeBodyRouter.name,
          initialChildren: children,
        );

  static const String name = 'HomeBodyRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i9.HomePage]
class HomePageRouter extends _i28.PageRouteInfo<void> {
  const HomePageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          HomePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'HomePageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i10.IntroPage]
class IntroPageRouter extends _i28.PageRouteInfo<void> {
  const IntroPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          IntroPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'IntroPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i11.MarkAttendancePage]
class MarkAttendancePageRouter
    extends _i28.PageRouteInfo<MarkAttendancePageRouterArgs> {
  MarkAttendancePageRouter({
    required String meetingId,
    _i30.Key? key,
    List<_i28.PageRouteInfo>? children,
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

  static const _i28.PageInfo<MarkAttendancePageRouterArgs> page =
      _i28.PageInfo<MarkAttendancePageRouterArgs>(name);
}

class MarkAttendancePageRouterArgs {
  const MarkAttendancePageRouterArgs({
    required this.meetingId,
    this.key,
  });

  final String meetingId;

  final _i30.Key? key;

  @override
  String toString() {
    return 'MarkAttendancePageRouterArgs{meetingId: $meetingId, key: $key}';
  }
}

/// generated route for
/// [_i12.MeetingDetailsPage]
class MeetingDetailsPageRouter
    extends _i28.PageRouteInfo<MeetingDetailsPageRouterArgs> {
  MeetingDetailsPageRouter({
    required String meetingId,
    _i30.Key? key,
    List<_i28.PageRouteInfo>? children,
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

  static const _i28.PageInfo<MeetingDetailsPageRouterArgs> page =
      _i28.PageInfo<MeetingDetailsPageRouterArgs>(name);
}

class MeetingDetailsPageRouterArgs {
  const MeetingDetailsPageRouterArgs({
    required this.meetingId,
    this.key,
  });

  final String meetingId;

  final _i30.Key? key;

  @override
  String toString() {
    return 'MeetingDetailsPageRouterArgs{meetingId: $meetingId, key: $key}';
  }
}

/// generated route for
/// [_i13.MeetingQRCodePage]
class MeetingQRCodePageRouter
    extends _i28.PageRouteInfo<MeetingQRCodePageRouterArgs> {
  MeetingQRCodePageRouter({
    required _i31.Meeting meeting,
    _i30.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
          MeetingQRCodePageRouter.name,
          args: MeetingQRCodePageRouterArgs(
            meeting: meeting,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'MeetingQRCodePageRouter';

  static const _i28.PageInfo<MeetingQRCodePageRouterArgs> page =
      _i28.PageInfo<MeetingQRCodePageRouterArgs>(name);
}

class MeetingQRCodePageRouterArgs {
  const MeetingQRCodePageRouterArgs({
    required this.meeting,
    this.key,
  });

  final _i31.Meeting meeting;

  final _i30.Key? key;

  @override
  String toString() {
    return 'MeetingQRCodePageRouterArgs{meeting: $meeting, key: $key}';
  }
}

/// generated route for
/// [_i14.MeetingsListPage]
class MeetingsListPageRouter extends _i28.PageRouteInfo<void> {
  const MeetingsListPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          MeetingsListPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'MeetingsListPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i15.PostDetailPage]
class PostDetailPageRouter
    extends _i28.PageRouteInfo<PostDetailPageRouterArgs> {
  PostDetailPageRouter({
    required String postId,
    _i30.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
          PostDetailPageRouter.name,
          args: PostDetailPageRouterArgs(
            postId: postId,
            key: key,
          ),
          rawPathParams: {'postId': postId},
          initialChildren: children,
        );

  static const String name = 'PostDetailPageRouter';

  static const _i28.PageInfo<PostDetailPageRouterArgs> page =
      _i28.PageInfo<PostDetailPageRouterArgs>(name);
}

class PostDetailPageRouterArgs {
  const PostDetailPageRouterArgs({
    required this.postId,
    this.key,
  });

  final String postId;

  final _i30.Key? key;

  @override
  String toString() {
    return 'PostDetailPageRouterArgs{postId: $postId, key: $key}';
  }
}

/// generated route for
/// [_i16.ProfilePage]
class ProfilePageRouter extends _i28.PageRouteInfo<ProfilePageRouterArgs> {
  ProfilePageRouter({
    String? userId,
    _i30.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
          ProfilePageRouter.name,
          args: ProfilePageRouterArgs(
            userId: userId,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'ProfilePageRouter';

  static const _i28.PageInfo<ProfilePageRouterArgs> page =
      _i28.PageInfo<ProfilePageRouterArgs>(name);
}

class ProfilePageRouterArgs {
  const ProfilePageRouterArgs({
    this.userId,
    this.key,
  });

  final String? userId;

  final _i30.Key? key;

  @override
  String toString() {
    return 'ProfilePageRouterArgs{userId: $userId, key: $key}';
  }
}

/// generated route for
/// [_i17.QRScannerPage]
class QRScannerPageRouter extends _i28.PageRouteInfo<void> {
  const QRScannerPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          QRScannerPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'QRScannerPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i18.SigninPage]
class SigninPageRouter extends _i28.PageRouteInfo<void> {
  const SigninPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          SigninPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SigninPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i19.SignupPage]
class SignupPageRouter extends _i28.PageRouteInfo<void> {
  const SignupPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          SignupPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SignupPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i20.SocialFeedModerationPage]
class SocialFeedModerationPageRouter extends _i28.PageRouteInfo<void> {
  const SocialFeedModerationPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          SocialFeedModerationPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SocialFeedModerationPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i21.SocialFeedPage]
class SocialFeedPageRouter extends _i28.PageRouteInfo<void> {
  const SocialFeedPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          SocialFeedPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SocialFeedPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i22.SplashPage]
class SplashPageRouter extends _i28.PageRouteInfo<void> {
  const SplashPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          SplashPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SplashPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i23.UserAttendanceHistoryPage]
class UserAttendanceHistoryPageRouter extends _i28.PageRouteInfo<void> {
  const UserAttendanceHistoryPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          UserAttendanceHistoryPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'UserAttendanceHistoryPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i24.UserListPage]
class UserListPageRouter extends _i28.PageRouteInfo<void> {
  const UserListPageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          UserListPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'UserListPageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i25.UserPostsPage]
class UserPostsPageRouter extends _i28.PageRouteInfo<UserPostsPageRouterArgs> {
  UserPostsPageRouter({
    required String userId,
    _i30.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
          UserPostsPageRouter.name,
          args: UserPostsPageRouterArgs(
            userId: userId,
            key: key,
          ),
          rawPathParams: {'userId': userId},
          initialChildren: children,
        );

  static const String name = 'UserPostsPageRouter';

  static const _i28.PageInfo<UserPostsPageRouterArgs> page =
      _i28.PageInfo<UserPostsPageRouterArgs>(name);
}

class UserPostsPageRouterArgs {
  const UserPostsPageRouterArgs({
    required this.userId,
    this.key,
  });

  final String userId;

  final _i30.Key? key;

  @override
  String toString() {
    return 'UserPostsPageRouterArgs{userId: $userId, key: $key}';
  }
}

/// generated route for
/// [_i26.UserQRCodePage]
class UserQRCodePageRouter extends _i28.PageRouteInfo<void> {
  const UserQRCodePageRouter({List<_i28.PageRouteInfo>? children})
      : super(
          UserQRCodePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'UserQRCodePageRouter';

  static const _i28.PageInfo<void> page = _i28.PageInfo<void>(name);
}

/// generated route for
/// [_i27.VehicleAwardsPage]
class VehicleAwardsPageRouter
    extends _i28.PageRouteInfo<VehicleAwardsPageRouterArgs> {
  VehicleAwardsPageRouter({
    required _i29.Vehicle vehicle,
    _i30.Key? key,
    List<_i28.PageRouteInfo>? children,
  }) : super(
          VehicleAwardsPageRouter.name,
          args: VehicleAwardsPageRouterArgs(
            vehicle: vehicle,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'VehicleAwardsPageRouter';

  static const _i28.PageInfo<VehicleAwardsPageRouterArgs> page =
      _i28.PageInfo<VehicleAwardsPageRouterArgs>(name);
}

class VehicleAwardsPageRouterArgs {
  const VehicleAwardsPageRouterArgs({
    required this.vehicle,
    this.key,
  });

  final _i29.Vehicle vehicle;

  final _i30.Key? key;

  @override
  String toString() {
    return 'VehicleAwardsPageRouterArgs{vehicle: $vehicle, key: $key}';
  }
}
