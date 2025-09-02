# Naver Maps Integration Setup

## ✅ Implementation Complete!

The Naver Maps integration is now ready. You just need to add your API credentials.

## 🔑 Getting Your Naver Maps API Key

### 1. Create Naver Cloud Platform Account
1. Go to [Naver Cloud Platform](https://www.ncloud.com/)
2. Sign up (Korean phone number required)
3. Log in to the console

### 2. Create Application
1. Navigate to **AI·NAVER API** → **Application**
2. Click **Application 등록** (Register Application)
3. Fill in:
   - Application name: `Wedding Invitation`
   - Service selection: Check **Maps** (지도)
   - Optional: Check **Search** (검색) for location search

### 3. Configure Web Service URL
Add these URLs in the **Web 서비스 URL** section:
```
http://localhost:*
https://localhost:*
https://daegyu.dev
https://*.vercel.app
```

### 4. Get Your Client ID
After creation, you'll see:
- **Client ID**: `abc123...` (copy this)
- **Client Secret**: `xyz789...` (not needed for web)

## 🔧 Configuration Steps

### 1. Update index.html
Replace `YOUR_NAVER_CLIENT_ID` in `web/index.html`:

```html
<!-- Line 63 -->
<script type="text/javascript" src="https://oapi.map.naver.com/openapi/v3/maps.js?ncpKeyId=YOUR_ACTUAL_CLIENT_ID"></script>
```

### 2. Update Environment Variables
Add to your `.env` file:
```env
NAVER_MAPS_CLIENT_ID=your_actual_client_id_here
NAVER_CLIENT_ID=your_actual_client_id_here
```

### 3. Optional: Dynamic Loading
For production, consider loading the API key dynamically:

```javascript
// In index.html
<script>
  const naverClientId = 'YOUR_CLIENT_ID'; // Or load from environment
  const script = document.createElement('script');
  script.src = `https://oapi.map.naver.com/openapi/v3/maps.js?ncpKeyId=${naverClientId}`;
  document.head.appendChild(script);
</script>
```

## 🧪 Testing

1. **Run locally:**
   ```bash
   flutter run -d chrome
   ```

2. **Test Naver Maps:**
   - Go to Location section
   - In edit mode, select "Naver Maps"
   - The map should load with Korean venue location

3. **Verify features:**
   - ✓ Map loads correctly
   - ✓ Marker shows venue location
   - ✓ Info window displays venue name
   - ✓ Map controls work (zoom, pan)
   - ✓ Lock/unlock in edit mode

## 📱 Usage

The Naver Maps will automatically be available when:
- User selects Korean venue
- Map provider is set to Naver
- Viewing on web platform

## 🚨 Troubleshooting

### Map not loading?
1. Check browser console for errors
2. Verify Client ID is correct
3. Ensure domain is registered in Naver Cloud Console
4. Check if API is enabled for your application

### "Invalid Client ID" error?
- Double-check the Client ID in index.html
- Ensure no extra spaces or quotes
- Verify the application is active in Naver console

### CORS errors?
- Add your domain to Web Service URLs in Naver console
- For local development, use `http://localhost:*`

## 🎯 Next Steps

1. Consider adding Kakao Maps for complete Korean map coverage
2. Implement location search using Naver Search API
3. Add custom map styles to match your wedding theme
4. Consider caching map tiles for offline viewing

## 📝 Notes

- Naver Maps free tier: 200,000 calls/day
- Best for Korean addresses and POIs
- Supports Korean, English, Chinese, Japanese
- Mobile app integration requires different setup

---

**Ready to deploy?** Once configured, build and deploy:
```bash
./scripts/build-for-deployment.sh
npx vercel --prod
```