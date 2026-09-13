import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the active locale and persists it across app restarts.
/// Supported: en (English) and am (Amharic).
class LocaleProvider extends ChangeNotifier {
  LocaleProvider([this._prefs, Locale? initialLocale]) : _currentLocale = initialLocale;

  final SharedPreferences? _prefs;
  Locale? _currentLocale;
  static const _key = 'app_locale';

  Locale get locale {
    if (_currentLocale != null) return _currentLocale!;
    final saved = _prefs?.getString(_key);
    if (saved == 'am') return const Locale('am');
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    _currentLocale = locale;
    await _prefs?.setString(_key, locale.languageCode);
    notifyListeners();
  }

  static Future<LocaleProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocaleProvider(prefs);
  }
}

