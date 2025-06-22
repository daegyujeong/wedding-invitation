import 'package:wedding_invitation/data/models/venue_model.dart';
import 'package:flutter/material.dart';

class MultiLanguageText {
  final Map<String, String> translations;
  final String defaultLanguage;

  MultiLanguageText({
    required this.translations,
    this.defaultLanguage = 'en',
  });

  String getText(String language) {
    return translations[language] ??
        translations[defaultLanguage] ??
        translations.values.first;
  }

  factory MultiLanguageText.fromJson(Map<String, dynamic> json) {
    return MultiLanguageText(
      translations: Map<String, String>.from(json['translations']),
      defaultLanguage: json['default_language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'translations': translations,
      'default_language': defaultLanguage,
    };
  }
}

class InvitationModel {
  final String id;
  final MultiLanguageText title;
  final MultiLanguageText groomName;
  final MultiLanguageText brideName;
  final MultiLanguageText greetingMessage;
  final List<VenueModel> venues;
  final String backgroundImage;
  final String template;
  final List<String> supportedLanguages;

  InvitationModel({
    required this.id,
    required this.title,
    required this.groomName,
    required this.brideName,
    required this.greetingMessage,
    required this.venues,
    required this.backgroundImage,
    required this.template,
    required this.supportedLanguages,
  });

  // JSON 변환 메서드
  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'],
      title: MultiLanguageText.fromJson(json['title']),
      groomName: MultiLanguageText.fromJson(json['groom_name']),
      brideName: MultiLanguageText.fromJson(json['bride_name']),
      greetingMessage: MultiLanguageText.fromJson(json['greeting_message']),
      venues:
          (json['venues'] as List).map((v) => VenueModel.fromJson(v)).toList(),
      backgroundImage: json['background_image'],
      template: json['template'],
      supportedLanguages: List<String>.from(json['supported_languages']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title.toJson(),
      'groom_name': groomName.toJson(),
      'bride_name': brideName.toJson(),
      'greeting_message': greetingMessage.toJson(),
      'venues': venues.map((v) => v.toJson()).toList(),
      'background_image': backgroundImage,
      'template': template,
      'supported_languages': supportedLanguages,
    };
  }
}

// 언어 변경 기능을 위한 Provider
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ko');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
