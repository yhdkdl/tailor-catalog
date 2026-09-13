import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tailor_catalog/app.dart';
import 'package:tailor_catalog/core/l10n/app_localizations.dart';
import 'package:tailor_catalog/core/l10n/app_localizations_am.dart';
import 'package:tailor_catalog/core/l10n/app_localizations_en.dart';
import 'package:tailor_catalog/core/locale/language_toggle.dart';
import 'package:tailor_catalog/core/locale/locale_provider.dart';

void main() {
  group('Localization Tests', () {
    test('LocaleProvider defaults to English and switches to Amharic', () async {
      final provider = LocaleProvider();
      expect(provider.locale.languageCode, equals('en'));

      var notified = false;
      provider.addListener(() => notified = true);

      await provider.setLocale(const Locale('am'));
      expect(provider.locale.languageCode, equals('am'));
      expect(notified, isTrue);

      await provider.setLocale(const Locale('en'));
      expect(provider.locale.languageCode, equals('en'));
    });

    test('AppLocalizations returns correct translations for en and am', () {
      final en = AppLocalizationsEn();
      final am = AppLocalizationsAm();

      expect(en.appTitle, equals('Tailor Catalog'));
      expect(am.appTitle, equals('ጥለት ካታሎግ'));

      expect(en.signIn, equals('Sign in'));
      expect(am.signIn, equals('ግባ'));

      expect(en.uploadDesign, equals('Upload Design'));
      expect(am.uploadDesign, equals('ዲዛይን ጫን'));

      expect(en.deleteDesign, equals('Delete Design'));
      expect(am.deleteDesign, equals('ዲዛይን ሰርዝ'));

      expect(en.email, equals('Email address'));
      expect(am.email, equals('ኢሜይል'));
    });

    testWidgets('LanguageToggle renders and switches language', (tester) async {
      final provider = LocaleProvider();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            appBar: AppBar(
              actions: [
                LanguageToggle(provider: provider),
              ],
            ),
          ),
        ),
      );

      // Initially displays EN | አማ
      expect(find.text('EN | አማ'), findsOneWidget);

      // Tap toggle to open bottom sheet
      await tester.tap(find.text('EN | አማ'));
      await tester.pumpAndSettle();

      // Verify bottom sheet shows language options
      expect(find.text('English'), findsOneWidget);
      expect(find.text('አማርኛ (Amharic)'), findsOneWidget);

      // Select Amharic
      await tester.tap(find.text('አማርኛ (Amharic)'));
      await tester.pumpAndSettle();

      expect(provider.locale.languageCode, equals('am'));
    });

    testWidgets('TailorApp switches language dynamically', (tester) async {
      final provider = LocaleProvider();

      await tester.pumpWidget(TailorApp(localeProvider: provider));
      await tester.pumpAndSettle();

      // Initial English screen
      expect(find.text('Tailor sign in'), findsOneWidget);
      expect(find.text('Sign in to manage your design catalog.'), findsOneWidget);

      // Tap language toggle
      await tester.tap(find.text('EN | አማ'));
      await tester.pumpAndSettle();

      // Pick Amharic
      await tester.tap(find.text('አማርኛ (Amharic)'));
      await tester.pumpAndSettle();

      // UI updates to Amharic
      expect(find.text('የጥለት ባለሙያ መግቢያ'), findsOneWidget);
      expect(find.text('ዲዛይን ካታሎጅዎን ለማስተዳደር ይግቡ።'), findsOneWidget);
    });
  });
}
