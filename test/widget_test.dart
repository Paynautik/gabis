import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nautik_money/app/app.dart';

void main() {
  testWidgets('App boots to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GabisApp()));
    expect(find.text('gabis'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
