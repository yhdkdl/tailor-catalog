import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_catalog/app.dart';

void main() {
  testWidgets('bootstrap screen shows app name', (WidgetTester tester) async {
    await tester.pumpWidget(const TailorApp());

    expect(find.text('Tailor Catalog'), findsOneWidget);
    expect(find.text('Your design catalog, ready to share'), findsOneWidget);
    expect(find.text('Supabase'), findsOneWidget);
    expect(find.text('Cloudinary'), findsOneWidget);
  });
}
