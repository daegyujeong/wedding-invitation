// Environment configuration for API keys
// Copy this file to .env and add your actual API keys
// NEVER commit .env file to version control

class Environment {
  // For development, we'll use the provided API key
  // In production, replace with your own API key
  static const String _defaultGoogleMapsApiKey =
      'AIzaSyDYtu2Bu-VPXsA3z5sWaENXOqa-B-m8vxM';

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: _defaultGoogleMapsApiKey,
  );

  static const String naverMapsClientId = String.fromEnvironment(
    'NAVER_MAPS_CLIENT_ID',
    defaultValue: '',
  );

  static const String naverClientId = String.fromEnvironment(
    'NAVER_CLIENT_ID',
    defaultValue: '',
  );

  static const String naverClientSecret = String.fromEnvironment(
    'NAVER_CLIENT_SECRET',
    defaultValue: '',
  );

  static const String kakaoMapsJsKey = String.fromEnvironment(
    'KAKAO_MAPS_JS_KEY',
    defaultValue: '',
  );

  static const String kakaoMapsApiKey = String.fromEnvironment(
    'KAKAO_MAPS_API_KEY',
    defaultValue: '',
  );

  // Other API keys
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Helper methods to check if API keys are configured
  static bool get isGoogleMapsConfigured =>
      googleMapsApiKey.isNotEmpty &&
      googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY';
  static bool get isNaverMapsConfigured =>
      naverMapsClientId.isNotEmpty &&
      naverMapsClientId != 'YOUR_NAVER_CLIENT_ID';
  static bool get isKakaoMapsConfigured =>
      kakaoMapsJsKey.isNotEmpty && kakaoMapsJsKey != 'YOUR_KAKAO_MAP_KEY';
}
