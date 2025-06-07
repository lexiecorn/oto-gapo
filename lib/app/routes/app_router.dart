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
        AutoRoute(
          page: SigninPageRouter.page,
          path: '/register',
        ),
        AutoRoute(
          page: ProfilePageRouter.page,
          path: '/profile',
        ),
      ];
}
