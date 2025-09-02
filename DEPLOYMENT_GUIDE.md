# Wedding Invitation Deployment Guide

## Quick Start with Vercel (Recommended)

### Step 1: Build the Project
```bash
# Run the build script
./scripts/build-for-deployment.sh
```

### Step 2: Deploy to Vercel

#### Option A: Using Vercel CLI
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy (from project root)
vercel --prod

# When prompted:
# - Set up and deploy: Y
# - Which scope: (select your account)
# - Link to existing project: N
# - Project name: wedding-invitation
# - Directory: ./build/web
# - Override settings: N
```

#### Option B: Using Vercel Dashboard
1. Go to [vercel.com](https://vercel.com)
2. Import your GitHub repository
3. Set build command: `flutter build web --release --base-href /invitation/`
4. Set output directory: `build/web`
5. Deploy!

### Step 3: Configure Custom Domain

1. In Vercel Dashboard → Settings → Domains
2. Add your domain: `daegyu.dev`
3. Configure DNS (at your domain registrar):
   ```
   Type: CNAME
   Name: @
   Value: cname.vercel-dns.com
   ```
   Or use A records:
   ```
   Type: A
   Name: @
   Value: 76.76.21.21
   ```

4. For subdirectory routing (`/invitation`), Vercel will handle it automatically with our `vercel.json` config

## Alternative Deployment Options

### Netlify
```bash
# Build first
./scripts/build-for-deployment.sh

# Install Netlify CLI
npm i -g netlify-cli

# Deploy
netlify deploy --dir=build/web --prod
```

### GitHub Pages
1. Enable GitHub Pages in repository settings
2. Use the provided GitHub Actions workflow
3. Set custom domain in repository settings

### Firebase Hosting
```bash
# Install Firebase CLI
npm i -g firebase-tools

# Initialize
firebase init hosting

# Deploy
firebase deploy
```

## Environment Variables

For production, set these in your hosting provider's dashboard:

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key
- `GOOGLE_MAPS_API_KEY`: Your Google Maps API key
- `NAVER_MAPS_CLIENT_ID`: Your Naver Maps client ID (for Korea venue)

## Post-Deployment Checklist

- [ ] Test all language versions (?ln=ko, ?ln=en, etc.)
- [ ] Test venue selections (?venue=kr, ?venue=sg, etc.)
- [ ] Verify Google Maps functionality
- [ ] Verify Naver Maps functionality (Korea venue)
- [ ] Test guestbook functionality with Supabase
- [ ] Check image loading and gallery
- [ ] Test on mobile devices
- [ ] Verify HTTPS is working
- [ ] Test sharing on social media (OG tags)

## Domain Configuration Notes

Your wedding invitation will be accessible at:
- `https://daegyu.dev/invitation` (main URL)
- With parameters: `https://daegyu.dev/invitation?ln=ko&venue=kr`

## Troubleshooting

### Images not loading
- Ensure all images in `assets/images/` are included in the build
- Check image paths don't have spaces or special characters

### Routing issues
- Verify `base-href` is set to `/invitation/`
- Check `vercel.json` rewrites configuration

### Google Maps not working
- Verify API key is set correctly
- Check domain is whitelisted in Google Cloud Console

## Support

For deployment issues:
- Vercel: [vercel.com/docs](https://vercel.com/docs)
- Flutter Web: [flutter.dev/web](https://flutter.dev/web)