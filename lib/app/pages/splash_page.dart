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
        debugPrint('SplashPage - Timeout reached, auth status: ${authBloc.state.authStatus}');
        if (authBloc.state.authStatus == AuthStatus.unknown) {
          debugPrint('SplashPage - Timeout: Navigating to signin page');
          AutoRouter.of(context).replaceAll([const SigninPageRouter()]);
        } else if (authBloc.state.authStatus == AuthStatus.authenticated) {
          debugPrint('SplashPage - Timeout: User authenticated, navigating to intro page');
          AutoRouter.of(context).replaceAll([const IntroPageRouter()]);
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
      // Listen to every state change to avoid missing transitions
      listenWhen: (previous, current) {
        // Always listen to state changes
        debugPrint('SplashPage - State change: ${previous.authStatus} -> ${current.authStatus}');
        return true;
      },
      listener: (context, state) {
        debugPrint('SplashPage - Auth state changed: ${state.authStatus}');
        debugPrint('SplashPage - User: ${state.user?.data['email']}');
        debugPrint('SplashPage - Mounted: $mounted');

        // Only navigate when we have a definitive auth status
        if (state.authStatus == AuthStatus.unauthenticated) {
          _timeoutTimer?.cancel();
          debugPrint('SplashPage - Navigating to signin page');
          // Use a small delay to ensure any pending state changes complete
          Future.microtask(() {
            if (context.mounted) {
              AutoRouter.of(context).replaceAll([const SigninPageRouter()]);
            }
          });
        } else if (state.authStatus == AuthStatus.authenticated) {
          _timeoutTimer?.cancel();
          debugPrint('SplashPage - Navigating to intro page');
          Future.microtask(() {
            if (context.mounted) {
              AutoRouter.of(context).replaceAll([
                const IntroPageRouter(),
              ]);
            }
          });
        } else {
          debugPrint('SplashPage - Auth status is unknown, keeping loading state');
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
                  state.authStatus == AuthStatus.unknown
                      ? 'Checking authentication...'
                      : state.authStatus == AuthStatus.unauthenticated
                          ? 'Redirecting to login...'
                          : 'Loading...',
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
