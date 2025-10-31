import 'package:attendance_repository/attendance_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/admin_analytics/bloc/admin_analytics_cubit.dart';
import 'package:otogapo/app/modules/attendance/bloc/attendance_cubit.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/calendar/bloc/calendar_cubit.dart';
import 'package:otogapo/app/modules/connectivity/bloc/connectivity_cubit.dart';
import 'package:otogapo/app/modules/meetings/bloc/meeting_cubit.dart';
import 'package:otogapo/app/modules/notifications/bloc/notification_cubit.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/modules/profile_progress/bloc/profile_progress_cubit.dart';
import 'package:otogapo/app/modules/signin/bloc/signin_cubit.dart';
import 'package:otogapo/app/modules/signup/signup_cubit.dart';
import 'package:otogapo/app/modules/version_check/bloc/version_check_cubit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:otogapo/app/routes/app_router.dart';
import 'package:otogapo/bootstrap.dart';
import 'package:otogapo/providers/theme_provider.dart';
import 'package:otogapo/repositories/version_repository.dart';
import 'package:otogapo/services/connectivity_service.dart';
import 'package:otogapo/services/notification_service.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/services/sync_service.dart';
import 'package:otogapo/utils/notification_navigation_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatelessWidget {
  const App({
    required AuthRepository authRepository,
    required PocketBaseAuthRepository pocketBaseAuthRepository,
    super.key,
  })  : _authRepository = authRepository,
        _pocketBaseAuthRepository = pocketBaseAuthRepository;

  final AuthRepository _authRepository;
  final PocketBaseAuthRepository _pocketBaseAuthRepository;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasError) {
          // If SharedPreferences fails, continue with app initialization
          print('SharedPreferences error: ${snapshot.error}');
          // In production, create a minimal fallback to prevent splash screen hang
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Initializing app...'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // Retry initialization
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Use snapshot.data if available, otherwise create a fallback
        final prefs = snapshot.data;

        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthRepository>.value(value: _authRepository),
            RepositoryProvider<PocketBaseAuthRepository>.value(
                value: _pocketBaseAuthRepository,),
            RepositoryProvider<ProfileRepository>(
              create: (context) => ProfileRepository(
                  pocketBaseAuth: context.read<PocketBaseAuthRepository>(),),
            ),
            RepositoryProvider<AttendanceRepository>(
              create: (context) => AttendanceRepository(
                  pocketBase:
                      context.read<PocketBaseAuthRepository>().pocketBase,),
            ),
            // Provide SyncService from GetIt singleton
            Provider<SyncService>(
              create: (_) => getIt<SyncService>(),
            ),
            // RepositoryProvider(
            //   create: (context) => PickListsRepository(
            //     pickingServices: PickListsApiServicses(
            //       client: getIt.get<Dio>(),
            //       baseUrl: FlavorConfig.instance.variables[OpstechConfigKeys.apiUrl2].toString(),
            //     ),
            //   ),
            // ),
            // RepositoryProvider(
            //   create: (context) => PickListRepository(
            //     pickingServices: PickListApiServicses(
            //       client: getIt.get<Dio>(),
            //       baseUrl: FlavorConfig.instance.variables[OpstechConfigKeys.apiUrl2].toString(),
            //     ),
            //   ),
            // ),
            // RepositoryProvider(
            //   create: (context) => PickListItemRepository(
            //     pickListItemService: PickListItemApiServicses(
            //       client: getIt.get<Dio>(),
            //       baseUrl: FlavorConfig.instance.variables[OpstechConfigKeys.apiUrl2].toString(),
            //     ),
            //   ),
            // ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(
                create: (context) => AuthBloc(
                  authRepository: context.read<AuthRepository>(),
                  pocketBaseAuth: context.read<PocketBaseAuthRepository>(),
                ),
              ),
              BlocProvider<SigninCubit>(
                create: (context) => SigninCubit(
                    pocketBaseAuth: context.read<PocketBaseAuthRepository>(),),
              ),
              BlocProvider<SignupCubit>(
                create: (context) =>
                    SignupCubit(authRepository: context.read<AuthRepository>()),
              ),
              BlocProvider<ProfileCubit>(
                create: (context) => ProfileCubit(
                  profileRepository: context.read<ProfileRepository>(),
                  syncService: context.read<SyncService>(),
                ),
              ),
              BlocProvider<MeetingCubit>(
                create: (context) => MeetingCubit(
                  attendanceRepository: context.read<AttendanceRepository>(),
                  syncService: context.read<SyncService>(),
                ),
              ),
              BlocProvider<AttendanceCubit>(
                create: (context) => AttendanceCubit(
                    attendanceRepository: context.read<AttendanceRepository>(),),
              ),
              // New Cubits for advanced features
              BlocProvider<ConnectivityCubit>(
                create: (context) => ConnectivityCubit(
                    connectivityService: getIt<ConnectivityService>(),
                    syncService: context.read<SyncService>(),),
              ),
              BlocProvider<CalendarCubit>(
                  create: (context) =>
                      CalendarCubit(pocketBaseService: PocketBaseService()),),
              BlocProvider<ProfileProgressCubit>(
                  create: (context) => ProfileProgressCubit(),),
              BlocProvider<AdminAnalyticsCubit>(
                create: (context) =>
                    AdminAnalyticsCubit(pocketBaseService: PocketBaseService()),
              ),
              BlocProvider<VersionCheckCubit>(
                create: (context) {
                  final versionRepository = VersionRepository();
                  final packageInfo = getIt<PackageInfo>();
                  return VersionCheckCubit(
                    versionRepository: versionRepository,
                    packageInfo: packageInfo,
                  );
                },
              ),
              BlocProvider<NotificationCubit>(
                create: (context) => NotificationCubit(
                  notificationService: getIt<NotificationService>(),
                ),
              ),
            ],
            child: ChangeNotifierProvider(
                create: (context) => ThemeProvider(prefs!),
                child: const AppView(),),
          ),
        );
      },
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final notificationService = getIt<NotificationService>();

    // Configure foreground notification display
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Configure notification tap when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification
    final initialMessage = await notificationService.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show notification even when app is in foreground
    // The OS handles this automatically based on configureForegroundNotification
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    if (!mounted) return;
    await NotificationNavigationHelper.handleNotificationTap(message, context);
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp.router(
              title: 'OTOGAPO',
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter.config(),
              theme: themeProvider.theme,
              builder: (context, child) {
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                  ),
                  child: child!,
                );
              },
            );
          },
        );
      },
    );
  }
}
