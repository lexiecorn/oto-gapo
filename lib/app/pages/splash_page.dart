import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';

// import 'package:otogapo/app/routes/app_router.gr.dart';

@RoutePage(
  name: 'SplashPageRouter',
)
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  // static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.authStatus == AuthStatus.unauthenticated) {
          AutoRouter.of(context).push(const SigninPageRouter());
        } else if (state.authStatus == AuthStatus.authenticated) {
          AutoRouter.of(context).push(
            // const HomePageRouter(),
            const IntroPageRouter(),
          );
        } else {
          AutoRouter.of(context).push(
            const SigninPageRouter(),
          );
        }
      },
      builder: (context, state) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
            ),
          ),
        );
      },
    );
  }
}
