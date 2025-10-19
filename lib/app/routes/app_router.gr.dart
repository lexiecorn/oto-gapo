// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i22;
import 'package:flutter/material.dart' as _i23;
import 'package:otogapo/app/modules/profile/profile_page.dart' as _i12;
import 'package:otogapo/app/modules/signin/signin_page.dart' as _i14;
import 'package:otogapo/app/modules/signup/signup_page.dart' as _i15;
import 'package:otogapo/app/pages/create_meeting_page.dart' as _i1;
import 'package:otogapo/app/pages/create_post_page.dart' as _i2;
import 'package:otogapo/app/pages/hashtag_posts_page.dart' as _i3;
import 'package:otogapo/app/pages/home_body.dart' as _i4;
import 'package:otogapo/app/pages/home_page.dart' as _i5;
import 'package:otogapo/app/pages/mark_attendance_page.dart' as _i7;
import 'package:otogapo/app/pages/meeting_details_page.dart' as _i8;
import 'package:otogapo/app/pages/meeting_qr_code_page.dart' as _i9;
import 'package:otogapo/app/pages/meetings_list_page.dart' as _i10;
import 'package:otogapo/app/pages/post_detail_page.dart' as _i11;
import 'package:otogapo/app/pages/qr_scanner_page.dart' as _i13;
import 'package:otogapo/app/pages/social_feed_moderation_page.dart' as _i16;
import 'package:otogapo/app/pages/social_feed_page.dart' as _i17;
import 'package:otogapo/app/pages/splash_page.dart' as _i18;
import 'package:otogapo/app/pages/user_attendance_history_page.dart' as _i19;
import 'package:otogapo/app/pages/user_posts_page.dart' as _i20;
import 'package:otogapo/app/pages/user_qr_code_page.dart' as _i21;
import 'package:otogapo/app/widgets/intro.dart' as _i6;
import 'package:otogapo/models/meeting.dart' as _i24;

abstract class $AppRouter extends _i22.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i22.PageFactory> pagesMap = {
    CreateMeetingPageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.CreateMeetingPage(),
      );
    },
    CreatePostPageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.CreatePostPage(),
      );
    },
    HashtagPostsPageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<HashtagPostsPageRouterArgs>(
          orElse: () => HashtagPostsPageRouterArgs(
              hashtag: pathParams.getString('hashtag')));
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i3.HashtagPostsPage(
          hashtag: args.hashtag,
          key: args.key,
        ),
      );
    },
    HomeBodyRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.HomeBody(),
      );
    },
    HomePageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.HomePage(),
      );
    },
    IntroPageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.IntroPage(),
      );
    },
    MarkAttendancePageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<MarkAttendancePageRouterArgs>(
          orElse: () => MarkAttendancePageRouterArgs(
              meetingId: pathParams.getString('meetingId')));
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i7.MarkAttendancePage(
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
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i8.MeetingDetailsPage(
          meetingId: args.meetingId,
          key: args.key,
        ),
      );
    },
    MeetingQRCodePageRouter.name: (routeData) {
      final args = routeData.argsAs<MeetingQRCodePageRouterArgs>();
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i9.MeetingQRCodePage(
          meeting: args.meeting,
          key: args.key,
        ),
      );
    },
    MeetingsListPageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.MeetingsListPage(),
      );
    },
    PostDetailPageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<PostDetailPageRouterArgs>(
          orElse: () =>
              PostDetailPageRouterArgs(postId: pathParams.getString('postId')));
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i11.PostDetailPage(
          postId: args.postId,
          key: args.key,
        ),
      );
    },
    ProfilePageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i12.ProfilePage(),
      );
    },
    QRScannerPageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i13.QRScannerPage(),
      );
    },
    SigninPageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i14.SigninPage(),
      );
    },
    SignupPageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i15.SignupPage(),
      );
    },
    SocialFeedModerationPageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i16.SocialFeedModerationPage(),
      );
    },
    SocialFeedPageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i17.SocialFeedPage(),
      );
    },
    SplashPageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i18.SplashPage(),
      );
    },
    UserAttendanceHistoryPageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i19.UserAttendanceHistoryPage(),
      );
    },
    UserPostsPageRouter.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<UserPostsPageRouterArgs>(
          orElse: () =>
              UserPostsPageRouterArgs(userId: pathParams.getString('userId')));
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i20.UserPostsPage(
          userId: args.userId,
          key: args.key,
        ),
      );
    },
    UserQRCodePageRouter.name: (routeData) {
      return _i22.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i21.UserQRCodePage(),
      );
    },
  };
}

/// generated route for
/// [_i1.CreateMeetingPage]
class CreateMeetingPageRouter extends _i22.PageRouteInfo<void> {
  const CreateMeetingPageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          CreateMeetingPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'CreateMeetingPageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i2.CreatePostPage]
class CreatePostPageRouter extends _i22.PageRouteInfo<void> {
  const CreatePostPageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          CreatePostPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'CreatePostPageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i3.HashtagPostsPage]
class HashtagPostsPageRouter
    extends _i22.PageRouteInfo<HashtagPostsPageRouterArgs> {
  HashtagPostsPageRouter({
    required String hashtag,
    _i23.Key? key,
    List<_i22.PageRouteInfo>? children,
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

  static const _i22.PageInfo<HashtagPostsPageRouterArgs> page =
      _i22.PageInfo<HashtagPostsPageRouterArgs>(name);
}

class HashtagPostsPageRouterArgs {
  const HashtagPostsPageRouterArgs({
    required this.hashtag,
    this.key,
  });

  final String hashtag;

  final _i23.Key? key;

  @override
  String toString() {
    return 'HashtagPostsPageRouterArgs{hashtag: $hashtag, key: $key}';
  }
}

/// generated route for
/// [_i4.HomeBody]
class HomeBodyRouter extends _i22.PageRouteInfo<void> {
  const HomeBodyRouter({List<_i22.PageRouteInfo>? children})
      : super(
          HomeBodyRouter.name,
          initialChildren: children,
        );

  static const String name = 'HomeBodyRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i5.HomePage]
class HomePageRouter extends _i22.PageRouteInfo<void> {
  const HomePageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          HomePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'HomePageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i6.IntroPage]
class IntroPageRouter extends _i22.PageRouteInfo<void> {
  const IntroPageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          IntroPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'IntroPageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i7.MarkAttendancePage]
class MarkAttendancePageRouter
    extends _i22.PageRouteInfo<MarkAttendancePageRouterArgs> {
  MarkAttendancePageRouter({
    required String meetingId,
    _i23.Key? key,
    List<_i22.PageRouteInfo>? children,
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

  static const _i22.PageInfo<MarkAttendancePageRouterArgs> page =
      _i22.PageInfo<MarkAttendancePageRouterArgs>(name);
}

class MarkAttendancePageRouterArgs {
  const MarkAttendancePageRouterArgs({
    required this.meetingId,
    this.key,
  });

  final String meetingId;

  final _i23.Key? key;

  @override
  String toString() {
    return 'MarkAttendancePageRouterArgs{meetingId: $meetingId, key: $key}';
  }
}

/// generated route for
/// [_i8.MeetingDetailsPage]
class MeetingDetailsPageRouter
    extends _i22.PageRouteInfo<MeetingDetailsPageRouterArgs> {
  MeetingDetailsPageRouter({
    required String meetingId,
    _i23.Key? key,
    List<_i22.PageRouteInfo>? children,
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

  static const _i22.PageInfo<MeetingDetailsPageRouterArgs> page =
      _i22.PageInfo<MeetingDetailsPageRouterArgs>(name);
}

class MeetingDetailsPageRouterArgs {
  const MeetingDetailsPageRouterArgs({
    required this.meetingId,
    this.key,
  });

  final String meetingId;

  final _i23.Key? key;

  @override
  String toString() {
    return 'MeetingDetailsPageRouterArgs{meetingId: $meetingId, key: $key}';
  }
}

/// generated route for
/// [_i9.MeetingQRCodePage]
class MeetingQRCodePageRouter
    extends _i22.PageRouteInfo<MeetingQRCodePageRouterArgs> {
  MeetingQRCodePageRouter({
    required _i24.Meeting meeting,
    _i23.Key? key,
    List<_i22.PageRouteInfo>? children,
  }) : super(
          MeetingQRCodePageRouter.name,
          args: MeetingQRCodePageRouterArgs(
            meeting: meeting,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'MeetingQRCodePageRouter';

  static const _i22.PageInfo<MeetingQRCodePageRouterArgs> page =
      _i22.PageInfo<MeetingQRCodePageRouterArgs>(name);
}

class MeetingQRCodePageRouterArgs {
  const MeetingQRCodePageRouterArgs({
    required this.meeting,
    this.key,
  });

  final _i24.Meeting meeting;

  final _i23.Key? key;

  @override
  String toString() {
    return 'MeetingQRCodePageRouterArgs{meeting: $meeting, key: $key}';
  }
}

/// generated route for
/// [_i10.MeetingsListPage]
class MeetingsListPageRouter extends _i22.PageRouteInfo<void> {
  const MeetingsListPageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          MeetingsListPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'MeetingsListPageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i11.PostDetailPage]
class PostDetailPageRouter
    extends _i22.PageRouteInfo<PostDetailPageRouterArgs> {
  PostDetailPageRouter({
    required String postId,
    _i23.Key? key,
    List<_i22.PageRouteInfo>? children,
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

  static const _i22.PageInfo<PostDetailPageRouterArgs> page =
      _i22.PageInfo<PostDetailPageRouterArgs>(name);
}

class PostDetailPageRouterArgs {
  const PostDetailPageRouterArgs({
    required this.postId,
    this.key,
  });

  final String postId;

  final _i23.Key? key;

  @override
  String toString() {
    return 'PostDetailPageRouterArgs{postId: $postId, key: $key}';
  }
}

/// generated route for
/// [_i12.ProfilePage]
class ProfilePageRouter extends _i22.PageRouteInfo<void> {
  const ProfilePageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          ProfilePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'ProfilePageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i13.QRScannerPage]
class QRScannerPageRouter extends _i22.PageRouteInfo<void> {
  const QRScannerPageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          QRScannerPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'QRScannerPageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i14.SigninPage]
class SigninPageRouter extends _i22.PageRouteInfo<void> {
  const SigninPageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          SigninPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SigninPageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i15.SignupPage]
class SignupPageRouter extends _i22.PageRouteInfo<void> {
  const SignupPageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          SignupPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SignupPageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i16.SocialFeedModerationPage]
class SocialFeedModerationPageRouter extends _i22.PageRouteInfo<void> {
  const SocialFeedModerationPageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          SocialFeedModerationPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SocialFeedModerationPageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i17.SocialFeedPage]
class SocialFeedPageRouter extends _i22.PageRouteInfo<void> {
  const SocialFeedPageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          SocialFeedPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SocialFeedPageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i18.SplashPage]
class SplashPageRouter extends _i22.PageRouteInfo<void> {
  const SplashPageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          SplashPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'SplashPageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i19.UserAttendanceHistoryPage]
class UserAttendanceHistoryPageRouter extends _i22.PageRouteInfo<void> {
  const UserAttendanceHistoryPageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          UserAttendanceHistoryPageRouter.name,
          initialChildren: children,
        );

  static const String name = 'UserAttendanceHistoryPageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}

/// generated route for
/// [_i20.UserPostsPage]
class UserPostsPageRouter extends _i22.PageRouteInfo<UserPostsPageRouterArgs> {
  UserPostsPageRouter({
    required String userId,
    _i23.Key? key,
    List<_i22.PageRouteInfo>? children,
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

  static const _i22.PageInfo<UserPostsPageRouterArgs> page =
      _i22.PageInfo<UserPostsPageRouterArgs>(name);
}

class UserPostsPageRouterArgs {
  const UserPostsPageRouterArgs({
    required this.userId,
    this.key,
  });

  final String userId;

  final _i23.Key? key;

  @override
  String toString() {
    return 'UserPostsPageRouterArgs{userId: $userId, key: $key}';
  }
}

/// generated route for
/// [_i21.UserQRCodePage]
class UserQRCodePageRouter extends _i22.PageRouteInfo<void> {
  const UserQRCodePageRouter({List<_i22.PageRouteInfo>? children})
      : super(
          UserQRCodePageRouter.name,
          initialChildren: children,
        );

  static const String name = 'UserQRCodePageRouter';

  static const _i22.PageInfo<void> page = _i22.PageInfo<void>(name);
}
