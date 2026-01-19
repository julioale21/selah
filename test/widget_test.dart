import 'package:flutter_test/flutter_test.dart';

import 'package:selah/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SelahApp());

    // Verify that the app title is displayed
    expect(find.text('Selah'), findsOneWidget);
    expect(find.text('Bienvenido a Selah'), findsOneWidget);
  });
}
