import 'package:authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/profile/bloc/profile_cubit.dart';
import 'package:otogapo/app/modules/signin/bloc/signin_cubit.dart';
import 'package:otogapo/app/modules/signup/signup_cubit.dart';
import 'package:otogapo/app/routes/app_router.dart';
import 'package:otogapo/bootstrap.dart';


class App extends StatelessWidget {
  const App({required AuthRepository authRepository, super.key}) : _authRepository = authRepository;

  final AuthRepository _authRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepository(
            firebaseFirestore: FirebaseFirestore.instance,
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
            ),
          ),
          BlocProvider<SigninCubit>(
            create: (context) => SigninCubit(
              authRepository: context.read<AuthRepository>(),
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

        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return ScreenUtilInit(
      designSize: const Size(1080, 2460),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Sarisuki',
          debugShowCheckedModeBanner: false,
          // routeInformationProvider: appRouter.routeInfoProvider(),
          routerConfig: appRouter.config(),
          // routeInformationParser: appRouter.defaultRouteParser(),
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          // routerDelegate: appRouter.delegate(
          //   navigatorObservers: () => [],
          // ),
          // builder: (context, child) {
          //   return MediaQuery(
          //     data: MediaQuery.of(context).copyWith(
          //       textScaleFactor: 1,
          //     ),
          //     child: SplashPage(),
          //   );
          // },
        );
      },
    );
  }
}
