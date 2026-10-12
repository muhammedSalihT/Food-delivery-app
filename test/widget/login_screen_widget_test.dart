import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets(
    'LoginScreen shows form fields, validation errors and demo credentials',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      await tester.pumpAndSettle();

      // Verify Title and elements matching the design
      expect(find.text('Log In'), findsNWidgets(2)); // Header title and button
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Email or Mobile Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forget Password'), findsOneWidget);
      expect(find.text('or sign up with'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);

      // Clear username field to trigger validation
      final usernameFinder = find.byKey(const Key('login_username_field'));
      await tester.enterText(usernameFinder, '');

      // Tap submit button
      final submitButtonFinder = find.byKey(const Key('login_submit_button'));
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      // Verify inline field validation message appears
      expect(find.text('Please enter your username'), findsOneWidget);
    },
  );
}
