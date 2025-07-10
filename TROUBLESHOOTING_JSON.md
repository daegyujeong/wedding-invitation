# Troubleshooting "Unexpected JSON Input" Error

## 🔍 **How to Debug the JSON Error**

### **Step 1: Check Browser Console**
1. Open browser DevTools (F12)
2. Go to Console tab
3. Look for detailed error messages that show:
   - Which JSON parsing operation failed
   - The actual JSON content that caused the error
   - Stack trace showing where the error occurred

### **Step 2: Common Sources of JSON Errors**

#### **A. Google Maps API Issues**
**Symptoms:** Error when searching for locations
**Check:** 
- Is your Google API key valid?
- Are the required APIs enabled? (Places API, Geocoding API)
- Network request in DevTools shows the actual response

**Quick Test:**
```bash
# Test your API key directly
curl "https://maps.googleapis.com/maps/api/place/textsearch/json?query=seoul&key=YOUR_API_KEY"
```

#### **B. Saved Data Corruption**
**Symptoms:** Error when app starts or loading saved locations
**Fix:** Clear saved data:
```dart
// Add this to your debug console or create a test button
SharedPreferences.getInstance().then((prefs) {
  prefs.remove('saved_locations');
  prefs.remove('recent_searches');
});
```

#### **C. Widget Data Parsing**
**Symptoms:** Error when adding/editing map widgets
**Check:** Look for these console messages:
- "MapWidget.fromJson: Unexpected data type"
- "Error parsing MapWidget"

### **Step 3: Enable Debug Logging**

Add this to your main.dart to see detailed JSON operations:

```dart
void main() {
  // Enable debug logging
  if (kDebugMode) {
    print('Debug mode enabled - detailed JSON logging active');
  }
  
  runApp(MyApp());
}
```

### **Step 4: Test Individual Components**

#### **Test Location Search:**
```dart
// Add this to a test button
final service = LocationSearchService();
service.searchGoogle('seoul').then((results) {
  print('Search results: $results');
}).catchError((e) {
  print('Search error: $e');
});
```

#### **Test Saved Locations:**
```dart
// Add this to a test button
final repo = SavedLocationsRepository();
repo.getSavedLocations().then((locations) {
  print('Saved locations: $locations');
}).catchError((e) {
  print('Load error: $e');
});
```

### **Step 5: Reset Everything (Nuclear Option)**

If all else fails, reset all map-related data:

```dart
Future<void> resetMapData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('saved_locations');
  await prefs.remove('recent_searches');
  print('All map data cleared');
}
```

## 🎯 **Specific Error Patterns**

### **"Unexpected token" in JSON**
- **Cause:** API returned HTML error page instead of JSON
- **Fix:** Check API key and network connectivity
- **Debug:** Look at Network tab in DevTools

### **"type 'String' is not a subtype of type 'Map'"**
- **Cause:** Trying to parse string as object
- **Fix:** Enhanced parsing logic now handles this
- **Debug:** Look for "Unexpected data type" messages

### **"Invalid argument(s): null"**
- **Cause:** Required fields missing from JSON
- **Fix:** Enhanced null safety now handles this
- **Debug:** Check which fields are null

## 🛠️ **Quick Fixes Applied**

The enhanced error handling now includes:

1. **API Response Validation:** Checks content-type before parsing
2. **Defensive Parsing:** Safely handles missing/null values
3. **Graceful Degradation:** Skips corrupted data instead of crashing
4. **Detailed Logging:** Shows exactly what went wrong
5. **Fallback Behavior:** Uses Google search when other APIs fail

## 📱 **Testing Strategy**

1. **Start Simple:** Use MapTestScreen with just Google API key
2. **Test Network:** Check if Google Places API works
3. **Test Storage:** Save and load a simple location
4. **Test Integration:** Add map widget to editor
5. **Debug Logs:** Check console for any error messages

## 🚨 **Emergency Reset**

If the app is completely broken, add this button temporarily:

```dart
ElevatedButton(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears ALL app data
    print('All app data cleared - restart app');
  },
  child: Text('EMERGENCY RESET'),
)
```

The enhanced error handling should prevent most JSON errors, but these steps will help identify any remaining issues.