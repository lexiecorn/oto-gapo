// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i25;
import 'package:flutter/material.dart' as _i26;
import 'package:otogapo/app/modules/profile/profile_page.dart' as _i14;
import 'package:otogapo/app/modules/signin/signin_page.dart' as _i16;
import 'package:otogapo/app/modules/signup/signup_page.dart' as _i17;
import 'package:otogapo/app/pages/announcements_list_page.dart' as _i1;
import 'package:otogapo/app/pages/attendance_calendar_page.dart' as _i2;
import 'package:otogapo/app/pages/create_meeting_page.dart' as _i3;
import 'package:otogapo/app/pages/create_post_page.dart' as _i4;
import 'package:otogapo/app/pages/hashtag_posts_page.dart' as _i5;
import 'package:otogapo/app/pages/home_body.dart' as _i6;
import 'package:otogapo/app/pages/home_page.dart' as _i7;
import 'package:otogapo/app/pages/mark_attendance_page.dart' as _i9;
import 'package:otogapo/app/pages/meeting_details_page.dart' as _i10;
import 'package:otogapo/app/pages/meeting_qr_code_page.dart' as _i11;
import 'package:otogapo/app/pages/meetings_list_page.dart' as _i12;
import 'package:otogapo/app/pages/post_detail_page.dart' as _i13;
import 'package:otogapo/app/pages/qr_scanner_page.dart' as _i15;
import 'package:otogapo/app/pages/social_feed_moderation_page.dart' as _i18;
import 'package:otogapo/app/pages/social_feed_page.dart' as _i19;
import 'package:otogapo/app/pages/splash_page.dart' as _i20;
import 'package:otogapo/app/pages/user_attendance_history_page.dart' as _i21;
import 'package:otogapo/app/pages/user_list_page.dart' as _i22;
import 'package:otogapo/app/pages/user_posts_page.dart' as _i23;
import 'package:otogapo/app/pages/user_qr_code_page.dart' as _i24;
import 'package:otogapo/app/widgets/intro.dart' as _i8;
import 'package:otogapo/models/meeting.dart' as _i27;

abstract class $AppRouter extends _i25.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i25.PageFactory> pagesMap = {
    AnnouncementsListPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AnnouncementsListPage(),
      );
    },
    AttendanceCalendarPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.AttendanceCalendarPage(),
      );
    },
    CreateMeetingPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.CreateMeetingPage(),
      );
    },
    CreatePostPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.CreatePostPage(),
      );
    },
    HashtagPostsPageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<HashtagPostsPageRouterArgs>(
          orElse: () => HashtagPostsPageRouterArgs(
              hashtag: pathParams.getString('hashtag')));
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i5.HashtagPostsPage(
          hashtag: args.hashtag,
          key: args.key,
        ),
      );
    },
    HomeBodyRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.HomeBody(),
      );
    },
    HomePageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.HomePage(),
      );
    },
    IntroPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.IntroPage(),
      );
    },
    MarkAttendancePageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<MarkAttendancePageRouterArgs>(
          orElse: () => MarkAttendancePageRouterArgs(
              meetingId: pathParams.getString('meetingId')));
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i9.MarkAttendancePage(
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
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i10.MeetingDetailsPage(
          meetingId: args.meetingId,
          key: args.key,
        ),
      );
    },
    MeetingQRCodePageRouter.name: (routeData) {
      final args = routeData.argsAs<MeetingQRCodePageRouterArgs>();
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i11.MeetingQRCodePage(
          meeting: args.meeting,
          key: args.key,
        ),
      );
    },
    MeetingsListPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i12.MeetingsListPage(),
      );
    },
    PostDetailPageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<PostDetailPageRouterArgs>(
          orElse: () =>
              PostDetailPageRouterArgs(postId: pathParams.getString('postId')));
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i13.PostDetailPage(
          postId: args.postId,
          key: args.key,
        ),
      );
    },
    ProfilePageRouter.name: (routeData) {
      final args = routeData.argsAs<ProfilePageRouterArgs>(
          orElse: () => const ProfilePageRouterArgs());
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i14.ProfilePage(
          userId: args.userId,
          key: args.key,
        ),
      );
    },
    QRScannerPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i15.QRScannerPage(),
      );
    },
    SigninPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i16.SigninPage(),
      );
    },
    SignupPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i17.SignupPage(),
      );
    },
    SocialFeedModerationPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i18.SocialFeedModerationPage(),
      );
    },
    SocialFeedPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i19.SocialFeedPage(),
      );
    },
    SplashPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i20.SplashPage(),
      );
    },
    UserAttendanceHistoryPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i21.UserAttendanceHistoryPage(),
      );
    },
    UserListPageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i22.UserListPage(),
      );
    },
    UserPostsPageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<UserPostsPageRouterArgs>(
          orElse: () =>
              UserPostsPageRouterArgs(userId: pathParams.getString('userId')));
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i23.UserPostsPage(
          userId: args.userId,
          key: args.key,
        ),
      );
    },
    UserQRCodePageRouter.name: (routeData) {
      return _i25.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i24.UserQRCodePage(),
      );
    },
  };
}

/// generated route for
/// [_i1.AnnouncementsListPage]
class AnnouncementsListPageRouter extends _i25.PageRouteInfo<void> {
  const AnnouncementsListPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          AnnouncementsListPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'AnnouncementsListPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i2.AttendanceCalendarPage]
class AttendanceCalendarPageRouter extends _i25.PageRouteInfo<void> {
  const AttendanceCalendarPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          AttendanceCalendarPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'AttendanceCalendarPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i3.CreateMeetingPage]
class CreateMeetingPageRouter extends _i25.PageRouteInfo<void> {
  const CreateMeetingPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          CreateMeetingPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'CreateMeetingPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i4.CreatePostPage]
class CreatePostPageRouter extends _i25.PageRouteInfo<void> {
  const CreatePostPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          CreatePostPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'CreatePostPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i5.HashtagPostsPage]
class HashtagPostsPageRouter
    extends _i25.PageRouteInfo<HashtagPostsPageRouterArgs> {
  HashtagPostsPageRouter({
    required String hashtag,
    _i26.Key? key,
    List<_i25.PageRouteInfo>? children,
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

  static const _i25.PageInfo<HashtagPostsPageRouterArgs> page =
      _i25.PageInfo<HashtagPostsPageRouterArgs>(name);
}

class HashtagPostsPageRouterArgs {
  const HashtagPostsPageRouterArgs({
    required this.hashtag,
    this.key,
  });

  final String hashtag;

  final _i26.Key? key;

  @override
  String toString() {
    return 'HashtagPostsPageRouterArgs{hashtag: $hashtag, key: $key}';
  }
}

/// generated route for
/// [_i6.HomeBody]
class HomeBodyRouter extends _i25.PageRouteInfo<void> {
  const HomeBodyRouter({List<_i25.PageRouteInfo>? children})
      : super(
          HomeBodyRouter.name,
          initialChildren: children,
        );

  static const String name = 'HomeBodyRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i7.HomePage]
class HomePageRouter extends _i25.PageRouteInfo<void> {
  const HomePageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          HomePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'HomePageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i8.IntroPage]
class IntroPageRouter extends _i25.PageRouteInfo<void> {
  const IntroPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          IntroPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'IntroPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i9.MarkAttendancePage]
class MarkAttendancePageRouter
    extends _i25.PageRouteInfo<MarkAttendancePageRouterArgs> {
  MarkAttendancePageRouter({
    required String meetingId,
    _i26.Key? key,
    List<_i25.PageRouteInfo>? children,
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

  static const _i25.PageInfo<MarkAttendancePageRouterArgs> page =
      _i25.PageInfo<MarkAttendancePageRouterArgs>(name);
}

class MarkAttendancePageRouterArgs {
  const MarkAttendancePageRouterArgs({
    required this.meetingId,
    this.key,
  });

  final String meetingId;

  final _i26.Key? key;

  @override
  String toString() {
    return 'MarkAttendancePageRouterArgs{meetingId: $meetingId, key: $key}';
  }
}

/// generated route for
/// [_i10.MeetingDetailsPage]
class MeetingDetailsPageRouter
    extends _i25.PageRouteInfo<MeetingDetailsPageRouterArgs> {
  MeetingDetailsPageRouter({
    required String meetingId,
    _i26.Key? key,
    List<_i25.PageRouteInfo>? children,
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

  static const _i25.PageInfo<MeetingDetailsPageRouterArgs> page =
      _i25.PageInfo<MeetingDetailsPageRouterArgs>(name);
}

class MeetingDetailsPageRouterArgs {
  const MeetingDetailsPageRouterArgs({
    required this.meetingId,
    this.key,
  });

  final String meetingId;

  final _i26.Key? key;

  @override
  String toString() {
    return 'MeetingDetailsPageRouterArgs{meetingId: $meetingId, key: $key}';
  }
}

/// generated route for
/// [_i11.MeetingQRCodePage]
class MeetingQRCodePageRouter
    extends _i25.PageRouteInfo<MeetingQRCodePageRouterArgs> {
  MeetingQRCodePageRouter({
    required _i27.Meeting meeting,
    _i26.Key? key,
    List<_i25.PageRouteInfo>? children,
  }) : super(
          MeetingQRCodePageRouter.name,
          args: MeetingQRCodePageRouterArgs(
            meeting: meeting,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'MeetingQRCodePageRouter';

  static const _i25.PageInfo<MeetingQRCodePageRouterArgs> page =
      _i25.PageInfo<MeetingQRCodePageRouterArgs>(name);
}

class MeetingQRCodePageRouterArgs {
  const MeetingQRCodePageRouterArgs({
    required this.meeting,
    this.key,
  });

  final _i27.Meeting meeting;

  final _i26.Key? key;

  @override
  String toString() {
    return 'MeetingQRCodePageRouterArgs{meeting: $meeting, key: $key}';
  }
}

/// generated route for
/// [_i12.MeetingsListPage]
class MeetingsListPageRouter extends _i25.PageRouteInfo<void> {
  const MeetingsListPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          MeetingsListPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'MeetingsListPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i13.PostDetailPage]
class PostDetailPageRouter
    extends _i25.PageRouteInfo<PostDetailPageRouterArgs> {
  PostDetailPageRouter({
    required String postId,
    _i26.Key? key,
    List<_i25.PageRouteInfo>? children,
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

  static const _i25.PageInfo<PostDetailPageRouterArgs> page =
      _i25.PageInfo<PostDetailPageRouterArgs>(name);
}

class PostDetailPageRouterArgs {
  const PostDetailPageRouterArgs({
    required this.postId,
    this.key,
  });

  final String postId;

  final _i26.Key? key;

  @override
  String toString() {
    return 'PostDetailPageRouterArgs{postId: $postId, key: $key}';
  }
}

/// generated route for
/// [_i14.ProfilePage]
class ProfilePageRouter extends _i25.PageRouteInfo<ProfilePageRouterArgs> {
  ProfilePageRouter({
    String? userId,
    _i26.Key? key,
    List<_i25.PageRouteInfo>? children,
  }) : super(
          ProfilePageRouter.name,
          args: ProfilePageRouterArgs(
            userId: userId,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'ProfilePageRouter';

  static const _i25.PageInfo<ProfilePageRouterArgs> page =
      _i25.PageInfo<ProfilePageRouterArgs>(name);
}

class ProfilePageRouterArgs {
  const ProfilePageRouterArgs({
    this.userId,
    this.key,
  });

  final String? userId;

  final _i26.Key? key;

  @override
  String toString() {
    return 'ProfilePageRouterArgs{userId: $userId, key: $key}';
  }
}

/// generated route for
/// [_i15.QRScannerPage]
class QRScannerPageRouter extends _i25.PageRouteInfo<void> {
  const QRScannerPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          QRScannerPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'QRScannerPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i16.SigninPage]
class SigninPageRouter extends _i25.PageRouteInfo<void> {
  const SigninPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          SigninPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SigninPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i17.SignupPage]
class SignupPageRouter extends _i25.PageRouteInfo<void> {
  const SignupPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          SignupPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SignupPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i18.SocialFeedModerationPage]
class SocialFeedModerationPageRouter extends _i25.PageRouteInfo<void> {
  const SocialFeedModerationPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          SocialFeedModerationPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SocialFeedModerationPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i19.SocialFeedPage]
class SocialFeedPageRouter extends _i25.PageRouteInfo<void> {
  const SocialFeedPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          SocialFeedPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SocialFeedPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i20.SplashPage]
class SplashPageRouter extends _i25.PageRouteInfo<void> {
  const SplashPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          SplashPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SplashPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i21.UserAttendanceHistoryPage]
class UserAttendanceHistoryPageRouter extends _i25.PageRouteInfo<void> {
  const UserAttendanceHistoryPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          UserAttendanceHistoryPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'UserAttendanceHistoryPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i22.UserListPage]
class UserListPageRouter extends _i25.PageRouteInfo<void> {
  const UserListPageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          UserListPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'UserListPageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}

/// generated route for
/// [_i23.UserPostsPage]
class UserPostsPageRouter extends _i25.PageRouteInfo<UserPostsPageRouterArgs> {
  UserPostsPageRouter({
    required String userId,
    _i26.Key? key,
    List<_i25.PageRouteInfo>? children,
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

  static const _i25.PageInfo<UserPostsPageRouterArgs> page =
      _i25.PageInfo<UserPostsPageRouterArgs>(name);
}

class UserPostsPageRouterArgs {
  const UserPostsPageRouterArgs({
    required this.userId,
    this.key,
  });

  final String userId;

  final _i26.Key? key;

  @override
  String toString() {
    return 'UserPostsPageRouterArgs{userId: $userId, key: $key}';
  }
}

/// generated route for
/// [_i24.UserQRCodePage]
class UserQRCodePageRouter extends _i25.PageRouteInfo<void> {
  const UserQRCodePageRouter({List<_i25.PageRouteInfo>? children})
      : super(
          UserQRCodePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'UserQRCodePageRouter';

  static const _i25.PageInfo<void> page = _i25.PageInfo<void>(name);
}
