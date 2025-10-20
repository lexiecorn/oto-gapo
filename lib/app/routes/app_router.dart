import 'package:auto_route/auto_route.dart';

// import 'package:otogapo/app/routes/app_router.gr.dart';
// part 'app_router.gr.dart';

import 'package:otogapo/app/routes/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: SplashPageRouter.page,
          initial: true,
          path: '/',
        ),
        AutoRoute(
          page: HomePageRouter.page,
          path: '/home',
        ),
        AutoRoute(
          page: IntroPageRouter.page,
          path: '/intro',
        ),
        AutoRoute(
          path: '/signin',
          page: SigninPageRouter.page,
        ),
        // Signup disabled - users are created by admins only
        // AutoRoute(
        //   page: SignupPageRouter.page,
        //   path: '/register',
        // ),
        AutoRoute(
          page: ProfilePageRouter.page,
          path: '/profile',
        ),
        // Attendance routes
        AutoRoute(
          page: MeetingsListPageRouter.page,
          path: '/meetings',
        ),
        AutoRoute(
          page: CreateMeetingPageRouter.page,
          path: '/meetings/create',
        ),
        AutoRoute(
          page: MeetingDetailsPageRouter.page,
          path: '/meetings/:meetingId',
        ),
        AutoRoute(
          page: MeetingQRCodePageRouter.page,
          path: '/meetings/:meetingId/qr',
        ),
        AutoRoute(
          page: MarkAttendancePageRouter.page,
          path: '/meetings/:meetingId/mark-attendance',
        ),
        AutoRoute(
          page: QRScannerPageRouter.page,
          path: '/scan-qr',
        ),
        AutoRoute(
          page: UserQRCodePageRouter.page,
          path: '/my-qr-code',
        ),
        AutoRoute(
          page: UserAttendanceHistoryPageRouter.page,
          path: '/attendance/history',
        ),
        AutoRoute(
          page: AttendanceCalendarPageRouter.page,
          path: '/attendance/calendar',
        ),
        // Members route
        AutoRoute(
          page: UserListPageRouter.page,
          path: '/members',
        ),
        // Announcements route
        AutoRoute(
          page: AnnouncementsListPageRouter.page,
          path: '/announcements',
        ),
        // Social Feed routes
        AutoRoute(
          page: SocialFeedPageRouter.page,
          path: '/social-feed',
        ),
        AutoRoute(
          page: CreatePostPageRouter.page,
          path: '/social-feed/create',
        ),
        AutoRoute(
          page: PostDetailPageRouter.page,
          path: '/social-feed/post/:postId',
        ),
        AutoRoute(
          page: UserPostsPageRouter.page,
          path: '/social-feed/user/:userId',
        ),
        AutoRoute(
          page: HashtagPostsPageRouter.page,
          path: '/social-feed/hashtag/:hashtag',
        ),
        AutoRoute(
          page: SocialFeedModerationPageRouter.page,
          path: '/social-feed/moderation',
        ),
      ];
}
