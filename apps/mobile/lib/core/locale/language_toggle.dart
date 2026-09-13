import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'locale_provider.dart';

/// A small pill/button that shows "EN | አማ" in the AppBar.
/// Tapping it opens a bottom sheet to pick the language.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({required this.provider, super.key});

  final LocaleProvider provider;

  @override
  Widget build(BuildContext context) {
    final isAmharic = provider.locale.languageCode == 'am';
    return TextButton(
      onPressed: () => _showPicker(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        foregroundColor: Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white24),
        ),
      ),
      child: Text(
        isAmharic ? 'አማ | EN' : 'EN | አማ',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.language,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _LanguageTile(
                  flag: '🇬🇧',
                  label: 'English',
                  locale: const Locale('en'),
                  current: provider.locale,
                  onTap: () {
                    provider.setLocale(const Locale('en'));
                    Navigator.pop(ctx);
                  },
                ),
                _LanguageTile(
                  flag: '🇪🇹',
                  label: 'አማርኛ (Amharic)',
                  locale: const Locale('am'),
                  current: provider.locale,
                  onTap: () {
                    provider.setLocale(const Locale('am'));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.locale,
    required this.current,
    required this.onTap,
  });

  final String flag;
  final String label;
  final Locale locale;
  final Locale current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = locale.languageCode == current.languageCode;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 22)),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.brand : Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.brand, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
