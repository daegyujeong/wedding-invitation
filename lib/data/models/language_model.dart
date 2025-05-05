class LanguageModel {
  final String code;
  final String name;
  final String localName;

  LanguageModel({
    required this.code,
    required this.name,
    required this.localName,
  });

  static List<LanguageModel> supportedLanguages = [
    LanguageModel(code: 'ko', name: 'Korean', localName: '한국어'),
    LanguageModel(code: 'en', name: 'English', localName: 'English'),
    LanguageModel(code: 'zh', name: 'Chinese', localName: '中文'),
    LanguageModel(code: 'ms', name: 'Malay', localName: 'Bahasa Melayu'),
    LanguageModel(code: 'ta', name: 'Tamil', localName: 'தமிழ்'),
  ];
}
