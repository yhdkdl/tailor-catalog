import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  if (AppConfig.hasSupabase) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  if (AppConfig.hasSentry) {
    await SentryFlutter.init(
      (options) {
        options.dsn = AppConfig.sentryDsn;
        // Capture 10 % of performance traces in production.
        options.tracesSampleRate = 0.1;
        // Enable Flutter-specific integrations: navigation, widget error reporting.
        options.enableAutoSessionTracking = true;
        options.enableAutoNativeBreadcrumbs = true;
      },
      appRunner: () => runApp(const TailorApp()),
    );
  } else {
    // No Sentry DSN configured — run normally (dev / local builds).
    runApp(const TailorApp());
  }
}

