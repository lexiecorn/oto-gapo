import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:otogapo/app/modules/auth/auth_bloc.dart';
import 'package:otogapo/app/modules/signin/bloc/signin_cubit.dart';
import 'package:otogapo/app/modules/utils/error_dialog.dart';
import 'package:otogapo/app/routes/app_router.gr.dart';
import 'package:otogapo/utils/crashlytics_helper.dart';
import 'package:otogapo_core/otogapo_core.dart';
import 'package:validators/validators.dart';

@RoutePage(
  name: 'SigninPageRouter',
)
class SigninPage extends StatefulWidget {
  const SigninPage({super.key});
  // static const String routeName = '/signin';

  @override
  SigninPageState createState() => SigninPageState();
}

class SigninPageState extends State<SigninPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String? _email;
  String? _password;

  void _submit() {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    form.save();

    context.read<SigninCubit>().signin(email: _email!, password: _password!);
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final signinCubit = context.read<SigninCubit>();

      if (context.mounted) {
        // Use PocketBase native Google OAuth
        signinCubit.signinWithGoogleOAuth();
      }
    } catch (error, stackTrace) {
      // Log to Crashlytics and n8n
      await CrashlyticsHelper.logError(
        error,
        stackTrace,
        reason: 'Google sign-in UI error',
        fatal: false,
      );
      if (context.mounted) {
        await errorDialog(
          context,
          'Google Sign-In Error',
          error.toString(),
          error.runtimeType.toString(),
        );
      }
      debugPrint('Google Sign-In Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // onWillPop: () async => false,

      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocConsumer<SigninCubit, SigninState>(
          listener: (context, state) {
            if (state.signinStatus == SigninStatus.error) {
              errorDialog(
                context,
                state.error?.message ?? 'An error occurred',
                state.error?.code ?? 'Error',
                state.error?.plugin ?? '',
              );
            } else if (state.signinStatus == SigninStatus.success) {
              // Navigate to splash page which will handle auth state transition
              debugPrint(
                  'SigninPage - Signin successful, navigating to splash page',);
              
              // Navigate immediately - SplashPage will handle checking auth state
              Future.microtask(() {
                if (context.mounted) {
                  debugPrint('SigninPage - Navigating to SplashPage');
                  AutoRouter.of(context).replaceAll([const SplashPageRouter()]);
                }
              });
            }
          },
          builder: (context, state) {
            return Scaffold(
              // backgroundColor: Colors.white,
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                // arrow back
                centerTitle: true,
                leading: const SizedBox.shrink(),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: .8.sw,
                              child: Image.asset(
                                'assets/images/logo_sm.jpg',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                              decoration: loginFormFeildDecor(context, 'Email'),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email required';
                                }
                                if (!isEmail(value.trim())) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                              onSaved: (String? value) {
                                _email = value;
                              },
                            ),
                            const SizedBox(height: 20),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              obscureText: true,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                              decoration:
                                  loginFormFeildDecor(context, 'Password'),
                              validator: (String? value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Password required';
                                }
                                if (value.trim().length < 6) {
                                  // ignore: lines_longer_than_80_chars
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                              onSaved: (String? value) {
                                _password = value;
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                // ignore: lines_longer_than_80_chars
                                onPressed: state.signinStatus ==
                                        SigninStatus.submitting
                                    ? null
                                    : _submit,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  backgroundColor: Colors.amber,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    submitBtnTxt(state),
                                    style: OpstechTextTheme.heading3.copyWith(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // OR divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.withOpacity(0.5),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.withOpacity(0.5),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Google login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                state.signinStatus == SigninStatus.submitting
                                    ? null
                                    : () => _handleGoogleSignIn(context),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              backgroundColor: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child:
                                  state.signinStatus == SigninStatus.submitting
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.grey,),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/icons/goog.png',
                                              height: 24,
                                              width: 24,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Sign in with Google',
                                              style: OpstechTextTheme.heading3
                                                  .copyWith(
                                                color: Colors.black87,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String submitBtnTxt(SigninState state) =>
      state.signinStatus == SigninStatus.submitting ? 'Loading...' : 'Sign in';

  InputDecoration loginFormFeildDecor(BuildContext context, [String? s]) {
    return InputDecoration(
      hintText: s,
      hintStyle: TextStyle(
        color: Theme.of(context).hintColor,
        fontWeight: FontWeight.w200,
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black12, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(width: 2),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      filled: true,
      // labelText: s,
      // prefixIcon: const Icon(Icons.lock),
      labelStyle: TextStyle(
        color: Theme.of(context).hintColor,
      ),
    );
  }
}
