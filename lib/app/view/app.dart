import 'package:attendance_repository/attendance_repository.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:authentication_repository/src/pocketbase_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_storage/local_storage.dart';
import 'package:otogapo/app/modules/admin_analytics/bloc/admin_analytics_cubit.dart';
import 'package:otogapo/app/modules/attendance/bloc/attendance_cubit.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/calendar/bloc/calendar_cubit.dart';
import 'package:otogapo/app/modules/connectivity/bloc/connectivity_cubit.dart';
import 'package:otogapo/app/modules/meetings/bloc/meeting_cubit.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/modules/profile_progress/bloc/profile_progress_cubit.dart';
import 'package:otogapo/app/modules/search/bloc/search_cubit.dart';
import 'package:otogapo/app/modules/signin/bloc/signin_cubit.dart';
import 'package:otogapo/app/modules/signup/signup_cubit.dart';
import 'package:otogapo/app/routes/app_router.dart';
import 'package:otogapo/bootstrap.dart';
import 'package:otogapo/providers/theme_provider.dart';
import 'package:otogapo/services/connectivity_service.dart';
import 'package:otogapo/services/pocketbase_service.dart';
import 'package:otogapo/services/sync_service.dart';
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
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AuthRepository>.value(value: _authRepository),
            RepositoryProvider<PocketBaseAuthRepository>.value(value: _pocketBaseAuthRepository),
            RepositoryProvider<ProfileRepository>(
              create: (context) => ProfileRepository(
                pocketBaseAuth: context.read<PocketBaseAuthRepository>(),
              ),
            ),
            RepositoryProvider<AttendanceRepository>(
              create: (context) => AttendanceRepository(
                pocketBase: context.read<PocketBaseAuthRepository>().pocketBase,
              ),
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
                  pocketBaseAuth: context.read<PocketBaseAuthRepository>(),
                ),
              ),
              BlocProvider<SignupCubit>(
                create: (context) => SignupCubit(
                  authRepository: context.read<AuthRepository>(),
                ),
              ),
              BlocProvider<ProfileCubit>(
                create: (context) => ProfileCubit(
                  profileRepository: context.read<ProfileRepository>(),
                ),
              ),
              BlocProvider<MeetingCubit>(
                create: (context) => MeetingCubit(
                  attendanceRepository: context.read<AttendanceRepository>(),
                ),
              ),
              BlocProvider<AttendanceCubit>(
                create: (context) => AttendanceCubit(
                  attendanceRepository: context.read<AttendanceRepository>(),
                ),
              ),
              // New Cubits for advanced features
              BlocProvider<ConnectivityCubit>(
                create: (context) => ConnectivityCubit(
                  connectivityService: ConnectivityService(),
                  syncService: SyncService(),
                ),
              ),
              BlocProvider<SearchCubit>(
                create: (context) => SearchCubit(
                  pocketBaseService: PocketBaseService(),
                  localStorage: const LocalStorage(),
                ),
              ),
              BlocProvider<CalendarCubit>(
                create: (context) => CalendarCubit(
                  pocketBaseService: PocketBaseService(),
                ),
              ),
              BlocProvider<ProfileProgressCubit>(
                create: (context) => ProfileProgressCubit(),
              ),
              BlocProvider<AdminAnalyticsCubit>(
                create: (context) => AdminAnalyticsCubit(
                  pocketBaseService: PocketBaseService(),
                ),
              ),
            ],
            child: ChangeNotifierProvider(
              create: (context) => ThemeProvider(snapshot.data!),
              child: const AppView(),
            ),
          ),
        );
      },
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

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
            );
          },
        );
      },
    );
  }
}
