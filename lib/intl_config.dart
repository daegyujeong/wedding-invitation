import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class IntlConfig {
  static Future<void> initialize() async {
    // Initialize Korean locale
    await initializeDateFormatting('ko_KR', null);
    
    // Set default locale to Korean
    Intl.defaultLocale = 'ko_KR';
  }
}
