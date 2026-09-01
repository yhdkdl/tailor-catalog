import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_catalog/app.dart';

void main() {
  testWidgets('unconfigured app shows tailor sign in with password field', (WidgetTester tester) async {
    await tester.pumpWidget(const TailorApp());

    expect(find.text('Tailor sign in'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('validation occurs before sign in submission', (WidgetTester tester) async {
    await tester.pumpWidget(const TailorApp());

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });
}
