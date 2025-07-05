# API Keys Setup Guide

This guide explains how to properly configure API keys for Google Maps, Naver Maps, and Kakao Maps in your Flutter wedding invitation app.

## 🚨 Important Security Note
**NEVER commit API keys to version control!** The `.env` file is already included in `.gitignore` to prevent accidental commits.

## 📋 Step-by-Step Setup

### 1. Google Maps API Key

#### Get Your API Key:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create or select a project
3. Enable **Google Maps JavaScript API** and **Google Maps SDK for iOS/Android**
4. Create credentials → API Key
5. (Optional) Restrict API key to your domains for security

#### Configure for Web:
Edit `web/index.html` and replace `YOUR_ACTUAL_API_KEY`:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBvOkBwgGlbUi...&libraries=geometry"></script>
```

#### Configure for Native Apps:
Create `.env` file in project root:
```bash
GOOGLE_MAPS_API_KEY=your_actual_google_maps_api_key_here
```

### 2. Naver Maps API Key

#### Get Your API Key:
1. Go to [Naver Cloud Platform](https://www.ncloud.com/)
2. Create application
3. Enable Maps API
4. Get Client ID

#### Configure:
Add to your `.env` file:
```bash
NAVER_MAPS_CLIENT_ID=your_naver_client_id_here
```

### 3. Kakao Maps API Key

#### Get Your API Key:
1. Go to [Kakao Developers](https://developers.kakao.com/)
2. Create application
3. Enable Maps API
4. Get JavaScript Key

#### Configure:
Add to your `.env` file:
```bash
KAKAO_MAPS_JS_KEY=your_kakao_maps_key_here
```

### 4. Complete .env File Template

Create `.env` file in your project root:
```bash
# Google Maps API Key
GOOGLE_MAPS_API_KEY=your_actual_google_maps_api_key_here

# Naver Maps API Key
NAVER_MAPS_CLIENT_ID=your_naver_client_id_here

# Kakao Maps API Key  
KAKAO_MAPS_JS_KEY=your_kakao_maps_key_here

# Supabase Configuration (if using)
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

## 🚀 Running the App

### For Web Development:
```bash
# Simple run (make sure web/index.html has the API key)
flutter run -d chrome

# Or with environment variables
flutter run -d chrome --dart-define=GOOGLE_MAPS_API_KEY=your_key_here
```

### For iOS/Android:
```bash
# Environment variables are automatically loaded from .env
flutter run -d ios
flutter run -d android
```

### For Production Build:
```bash
# Web build with environment variables
flutter build web --dart-define=GOOGLE_MAPS_API_KEY=your_key_here

# iOS/Android builds (uses .env automatically)
flutter build ios --release
flutter build android --release
```

## 🔧 Troubleshooting

### "Google Maps JavaScript API warning: InvalidKey"
- Check that `web/index.html` has your real API key (not placeholder)
- Verify the API key is valid and Maps JavaScript API is enabled
- Check domain restrictions in Google Cloud Console

### "Naver Maps not loading"
- Verify Client ID is correct
- Check that Maps API is enabled in Naver Cloud Platform
- Ensure `.env` file is in project root

### "Kakao Maps not working"
- Verify JavaScript key is correct
- Check that Maps API is enabled in Kakao Developers
- Ensure domain is registered in Kakao app settings

## 📱 Platform-Specific Notes

### Web
- API key must be in `web/index.html` (static HTML)
- Consider domain restrictions for security
- Test thoroughly on different browsers

### iOS
- API key loaded from Environment class
- iOS deployment target must be 14.0+
- Test on physical device for location features

### Android
- API key loaded from Environment class
- Location permissions required
- Test on different Android versions

## 🔐 Security Best Practices

1. **Never commit API keys** - Always use environment variables
2. **Restrict API keys** - Limit to specific domains/apps
3. **Monitor usage** - Check API quotas and billing
4. **Rotate keys** - Regularly update API keys
5. **Use different keys** - Separate keys for dev/staging/prod

## 📞 Support

If you encounter issues:
1. Check this guide first
2. Verify API keys are valid
3. Test with a simple map implementation
4. Check provider documentation:
   - [Google Maps](https://developers.google.com/maps/documentation)
   - [Naver Maps](https://navermaps.github.io/android-map-sdk/guide-ko/)
   - [Kakao Maps](https://apis.map.kakao.com/) 