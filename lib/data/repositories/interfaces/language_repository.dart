// lib/data/repositories/interfaces/language_repository.dart
import '../../models/language_model.dart';

/// Abstract repository interface for language and localization operations
abstract class ILanguageRepository {
  /// Get all supported languages
  Future<List<LanguageModel>> getSupportedLanguages();

  /// Get current language setting
  Future<LanguageModel?> getCurrentLanguage();

  /// Set current language
  Future<bool> setCurrentLanguage(String languageCode);

  /// Check if language is supported
  Future<bool> isLanguageSupported(String languageCode);

  /// Get language by code
  Future<LanguageModel?> getLanguageByCode(String languageCode);

  /// Get default language
  Future<LanguageModel> getDefaultLanguage();

  /// Get available language codes
  Future<List<String>> getAvailableLanguageCodes();

  /// Add custom language support
  Future<bool> addCustomLanguage(LanguageModel language);

  /// Remove language support
  Future<bool> removeLanguageSupport(String languageCode);

  /// Get language preferences
  Future<Map<String, dynamic>> getLanguagePreferences();

  /// Save language preferences
  Future<bool> saveLanguagePreferences(Map<String, dynamic> preferences);

  /// Get localized text for key
  Future<String?> getLocalizedText(String key, String languageCode);

  /// Set localized text
  Future<bool> setLocalizedText(String key, String languageCode, String text);

  /// Get all translations for a key
  Future<Map<String, String>> getAllTranslations(String key);

  /// Import translation file
  Future<bool> importTranslations(String languageCode, Map<String, String> translations);

  /// Export translation file
  Future<Map<String, String>?> exportTranslations(String languageCode);
}