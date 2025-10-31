import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Launch the PRODUCTION flavor app
import 'package:otogapo/main_production.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PRODUCTION login with email/password navigates past SigninPage', (tester) async {
    // Start the application (PRODUCTION flavor)
    app.main();

    // Wait for app to initialize and navigate from SplashPage to SigninPage
    await tester.pumpAndSettle(const Duration(seconds: 10));

    // Wait for SigninPage to be fully visible and find text fields
    // On real devices, text fields may take longer to render
    Finder? emailField;
    Finder? passwordField;

    // Wait up to 15 seconds for fields to appear
    int attempts = 0;
    while (attempts < 30 && (emailField == null || passwordField == null)) {
      await tester.pump(const Duration(milliseconds: 500));

      // Try finding by type
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        emailField = textFields.at(0);
        passwordField = textFields.at(1);
        break;
      }

      attempts++;
    }

    // Verify fields were found
    expect(emailField, isNotNull, reason: 'Email field should be found');
    expect(passwordField, isNotNull, reason: 'Password field should be found');
    expect(emailField!, findsOneWidget, reason: 'Email field should be visible');
    expect(passwordField!, findsOneWidget, reason: 'Password field should be visible');

    // Ensure fields are visible and tappable
    await tester.ensureVisible(emailField!);
    await tester.ensureVisible(passwordField!);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // NOTE: Text input on real Android devices via integration_test is unreliable
    // The test framework has limitations with real device keyboards
    // For now, you may need to manually enter credentials during the test
    // OR run this on an emulator where text input works better

    // Try to enter credentials - this may not work on all real devices
    await tester.tap(emailField!);
    await tester.pump(const Duration(seconds: 3)); // Longer wait for real device

    // Attempt to enter email - may fail silently on real device
    try {
      await tester.enterText(emailField!, 'ialexies@gmail.com');
      await tester.pump(const Duration(seconds: 2));
    } catch (e) {
      print('Warning: Could not enter email automatically: $e');
      print('You may need to enter credentials manually on the device');
    }

    // Move to password field
    await tester.tap(passwordField!);
    await tester.pump(const Duration(seconds: 3)); // Longer wait for real device

    // Attempt to enter password - may fail silently on real device
    try {
      await tester.enterText(passwordField!, 'chachielex');
      await tester.pump(const Duration(seconds: 2));
    } catch (e) {
      print('Warning: Could not enter password automatically: $e');
      print('You may need to enter credentials manually on the device');
    }

    // Give user time to manually enter if auto-entry failed
    print('Waiting 10 seconds - if text was not entered, please enter credentials manually now');
    await tester.pump(const Duration(seconds: 10));

    // Wait a moment for form validation
    await tester.pump(const Duration(milliseconds: 500));

    // Find and tap Sign in button
    // Button might show "Sign in" or "Loading..." text
    final signInButton = find.byType(ElevatedButton).first;
    expect(signInButton, findsOneWidget);

    // Make sure button is enabled (not in loading state)
    final buttonWidget = tester.widget<ElevatedButton>(signInButton);
    expect(buttonWidget.onPressed, isNotNull, reason: 'Sign in button should be enabled');

    await tester.tap(signInButton);
    await tester.pump();

    // Wait for button to show loading state
    await tester.pump(const Duration(seconds: 1));

    // Wait for sign-in to complete - this may take several seconds due to network
    // After successful login, app navigates: SigninPage -> SplashPage -> IntroPage
    await tester.pumpAndSettle(const Duration(seconds: 20));

    // Verify we've navigated away from SigninPage
    // After successful login: SigninPage -> SplashPage -> IntroPage
    // Check if we still have the login form fields (if yes, we're still on SigninPage)
    final loginEmailField = find.byType(TextFormField);
    if (loginEmailField.evaluate().isNotEmpty) {
      // Still on SigninPage - check if there's an error dialog
      final dialogs = find.byType(AlertDialog);
      if (dialogs.evaluate().isNotEmpty) {
        // Error dialog is showing - login failed
        final dialogText = find.textContaining('error', findRichText: true);
        if (dialogText.evaluate().isNotEmpty) {
          fail('Login failed: Error dialog is showing');
        }
      }
      fail('Still on SigninPage after login attempt - navigation may have failed');
    }

    // If we got here, we've navigated away from SigninPage
    // Verify by checking that login form fields are gone
    expect(loginEmailField, findsNothing, reason: 'Should have navigated away from SigninPage (no login form fields)');
  });
}
