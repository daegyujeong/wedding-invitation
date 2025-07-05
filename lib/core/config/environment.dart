// Environment configuration for API keys
// Copy this file to .env and add your actual API keys
// NEVER commit .env file to version control

class Environment {
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'YOUR_GOOGLE_MAPS_API_KEY',
  );

  static const String naverMapsClientId = String.fromEnvironment(
    'NAVER_MAPS_CLIENT_ID',
    defaultValue: 'YOUR_NAVER_CLIENT_ID',
  );

  static const String kakaoMapsJsKey = String.fromEnvironment(
    'KAKAO_MAPS_JS_KEY',
    defaultValue: 'YOUR_KAKAO_MAP_KEY',
  );

  // Other API keys
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );
}
