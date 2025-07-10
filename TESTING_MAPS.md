# Testing Map Widgets with Google API Key Only

## 🚀 Quick Setup

### 1. Add your Google API Key

Add this to your app configuration (typically in a `.env` file or directly in `environment.dart`):

```bash
# .env file (recommended)
GOOGLE_MAPS_API_KEY=your_actual_google_api_key_here
```

Or update `lib/core/config/environment.dart`:
```dart
static const String googleMapsApiKey = 'your_actual_google_api_key_here';
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Test the Map Widgets

Add this route to your app router to test the functionality:

```dart
// In your main.dart or router
import 'package:wedding_invitation/features/location/presentation/screens/map_test_screen.dart';

// Add route
'/map-test': (context, state) => const MapTestScreen(),
```

## 🧪 Testing Features

### **With Google API Key:**
- ✅ **Google Maps**: Full functionality with real search
- ✅ **Kakao Maps**: Map display + Google search fallback  
- ✅ **Naver Maps**: Map display + Google search fallback
- ✅ **Location Search**: Google Places API search
- ✅ **Save Locations**: Persistent local storage
- ✅ **Provider Switching**: All three map providers

### **Fallback Behavior:**
When Kakao/Naver API keys aren't configured:
- Map display still works (using webview/SDK)
- Search falls back to Google Places API
- Results are labeled as `kakao-fallback` or `naver-fallback`
- All other functionality remains the same

## 🎯 Test Scenarios

### 1. **Basic Map Display**
```dart
MultiMapWidget(
  latitude: 37.5665,
  longitude: 126.9780,
  venue: 'Seoul City Hall',
  provider: MapProvider.google, // or kakao/naver
  showControls: true,
)
```

### 2. **Location Search**
```dart
MultiMapWidget(
  // ... same as above
  showSearch: true,
  onLocationSelected: (result) {
    print('Selected: ${result.name}');
  },
)
```

### 3. **Save Functionality**
```dart
MultiMapWidget(
  // ... same as above
  showSearch: true,
  onLocationSaved: (venue) {
    print('Saved: ${venue.name}');
  },
)
```

### 4. **Individual Map Screens**
```dart
// Google only
Navigator.push(context, MaterialPageRoute(
  builder: (_) => GoogleMapScreen(),
));

// Kakao (with Google search fallback)
Navigator.push(context, MaterialPageRoute(
  builder: (_) => KakaoMapScreen(),
));

// Naver (with Google search fallback)
Navigator.push(context, MaterialPageRoute(
  builder: (_) => NaverMapScreen(),
));

// Combined (all providers)
Navigator.push(context, MaterialPageRoute(
  builder: (_) => CombinedMapScreen(),
));
```

## 🔧 Configuration

### Google Maps API Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable these APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS** 
   - **Places API** (for search)
   - **Geocoding API** (for search)
3. Create API key and add restrictions
4. Add to your app configuration

### Optional: Add Other Providers Later
When you get other API keys, just update `environment.dart`:

```dart
// For Kakao Maps search
static const String kakaoMapsApiKey = 'your_kakao_api_key';

// For Naver Maps search  
static const String naverClientId = 'your_naver_client_id';
static const String naverClientSecret = 'your_naver_client_secret';
```

## 🎨 UI Features

### MapTestScreen includes:
- **Provider switching chips** (Google/Kakao/Naver)
- **Location search bar** with autocomplete
- **Save/load locations** with persistent storage
- **Quick test buttons** (Seoul/Busan/Jeju)
- **Saved locations sheet** with delete functionality

### Search Results show:
- Location name and address
- Provider badge (Google/Kakao-fallback/Naver-fallback)
- Tap to select and update map

## 📱 Example Usage

```dart
class MyMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map Test')),
      body: MultiMapWidget(
        latitude: 37.5665,
        longitude: 126.9780,
        venue: 'Seoul',
        provider: MapProvider.google,
        showSearch: true,
        showControls: true,
        showDirections: true,
        height: 400,
        onLocationSelected: (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected: ${result.name}')),
          );
        },
        onLocationSaved: (venue) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved: ${venue.name}')),
          );
        },
      ),
    );
  }
}
```

## 🐛 Troubleshooting

### Common Issues:
1. **"API key not valid"**: Check Google Cloud Console API restrictions
2. **"Search not working"**: Ensure Places API is enabled
3. **"Map not loading"**: Check platform-specific setup (iOS/Android)
4. **"Kakao/Naver search fails silently"**: Expected behavior, using Google fallback

### Debug Tips:
- Check console for fallback messages
- Verify API key is properly set
- Test with simple locations first (Seoul, Tokyo, etc.)
- Use MapTestScreen for comprehensive testing

## ✨ Next Steps

Once you have all API keys:
1. Update `environment.dart` with real keys
2. Remove fallback behavior if desired
3. Test provider-specific search results
4. Customize UI for your wedding app needs

The system is designed to work progressively - start with Google, add others later!