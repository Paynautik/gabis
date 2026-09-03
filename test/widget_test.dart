import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nautik_money/app/app.dart';
import 'package:nautik_money/features/landing/gabis_landing_v3.dart';

void main() {
  // The app opens on the landing page, not the splash screen, and the mark at
  // the top is the wordmark asset rather than the word typed out, so there is
  // no 'gabis' text to find. What this actually guards is that the page builds
  // and settles: a layout overflow anywhere on the way fails the test, which
  // is how the phone mock-up and the card were caught spilling at 800x600.
  testWidgets('App boots to the landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GabisApp()));
    expect(find.byType(LandingScreen), findsOneWidget);
    // The landing page runs a looping animation, so it never settles. Pumping
    // a few frames is enough to catch a build or layout error.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));
  });
}
