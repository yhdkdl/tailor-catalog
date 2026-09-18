import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/l10n/app_localizations.dart';
import 'core/locale/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_repository.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/profile_gate.dart';
import 'features/designs/dashboard_screen.dart';

class TailorApp extends StatelessWidget {
  const TailorApp({this.localeProvider, super.key});

  final LocaleProvider? localeProvider;
  static final LocaleProvider _defaultLocaleProvider = LocaleProvider();

  @override
  Widget build(BuildContext context) {
    final provider = localeProvider ?? _defaultLocaleProvider;
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return MaterialApp(
          title: 'Tailor Catalog',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          locale: provider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          navigatorObservers: [dashboardRouteObserver],
          home: AppConfig.hasSupabase
              ? ProfileGate(
                  repository:
                      SupabaseAuthRepository(Supabase.instance.client),
                  localeProvider: provider,
                )
              : AuthScreen(
                  repository: const UnconfiguredAuthRepository(),
                  localeProvider: provider,
                ),
        );
      },
    );
  }
}
