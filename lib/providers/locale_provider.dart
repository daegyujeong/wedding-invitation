import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  
  Locale _locale = const Locale('en'); // Default to English
  
  Locale get locale => _locale;
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ko'), // Korean
    Locale('zh'), // Chinese
    Locale('ms'), // Malay
  ];
  
  // Language names for display
  static const Map<String, String> languageNames = {
    'en': 'English',
    'ko': '한국어',
    'zh': '中文',
    'ms': 'Bahasa Melayu',
  };
  
  // Country flags (emoji)
  static const Map<String, String> countryFlags = {
    'en': '🇬🇧',
    'ko': '🇰🇷',
    'zh': '🇨🇳',
    'ms': '🇲🇾',
  };
  
  LocaleProvider() {
    _loadLocale();
  }
  
  // Load saved locale or detect from system
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    } else {
      // Use system locale if available and supported
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final supportedLanguageCodes = supportedLocales.map((l) => l.languageCode).toList();
      
      if (supportedLanguageCodes.contains(systemLocale.languageCode)) {
        _locale = Locale(systemLocale.languageCode);
      } else {
        // Default to English if system locale is not supported
        _locale = const Locale('en');
      }
    }
    
    notifyListeners();
  }
  
  // Change locale
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    _locale = locale;
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    
    notifyListeners();
  }
  
  // Get display name for a locale
  String getDisplayName(Locale locale) {
    return languageNames[locale.languageCode] ?? locale.languageCode;
  }
  
  // Get flag for a locale
  String getFlag(Locale locale) {
    return countryFlags[locale.languageCode] ?? '🏳️';
  }
}