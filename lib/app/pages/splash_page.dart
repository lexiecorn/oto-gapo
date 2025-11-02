import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/bootstrap.dart';
import 'package:otogapo/services/notification_service.dart';
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
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    DebugHelper.log('SplashPage - Initializing splash screen');

    // Set a safety timeout to prevent infinite loading (increased for production stability)
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_hasNavigated) {
        _hasNavigated = true;
        DebugHelper.log('SplashPage - TIMEOUT: Force navigating to signin');
        // Force navigation to signin if auth check takes too long
        AutoRouter.of(context).replaceAll([const SigninPageRouter()]);
      }
    });

    // Trigger auth check to ensure we get auth state (stream may already have emitted)
    Future.microtask(() {
      if (mounted) {
        debugPrint('SplashPage - initState: Triggering CheckExistingAuthEvent as backup');
        context.read<AuthBloc>().add(CheckExistingAuthEvent());
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
    debugPrint('SplashPage - Building widget');
    
    // Check if auth state is already known when building (may have been emitted before listener registered)
    final authState = context.read<AuthBloc>().state;
    debugPrint('SplashPage - Current auth status when building: ${authState.authStatus}');
    
    // If already authenticated or unauthenticated, handle it immediately
    if (!_hasNavigated) {
      if (authState.authStatus == AuthStatus.authenticated) {
        _hasNavigated = true;
        Future.microtask(() {
          if (mounted) {
            debugPrint('SplashPage - Already authenticated when building, navigating to intro');
            AutoRouter.of(context).replaceAll([const IntroPageRouter()]);
          }
        });
      } else if (authState.authStatus == AuthStatus.unauthenticated) {
        _hasNavigated = true;
        Future.microtask(() {
          if (mounted) {
            debugPrint('SplashPage - Already unauthenticated when building, navigating to signin');
            AutoRouter.of(context).replaceAll([const SigninPageRouter()]);
          }
        });
      }
    }
    
    return BlocConsumer<AuthBloc, AuthState>(
      // Listen to every state change to avoid missing transitions
      listenWhen: (previous, current) {
        // Always listen to state changes
        debugPrint(
          'SplashPage - listenWhen: ${previous.authStatus} -> ${current.authStatus}',
        );
        return true;
      },
      listener: (context, state) {
        debugPrint('SplashPage - listener triggered: ${state.authStatus}');
        debugPrint('SplashPage - User: ${state.user?.data['email']}');
        debugPrint('SplashPage - Mounted: $mounted');

        // Only navigate when we have a definitive auth status and haven't navigated yet
        if (!_hasNavigated) {
          if (state.authStatus == AuthStatus.unauthenticated) {
            _hasNavigated = true;
            _timeoutTimer?.cancel();
            debugPrint('SplashPage - Navigating to signin page');
            // Use a small delay to ensure any pending state changes complete
            Future.microtask(() {
              if (context.mounted) {
                AutoRouter.of(context).replaceAll([const SigninPageRouter()]);
              }
            });
          } else if (state.authStatus == AuthStatus.authenticated) {
            _hasNavigated = true;
            _timeoutTimer?.cancel();
            debugPrint('SplashPage - User authenticated, saving FCM token');
            
            // Save FCM token now that user is authenticated
            try {
              final notificationService = getIt<NotificationService>();
              notificationService.saveCurrentTokenIfAuthenticated();
              debugPrint('SplashPage - FCM token save initiated');
            } catch (e) {
              debugPrint('SplashPage - Error saving FCM token: $e');
            }
            
            debugPrint('SplashPage - Navigating to intro page');
            Future.microtask(() {
              if (context.mounted) {
                AutoRouter.of(context).replaceAll([const IntroPageRouter()]);
              }
            });
          } else {
            debugPrint(
              'SplashPage - Auth status is unknown, keeping loading state',
            );
          }
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
