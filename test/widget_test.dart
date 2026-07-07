import 'package:flex_scan/firebase_options.dart';
import 'package:flex_scan/screens/auth/forgot_password_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('forgot password screen shows the reset-link flow',
      (tester) async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
    expect(find.text('Verification code'), findsNothing);
  });
}
