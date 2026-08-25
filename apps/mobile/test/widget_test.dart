import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_catalog/app.dart';

void main() {
  testWidgets('unconfigured app shows tailor sign in', (WidgetTester tester) async {
    await tester.pumpWidget(const TailorApp());

    expect(find.text('Tailor sign in'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Send code'), findsOneWidget);
  });

  testWidgets('email is required before requesting a code', (WidgetTester tester) async {
    await tester.pumpWidget(const TailorApp());

    await tester.tap(find.text('Send code'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });
}
