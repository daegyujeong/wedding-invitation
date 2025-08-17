// lib/data/repositories/language_repository_impl.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language_model.dart';
import 'interfaces/language_repository.dart';

class LanguageRepositoryImpl implements ILanguageRepository {
  static const String _currentLanguageKey = 'current_language';
  static const String _languagePreferencesKey = 'language_preferences';
  static const String _customLanguagesKey = 'custom_languages';
  static const String _translationsKey = 'translations';

  @override
  Future<List<LanguageModel>> getSupportedLanguages() async {
    try {
      // Get default languages
      final languages = List<LanguageModel>.from(LanguageModel.supportedLanguages);
      
      // Add custom languages
      final customLanguages = await _getCustomLanguages();
      languages.addAll(customLanguages);
      
      return languages;
    } catch (e) {
      print('Error getting supported languages: $e');
      return LanguageModel.supportedLanguages;
    }
  }

  @override
  Future<LanguageModel?> getCurrentLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_currentLanguageKey);
      
      if (languageCode == null) {
        return getDefaultLanguage();
      }
      
      return await getLanguageByCode(languageCode);
    } catch (e) {
      print('Error getting current language: $e');
      return getDefaultLanguage();
    }
  }

  @override
  Future<bool> setCurrentLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_currentLanguageKey, languageCode);
    } catch (e) {
      print('Error setting current language: $e');
      return false;
    }
  }

  @override
  Future<bool> isLanguageSupported(String languageCode) async {
    final languages = await getSupportedLanguages();
    return languages.any((lang) => lang.code == languageCode);
  }

  @override
  Future<LanguageModel?> getLanguageByCode(String languageCode) async {
    final languages = await getSupportedLanguages();
    try {
      return languages.firstWhere((lang) => lang.code == languageCode);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<LanguageModel> getDefaultLanguage() async {
    return LanguageModel.supportedLanguages.first; // Korean is first
  }

  @override
  Future<List<String>> getAvailableLanguageCodes() async {
    final languages = await getSupportedLanguages();
    return languages.map((lang) => lang.code).toList();
  }

  @override
  Future<bool> addCustomLanguage(LanguageModel language) async {
    try {
      final customLanguages = await _getCustomLanguages();
      
      // Check if language already exists
      if (customLanguages.any((lang) => lang.code == language.code)) {
        return false;
      }
      
      customLanguages.add(language);
      return await _saveCustomLanguages(customLanguages);
    } catch (e) {
      print('Error adding custom language: $e');
      return false;
    }
  }

  @override
  Future<bool> removeLanguageSupport(String languageCode) async {
    try {
      // Don't allow removing default languages
      if (LanguageModel.supportedLanguages.any((lang) => lang.code == languageCode)) {
        return false;
      }
      
      final customLanguages = await _getCustomLanguages();
      customLanguages.removeWhere((lang) => lang.code == languageCode);
      
      return await _saveCustomLanguages(customLanguages);
    } catch (e) {
      print('Error removing language support: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getLanguagePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = prefs.getString(_languagePreferencesKey);
      
      if (preferencesJson == null) {
        return {
          'fallbackLanguage': 'ko',
          'autoDetect': true,
          'showLanguageSelector': true,
        };
      }
      
      return json.decode(preferencesJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting language preferences: $e');
      return {};
    }
  }

  @override
  Future<bool> saveLanguagePreferences(Map<String, dynamic> preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preferencesJson = json.encode(preferences);
      return await prefs.setString(_languagePreferencesKey, preferencesJson);
    } catch (e) {
      print('Error saving language preferences: $e');
      return false;
    }
  }

  @override
  Future<String?> getLocalizedText(String key, String languageCode) async {
    try {
      final translations = await _getTranslations(languageCode);
      return translations[key];
    } catch (e) {
      print('Error getting localized text: $e');
      return null;
    }
  }

  @override
  Future<bool> setLocalizedText(String key, String languageCode, String text) async {
    try {
      final translations = await _getTranslations(languageCode);
      translations[key] = text;
      return await _saveTranslations(languageCode, translations);
    } catch (e) {
      print('Error setting localized text: $e');
      return false;
    }
  }

  @override
  Future<Map<String, String>> getAllTranslations(String key) async {
    try {
      final languages = await getAvailableLanguageCodes();
      final translations = <String, String>{};
      
      for (final languageCode in languages) {
        final text = await getLocalizedText(key, languageCode);
        if (text != null) {
          translations[languageCode] = text;
        }
      }
      
      return translations;
    } catch (e) {
      print('Error getting all translations: $e');
      return {};
    }
  }

  @override
  Future<bool> importTranslations(String languageCode, Map<String, String> translations) async {
    try {
      final existingTranslations = await _getTranslations(languageCode);
      existingTranslations.addAll(translations);
      return await _saveTranslations(languageCode, existingTranslations);
    } catch (e) {
      print('Error importing translations: $e');
      return false;
    }
  }

  @override
  Future<Map<String, String>?> exportTranslations(String languageCode) async {
    try {
      return await _getTranslations(languageCode);
    } catch (e) {
      print('Error exporting translations: $e');
      return null;
    }
  }

  // Private helper methods
  Future<List<LanguageModel>> _getCustomLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customLanguagesJson = prefs.getString(_customLanguagesKey);
      
      if (customLanguagesJson == null) return [];
      
      final List<dynamic> languagesList = json.decode(customLanguagesJson);
      return languagesList.map((json) => LanguageModel(
        code: json['code'],
        name: json['name'],
        localName: json['localName'],
      )).toList();
    } catch (e) {
      print('Error getting custom languages: $e');
      return [];
    }
  }

  Future<bool> _saveCustomLanguages(List<LanguageModel> languages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languagesJson = json.encode(languages.map((lang) => {
        'code': lang.code,
        'name': lang.name,
        'localName': lang.localName,
      }).toList());
      
      return await prefs.setString(_customLanguagesKey, languagesJson);
    } catch (e) {
      print('Error saving custom languages: $e');
      return false;
    }
  }

  Future<Map<String, String>> _getTranslations(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final translationsJson = prefs.getString('${_translationsKey}_$languageCode');
      
      if (translationsJson == null) return {};
      
      final Map<String, dynamic> translations = json.decode(translationsJson);
      return translations.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print('Error getting translations: $e');
      return {};
    }
  }

  Future<bool> _saveTranslations(String languageCode, Map<String, String> translations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final translationsJson = json.encode(translations);
      return await prefs.setString('${_translationsKey}_$languageCode', translationsJson);
    } catch (e) {
      print('Error saving translations: $e');
      return false;
    }
  }
}