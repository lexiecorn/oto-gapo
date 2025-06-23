import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:otogapo/app/modules/signin/bloc/signin_cubit.dart';
import 'package:otogapo/app/modules/utils/error_dialog.dart';
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

  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Google Sign-In instance

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      _googleSignIn.signOut(); // Non-blocking sign out

      final googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;

        if (googleAuth.idToken != null) {
          // Use a local variable to store the result of read<SigninCubit>()
          final signinCubit = context.read<SigninCubit>();

          // Check if the context is still valid before calling the cubit method
          if (context.mounted) {
            signinCubit.signinWithGoogle(
              idToken: googleAuth.idToken!,
              displayName: googleUser.displayName,
            );
          } else {
            debugPrint('Context is no longer mounted. Not calling cubit method.');
            // Optionally handle this case, e.g., by logging an error or showing a snackbar on the next screen
          }
        } else {
          if (context.mounted) {
            await errorDialog(
              context,
              'Sign-in Failed',
              'We couldn\'t verify your Google account. Please try again. If the problem continues, check your internet connection or try a different account.',
              'Missing ID Token',
            );
          }
        }
      } else {
        debugPrint('User canceled Google Sign-In');
      }
    }
    // on GoogleSignInException catch (e) {
    //   if (context.mounted) {
    //     await errorDialog(
    //       context,
    //       'Google Sign-In Error',
    //       e.message ?? 'An error occurred during Google Sign-In.',
    //       e.runtimeType.toString(),
    //     );
    //   }
    //   debugPrint('Google Sign-In Exception: ${e.toString()}');
    // }
    catch (error) {
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
                state.error.message,
                state.error.code,
                state.error.plugin,
              );
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
                                color: Theme.of(context).textTheme.bodyLarge?.color,
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
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              decoration: loginFormFeildDecor(context, 'Password'),
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
                                onPressed: state.signinStatus == SigninStatus.submitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  backgroundColor: Colors.amber,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    submitBtnTxt(state),
                                    style: OpstechTextTheme.heading3
                                        .copyWith(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Row of 2 buttons, with google login button and facebook
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  state.signinStatus == SigninStatus.submitting ? null : _handleGoogleSignIn(context);
                                },
                                icon: Image.asset(
                                  'assets/icons/goog.png',
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {},
                                icon: Image.network(
                                  'https://www.facebook.com/favicon.ico',
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                          ],
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

  String submitBtnTxt(SigninState state) => state.signinStatus == SigninStatus.submitting ? 'Loading...' : 'Sign in';

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
