import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/utils/debug_helper.dart';
import 'package:otogapo/utils/network_helper.dart';

// import 'package:otogapo/app/routes/app_router.gr.dart';

@RoutePage(name: 'SplashPageRouter')
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
    DebugHelper.log('SplashPage - Initializing splash screen');

    // Set a safety timeout to prevent infinite loading (increased for production stability)
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        DebugHelper.log('SplashPage - TIMEOUT: Force navigating to signin');
        // Force navigation to signin if auth check takes too long
        AutoRouter.of(context).replaceAll([const SigninPageRouter()]);
      }
    });

    // Check network connectivity and show appropriate message
    _checkNetworkConnectivity();
  }

  Future<void> _checkNetworkConnectivity() async {
    final hasInternet = await NetworkHelper.hasInternetConnection();
    if (!hasInternet) {
      debugPrint('SplashPage - No internet connection detected');
    }
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
        debugPrint(
            'SplashPage - State change: ${previous.authStatus} -> ${current.authStatus}',);
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
              AutoRouter.of(context).replaceAll([const IntroPageRouter()]);
            }
          });
        } else {
          debugPrint(
              'SplashPage - Auth status is unknown, keeping loading state',);
        }
        // If status is still unknown, keep showing loading
      },
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(strokeWidth: 2),
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
