import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/bootstrap/bootstrap_screen.dart';

class TailorApp extends StatelessWidget {
  const TailorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tailor Catalog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const BootstrapScreen(),
    );
  }
}
