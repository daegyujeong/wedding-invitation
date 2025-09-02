# Deploying Flutter Wedding Invitation to GitHub Pages

## Overview
This guide will help you deploy your Flutter wedding invitation app to GitHub Pages with your custom domain `daegyu.dev/mobileinvitation`.

## Prerequisites
- GitHub account
- Your `daegyu.dev` domain with DNS access
- Flutter SDK installed
- Git installed

## Step 1: Prepare Your Flutter App for Web Deployment

### 1.1 Update base href in index.html
Since your app will be served from `/mobileinvitation/`, update the base href:

```bash
flutter build web --base-href="/mobileinvitation/"
```

### 1.2 Build Script
Use the provided build script that handles image optimization and web assets:

```bash
./scripts/build-for-deployment.sh
```

## Step 2: Create GitHub Repository

1. Create a new repository on GitHub (e.g., `wedding-invitation-web`)
2. Make sure the repository is public (required for free GitHub Pages)

## Step 3: Set Up GitHub Pages Deployment

### Option A: Using GitHub Actions (Recommended)

Create `.github/workflows/deploy-github-pages.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Build web
        run: flutter build web --base-href="/mobileinvitation/" --release
        
      - name: Setup Pages
        uses: actions/configure-pages@v4
        
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: 'build/web'
          
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### Option B: Manual Deployment

1. Build your Flutter web app:
```bash
flutter build web --base-href="/mobileinvitation/" --release
```

2. Create a `gh-pages` branch:
```bash
git checkout -b gh-pages
```

3. Copy the contents of `build/web` to the root of the `gh-pages` branch
4. Push to GitHub

## Step 4: Configure Your Domain

### 4.1 GitHub Repository Settings
1. Go to your repository Settings → Pages
2. Under "Custom domain", enter `daegyu.dev`
3. Check "Enforce HTTPS"

### 4.2 DNS Configuration
Add these records to your domain's DNS settings:

```
Type: A
Name: @
Value: 185.199.108.153

Type: A
Name: @
Value: 185.199.109.153

Type: A
Name: @
Value: 185.199.110.153

Type: A
Name: @
Value: 185.199.111.153

Type: CNAME
Name: www
Value: [your-github-username].github.io
```

### 4.3 Create CNAME file
In your repository root (in the `gh-pages` branch or `build/web` folder), create a `CNAME` file:

```
daegyu.dev
```

## Step 5: Configure Subdirectory Routing

Since you want the app at `/mobileinvitation/`, you have two options:

### Option A: Deploy to a Repository Named `mobileinvitation`
- Create a repository named `mobileinvitation`
- GitHub will automatically serve it at `daegyu.dev/mobileinvitation/`

### Option B: Use a Subdirectory in Your Main Site
- If you have a main site at `daegyu.dev`, create a `mobileinvitation` directory
- Deploy the Flutter web build to that directory

## Step 6: Environment Variables and API Keys

### 6.1 For Public APIs (Maps, etc.)
Update your `web/index.html` to use environment-specific keys:

```html
<script>
  // Production configuration
  window.GOOGLE_MAPS_API_KEY = 'YOUR_PRODUCTION_GOOGLE_MAPS_KEY';
  window.NAVER_MAPS_CLIENT_ID = 'YOUR_PRODUCTION_NAVER_CLIENT_ID';
</script>
```

### 6.2 For Sensitive Data (Supabase)
Use GitHub Secrets for sensitive keys:

1. Go to Repository Settings → Secrets and variables → Actions
2. Add secrets:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

3. Update your workflow to inject these during build:

```yaml
- name: Build web
  env:
    SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
    SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
  run: |
    flutter build web --base-href="/mobileinvitation/" --release \
      --dart-define=SUPABASE_URL=$SUPABASE_URL \
      --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

## Step 7: Test Your Deployment

1. After deployment, visit:
   - `https://daegyu.dev/mobileinvitation/`
   - Test all features (maps, guestbook, language switching)
   - Check venue-specific content filtering

2. Verify HTTPS is working
3. Test on mobile devices

## Alternative Free Hosting Options

### 1. Vercel (Recommended Alternative)
- Pros: Excellent performance, automatic HTTPS, easy custom domains
- Deploy command: `vercel --prod`
- Custom domain: Add in Vercel dashboard

### 2. Netlify
- Pros: Great for static sites, form handling
- Deploy: Drag and drop `build/web` folder
- Custom domain: Easy setup in dashboard

### 3. Firebase Hosting
- Pros: Google's CDN, good for Firebase integration
- Deploy: `firebase deploy`
- Custom domain: Configure in Firebase console

### 4. Cloudflare Pages
- Pros: Fast global CDN, unlimited bandwidth
- Deploy: Connect GitHub repo
- Custom domain: Easy if using Cloudflare DNS

## Troubleshooting

### Issue: 404 errors on page refresh
Add a `404.html` file that redirects to index.html:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Redirecting...</title>
  <script>
    sessionStorage.redirect = location.href;
  </script>
  <meta http-equiv="refresh" content="0;URL='/mobileinvitation/'">
</head>
</html>
```

### Issue: Assets not loading
- Check base href is set correctly
- Verify all asset paths are relative
- Check browser console for specific errors

### Issue: API keys not working
- Use different keys for production
- Check CORS settings for your domain
- Verify environment variables are set correctly

## Maintenance

1. **Updates**: Push to main branch to trigger automatic deployment
2. **Monitoring**: Use GitHub Pages insights or Google Analytics
3. **Backups**: Keep local copies of your build artifacts

## Security Considerations

1. Never commit sensitive API keys to the repository
2. Use environment variables or GitHub Secrets
3. Implement rate limiting on your Supabase backend
4. Consider adding reCAPTCHA for the guestbook

## Performance Optimization

1. Enable gzip compression
2. Use CDN for images (consider Cloudinary or similar)
3. Implement lazy loading for gallery images
4. Minimize JavaScript bundle size

## Next Steps

1. Set up monitoring (e.g., Google Analytics)
2. Configure SEO meta tags
3. Add social media preview cards
4. Set up automated testing before deployment