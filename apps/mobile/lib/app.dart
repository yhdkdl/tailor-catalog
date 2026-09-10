import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_repository.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/profile_gate.dart';
import 'features/designs/dashboard_screen.dart';

class TailorApp extends StatelessWidget {
  const TailorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tailor Catalog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // Register the route observer so DashboardScreen can detect when it
      // becomes active again after any sub-screen (QR, upload, edit) is popped.
      navigatorObservers: [dashboardRouteObserver],
      home: AppConfig.hasSupabase
          ? ProfileGate(repository: SupabaseAuthRepository(Supabase.instance.client))
          : const AuthScreen(repository: UnconfiguredAuthRepository()),
    );
  }
}
