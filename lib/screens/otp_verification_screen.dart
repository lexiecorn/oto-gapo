import 'package:flutter/material.dart';
import 'package:otogapo/providers/auth_provider.dart';
import 'package:otogapo/providers/user_provider.dart';
import 'package:otogapo/utils/validators.dart';
import 'package:otogapo/widgets/custom_button.dart';
import 'package:otogapo/widgets/custom_text_field.dart';
import 'package:otogapo/widgets/loading_overlay.dart';
import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    required this.phoneNumber,
    required this.verificationId,
    super.key,
  });
  final String phoneNumber;
  final String verificationId;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  int _remainingTime = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
            _startTimer();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final user = await authProvider.verifyOtp(
        widget.verificationId,
        _otpController.text,
      );

      if (user != null) {
        await userProvider.setUser(user);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _canResend = false;
      _remainingTime = 60;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.sendOtp(widget.phoneNumber);
      _startTimer();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _canResend = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.phone_android,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enter the verification code sent to',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.phoneNumber,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _otpController,
                    labelText: 'Verification Code',
                    hintText: 'Enter 6-digit code',
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: Validators.validateOtp,
                    prefixIcon: const Icon(Icons.lock_outline),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 8,
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    onPressed: _verifyOtp,
                    text: 'Verify',
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _canResend ? _resendOtp : null,
                    child: Text(
                      _canResend
                          ? 'Resend Code'
                          : 'Resend Code in $_remainingTime seconds',
                      style: TextStyle(
                        color: _canResend
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
