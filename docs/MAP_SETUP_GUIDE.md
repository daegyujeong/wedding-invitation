# Map Widget Setup Guide

This guide explains how to configure Google Maps, Naver Maps, and Kakao Maps for the Flutter Wedding Invitation app.

## Prerequisites

Before using the map widgets, you need to obtain API keys from each map provider.

## 1. Google Maps Setup

### Android Configuration

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add the following inside the `<application>` tag:

```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

### iOS Configuration

1. Open `ios/Runner/AppDelegate.swift`
2. Add the following import and configuration:

```swift
import GoogleMaps

// In application(_:didFinishLaunchingWithOptions:)
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### Getting Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing one
3. Enable "Maps SDK for Android" and "Maps SDK for iOS"
4. Create credentials (API Key)
5. (Optional) Restrict the API key to your app

## 2. Naver Maps Setup

### Android Configuration

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add the following inside the `<application>` tag:

```xml
<meta-data android:name="com.naver.maps.map.CLIENT_ID"
           android:value="YOUR_NAVER_CLIENT_ID"/>
```

### iOS Configuration

1. Open `ios/Runner/Info.plist`
2. Add the following:

```xml
<key>NMFClientId</key>
<string>YOUR_NAVER_CLIENT_ID</string>
```

### Getting Naver Maps Client ID

1. Go to [Naver Developers](https://developers.naver.com)
2. Create an application
3. Add "Maps" service
4. Get your Client ID
5. Register your app's bundle ID (iOS) and package name (Android)

## 3. Kakao Maps Setup

### Getting Kakao Maps JavaScript Key

1. Go to [Kakao Developers](https://developers.kakao.com)
2. Create an application
3. Add platform (Web platform for WebView usage)
4. Get your JavaScript key
5. Add your domain to allowed domains

### Configuration in Code

Replace the key in `kakao_map_widget.dart`:

```dart
const String kakaoMapKey = 'YOUR_KAKAO_MAP_KEY'; // Replace with actual key
```

## 4. Platform-specific Setup

### Android

Add internet permission in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS

Add location permission in `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location for showing wedding venue on map.</string>
```

## 5. Usage in Code

```dart
// In your editor widget
MapWidget(
  latitude: 37.5665,
  longitude: 126.9780,
  venue: 'Wedding Hall Name',
  mapProvider: 'google', // or 'naver', 'kakao'
  showControls: true,
  showDirections: true,
)
```

## 6. Testing

1. Run `flutter pub get` to install dependencies
2. Run the app on Android/iOS device or emulator
3. Test each map provider by switching between them
4. Test navigation buttons to ensure they open respective map apps

## Troubleshooting

### Google Maps not showing
- Check if API key is correctly set
- Ensure Maps SDK is enabled in Google Cloud Console
- Check if billing is enabled for your project

### Naver Maps not showing
- Verify Client ID is correct
- Check if your app's bundle ID/package name is registered
- Ensure you're using the correct platform (Android/iOS) settings

### Kakao Maps not showing
- Verify JavaScript key is correct
- Check if your domain is added to allowed domains
- Ensure WebView is properly configured

## Security Notes

- Never commit API keys to version control
- Use environment variables or secure storage for API keys
- Consider using different keys for development and production
- Implement key restrictions based on your app's bundle ID/package name
