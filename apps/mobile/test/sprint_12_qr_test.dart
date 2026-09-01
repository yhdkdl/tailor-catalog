import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:tailor_catalog/core/theme/app_theme.dart';
import 'package:tailor_catalog/features/auth/auth_repository.dart';
import 'package:tailor_catalog/features/designs/dashboard_screen.dart';
import 'package:tailor_catalog/features/designs/design_repository.dart';
import 'package:tailor_catalog/features/qr/qr_screen.dart';
import 'package:tailor_catalog/features/qr/qr_service.dart';

// ────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────

TailorProfile _testProfile({
  String shopName = 'Fasil Designs',
  String shopSlug = 'fasil-designs',
}) {
  return TailorProfile(
    id: 'p-1',
    authId: 'auth-1',
    shopName: shopName,
    shopSlug: shopSlug,
    status: 'approved',
    email: 'fasil@example.com',
  );
}

Widget _wrapWithMaterial(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: child,
  );
}

// ────────────────────────────────────────────────────────────
// QrService unit tests
// ────────────────────────────────────────────────────────────

void main() {
  group('QrService unit tests', () {
    test('buildCatalogUrl produces the correct URL', () {
      const slug = 'my-tailor-shop';
      final url = QrService.buildCatalogUrl(slug);
      expect(url, equals('https://tailor-catalog.vercel.app/my-tailor-shop'));
    });

    test('getQrStoragePath returns correct path', () {
      const uid = 'uid-123';
      const slug = 'my-shop';
      final path = QrService.getQrStoragePath(uid, slug);
      expect(path, equals('uid-123/my-shop-qr.png'));
    });

    test('buildCatalogUrl includes slug in URL', () {
      final url = QrService.buildCatalogUrl('testslug');
      expect(url, contains('testslug'));
    });
  });

  // ────────────────────────────────────────────────────────────
  // QrScreen widget tests
  // ────────────────────────────────────────────────────────────

  group('QrScreen widget tests', () {
    testWidgets('renders shop name', (tester) async {
      await tester.pumpWidget(_wrapWithMaterial(
        QrScreen(profile: _testProfile()),
      ));
      await tester.pump();
      expect(find.byKey(const Key('qr_shop_name')), findsOneWidget);
      expect(find.text('Fasil Designs'), findsWidgets);
    });

    testWidgets('renders shop slug', (tester) async {
      await tester.pumpWidget(_wrapWithMaterial(
        QrScreen(profile: _testProfile()),
      ));
      await tester.pump();
      expect(find.byKey(const Key('qr_shop_slug')), findsOneWidget);
      expect(find.text('fasil-designs'), findsOneWidget);
    });

    testWidgets('renders QrImageView widget', (tester) async {
      await tester.pumpWidget(_wrapWithMaterial(
        QrScreen(profile: _testProfile()),
      ));
      await tester.pump();
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('renders catalog URL text', (tester) async {
      await tester.pumpWidget(_wrapWithMaterial(
        QrScreen(profile: _testProfile()),
      ));
      await tester.pump();
      expect(find.byKey(const Key('qr_catalog_url')), findsOneWidget);
      final expectedUrl = QrService.buildCatalogUrl('fasil-designs');
      expect(find.text(expectedUrl), findsOneWidget);
    });

    testWidgets('renders Share Catalog Link button', (tester) async {
      await tester.pumpWidget(_wrapWithMaterial(
        QrScreen(profile: _testProfile()),
      ));
      await tester.pump();
      expect(find.byKey(const Key('share_qr_btn')), findsOneWidget);
      expect(find.text('Share Catalog Link'), findsOneWidget);
    });

    testWidgets('renders Copy Catalog Link button', (tester) async {
      await tester.pumpWidget(_wrapWithMaterial(
        QrScreen(profile: _testProfile()),
      ));
      await tester.pump();
      expect(find.byKey(const Key('copy_link_btn')), findsOneWidget);
      expect(find.text('Copy Catalog Link'), findsOneWidget);
    });

    testWidgets('AppBar title is "Store QR Code"', (tester) async {
      await tester.pumpWidget(_wrapWithMaterial(
        QrScreen(profile: _testProfile()),
      ));
      await tester.pump();
      expect(find.text('Store QR Code'), findsOneWidget);
    });
  });

  // ────────────────────────────────────────────────────────────
  // DashboardScreen → QrScreen navigation test
  // ────────────────────────────────────────────────────────────

  group('DashboardScreen QR navigation', () {
    testWidgets('QR icon button is present in AppBar', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: DashboardScreen(
          profile: _testProfile(),
          designRepository: const UnconfiguredDesignRepository(),
          onSignOut: () async {},
        ),
      ));
      await tester.pump();
      expect(find.byKey(const Key('qr_icon_btn')), findsOneWidget);
    });

    testWidgets('tapping QR icon navigates to QrScreen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: DashboardScreen(
          profile: _testProfile(),
          designRepository: const UnconfiguredDesignRepository(),
          onSignOut: () async {},
        ),
      ));
      await tester.pump();

      await tester.tap(find.byKey(const Key('qr_icon_btn')));
      await tester.pumpAndSettle();

      expect(find.byType(QrScreen), findsOneWidget);
      expect(find.text('Store QR Code'), findsOneWidget);
    });
  });
}
