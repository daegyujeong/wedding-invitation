# Social Media Preview Guide for Wedding Invitation

## Overview
This guide explains how to set up and manage social media preview thumbnails for your wedding invitation website. When someone shares your link on social platforms (Facebook, Twitter, WhatsApp, KakaoTalk, etc.), a preview image will appear.

## Current Setup

### Preview Image Details
- **Current Image**: `wedding-thumbnail.jpg`
- **Location**: `/web/wedding-thumbnail.jpg`
- **Dimensions**: 1200x630 pixels (standard Open Graph size)
- **Format**: JPG (best compatibility)
- **Live URL**: `https://www.daegyu.dev/invitation/wedding-thumbnail.jpg`

### Meta Tags Configuration
The preview is controlled by meta tags in `/web/index.html`:

```html
<!-- Open Graph meta tags (Facebook, KakaoTalk, etc.) -->
<meta property="og:title" content="Daegyu & Irene Wedding Invitation">
<meta property="og:description" content="Join us for our special day - 대규 & Irene">
<meta property="og:image" content="https://www.daegyu.dev/invitation/wedding-thumbnail.jpg">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">

<!-- Twitter Card meta tags -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:image" content="https://www.daegyu.dev/invitation/wedding-thumbnail.jpg">
```

## How to Change the Preview Image

### Step 1: Prepare Your New Image
1. Choose a high-quality photo (wedding photo, couple photo, etc.)
2. Recommended specifications:
   - **Size**: 1200x630 pixels (optimal for all platforms)
   - **Format**: JPG or PNG
   - **File size**: Under 5MB
   - **Content**: Clear, attractive image that represents your wedding

### Step 2: Convert and Optimize the Image

#### Using Python (if needed):
```bash
python3 -c "
from PIL import Image
img = Image.open('your-new-image.webp')  # or any format
img_resized = img.resize((1200, 630), Image.Resampling.LANCZOS)
img_resized.save('web/wedding-thumbnail.jpg', 'JPEG', quality=95)
"
```

#### Using online tools:
- [Canva](https://www.canva.com) - Create custom designs at 1200x630
- [ResizeImage.net](https://resizeimage.net) - Resize existing images
- [TinyPNG](https://tinypng.com) - Compress images without quality loss

### Step 3: Replace the Image
```bash
# Copy your new image to the web directory
cp your-new-image.jpg web/wedding-thumbnail.jpg
```

### Step 4: Update Meta Tags (if changing filename)
If you use a different filename, update `/web/index.html`:
```html
<meta property="og:image" content="https://www.daegyu.dev/invitation/your-new-image.jpg">
<meta name="twitter:image" content="https://www.daegyu.dev/invitation/your-new-image.jpg">
```

### Step 5: Build and Deploy
```bash
# Build with optimizations
./scripts/build-for-deployment.sh

# Deploy to Vercel
npx vercel --prod
```

## Testing Your Preview

### 1. Facebook Debugger (Most Important)
- Visit: https://developers.facebook.com/tools/debug/
- Enter your URL: `https://www.daegyu.dev/invitation/`
- Click "Debug"
- **Important**: Click "Scrape Again" to clear cache
- You should see your new preview image

### 2. Twitter Card Validator
- Visit: https://cards-dev.twitter.com/validator
- Enter your URL: `https://www.daegyu.dev/invitation/`
- Preview will appear on the right

### 3. LinkedIn Post Inspector
- Visit: https://www.linkedin.com/post-inspector/
- Enter your URL: `https://www.daegyu.dev/invitation/`
- Click "Inspect"

### 4. WhatsApp/KakaoTalk Testing
- Send the link to yourself in a chat
- The preview should appear automatically
- If old preview shows, wait 24 hours for cache to clear

## Troubleshooting

### Preview Not Showing
1. **Check image accessibility**:
   ```bash
   curl -I https://www.daegyu.dev/invitation/wedding-thumbnail.jpg
   ```
   Should return `HTTP/2 200` and `content-type: image/jpeg`

2. **Verify Vercel configuration** (`vercel.json`):
   ```json
   {
     "routes": [
       {
         "src": "/invitation/(.*\\.(jpg|jpeg|png|webp|gif))",
         "dest": "/$1"
       }
     ]
   }
   ```

3. **Clear social media cache**:
   - Facebook: Use "Scrape Again" button
   - Twitter: Wait 7 days or use new URL parameter (`?v=2`)
   - WhatsApp: Wait 24 hours

### Wrong Image Showing
1. Old cache - use debugger tools to refresh
2. Multiple og:image tags - check for duplicates in HTML
3. Image too large - keep under 5MB

### Image Looks Bad
1. Wrong dimensions - use exactly 1200x630 pixels
2. Low quality - save at 95% JPEG quality
3. Text too small - ensure text is readable on mobile

## Best Practices

### Image Design Tips
- **Contrast**: Use high contrast for text over images
- **Clarity**: Avoid busy backgrounds
- **Branding**: Include your names and wedding date
- **Quality**: Use professional photos when possible
- **Test**: Preview on mobile before deploying

### Technical Tips
- **Format**: Use JPG for photos, PNG for graphics
- **Naming**: Use descriptive names (wedding-thumbnail.jpg)
- **Backup**: Keep original high-res versions
- **CDN**: Consider using a CDN for faster loading
- **Multiple images**: Can have different images for different pages

## Platform-Specific Requirements

### Facebook/Instagram
- Minimum: 200x200 pixels
- Recommended: 1200x630 pixels
- Aspect ratio: 1.91:1
- Format: JPG, PNG

### Twitter/X
- Minimum: 144x144 pixels
- Recommended: 1200x630 pixels
- Maximum: 4096x4096 pixels
- Format: JPG, PNG, WebP, GIF

### LinkedIn
- Minimum: 200x200 pixels
- Recommended: 1200x630 pixels
- Format: JPG, PNG

### WhatsApp
- Minimum: 300x200 pixels
- Recommended: 1200x630 pixels
- Format: JPG, PNG

### KakaoTalk
- Minimum: 200x200 pixels
- Recommended: 1200x630 pixels
- Format: JPG, PNG

## Quick Commands Reference

```bash
# Build and deploy with current image
./scripts/build-for-deployment.sh && npx vercel --prod

# Test image accessibility
curl -I https://www.daegyu.dev/invitation/wedding-thumbnail.jpg

# View current meta tags
grep -A 5 "og:image" web/index.html

# Clear Facebook cache (manual)
# Visit: https://developers.facebook.com/tools/debug/?q=https://www.daegyu.dev/invitation/
```

## Support

If you encounter issues:
1. Check this guide first
2. Test with debugger tools
3. Wait for cache to clear (up to 24 hours)
4. Try with a different image format
5. Verify image is accessible via direct URL

Remember: Social media platforms cache aggressively. Always use their debugger tools to force a refresh when testing changes.

---

*Last updated: September 2025*
*Wedding Invitation: https://www.daegyu.dev/invitation/*