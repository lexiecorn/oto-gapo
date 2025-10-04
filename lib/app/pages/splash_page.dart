import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';

// import 'package:otogapo/app/routes/app_router.gr.dart';

@RoutePage(
  name: 'SplashPageRouter',
)
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  // static const String routeName = '/';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    // Set a timeout to prevent infinite loading
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        // If still unknown after timeout, redirect to signin
        final authBloc = context.read<AuthBloc>();
        if (authBloc.state.authStatus == AuthStatus.unknown) {
          AutoRouter.of(context).push(const SigninPageRouter());
        }
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Only navigate when we have a definitive auth status
        if (state.authStatus == AuthStatus.unauthenticated) {
          _timeoutTimer?.cancel();
          AutoRouter.of(context).push(const SigninPageRouter());
        } else if (state.authStatus == AuthStatus.authenticated) {
          _timeoutTimer?.cancel();
          AutoRouter.of(context).push(
            // const HomePageRouter(),
            const IntroPageRouter(),
          );
        }
        // If status is still unknown, keep showing loading
      },
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  state.authStatus == AuthStatus.unknown ? 'Checking authentication...' : 'Loading...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
