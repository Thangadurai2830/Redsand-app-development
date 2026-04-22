import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

import 'helpers/test_app_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'app boots and renders a MaterialApp',
    (tester) async {
      await registerTestAppDependencies();

      await tester.pumpWidget(const MyApp());

      // Only pump one frame — avoids pending splash timers
      expect(find.byType(MaterialApp), findsOneWidget);

      // Drain all pending timers so the test framework does not complain
      await tester.pumpAndSettle(const Duration(seconds: 5));
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}

