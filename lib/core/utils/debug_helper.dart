import 'dart:convert';

class DebugHelper {
  /// Safely decode JSON with detailed error reporting
  static dynamic safeJsonDecode(String jsonString, {String? context}) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      print('=== JSON DECODE ERROR ===');
      print('Context: ${context ?? 'Unknown'}');
      print('Error: $e');
      print('JSON String (first 500 chars): ${jsonString.length > 500 ? jsonString.substring(0, 500) + "..." : jsonString}');
      print('JSON String length: ${jsonString.length}');
      print('JSON String type: ${jsonString.runtimeType}');
      print('=========================');
      rethrow;
    }
  }

  /// Validate JSON structure before parsing
  static bool isValidJson(String jsonString) {
    try {
      json.decode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Debug API response
  static void debugApiResponse(dynamic response, String apiName) {
    print('=== $apiName API RESPONSE DEBUG ===');
    print('Response type: ${response.runtimeType}');
    if (response is Map) {
      print('Response keys: ${response.keys.toList()}');
      print('Response: $response');
    } else {
      print('Response: $response');
    }
    print('=====================================');
  }

  /// Debug widget data parsing
  static void debugWidgetData(Map<String, dynamic> data, String widgetType) {
    print('=== $widgetType WIDGET DATA DEBUG ===');
    print('Data keys: ${data.keys.toList()}');
    print('Data: $data');
    print('======================================');
  }
}