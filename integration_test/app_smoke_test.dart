import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart';

import '../test/helpers/test_app_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Splash → Onboarding flow (new user)', () {
    testWidgets('moves from splash to onboarding', (tester) async {
      await registerTestAppDependencies(onboardingComplete: false);

      await tester.pumpWidget(const MyApp());

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Find Rental Properties'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('onboarding shows Skip button on first slide', (tester) async {
      await registerTestAppDependencies(onboardingComplete: false);

      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('tapping Skip dismisses onboarding', (tester) async {
      await registerTestAppDependencies(onboardingComplete: false);

      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // After skipping, we should leave the onboarding page
      expect(find.text('Find Rental Properties'), findsNothing);
    });
  });

  group('Splash → Login flow (returning user, no token)', () {
    testWidgets('unauthenticated user lands on login after onboarding complete',
        (tester) async {
      await registerTestAppDependencies(onboardingComplete: true);

      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should be on login — look for email or password field
      final loginIndicators = [
        find.byType(TextField),
        find.text('Login'),
        find.text('Sign in'),
        find.textContaining('email'),
      ];
      final found = loginIndicators.any((f) => f.evaluate().isNotEmpty);
      expect(found, isTrue,
          reason: 'Expected login screen for unauthenticated returning user');
    });
  });
}

