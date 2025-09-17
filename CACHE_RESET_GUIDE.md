# Flutter Web Cache Reset Guide

## Problem: Users See Old Cached Version After Deployment

When deploying Flutter web apps, users often see outdated cached versions due to:
- Service Worker caching
- Browser HTTP caching
- PWA aggressive caching
- CDN caching on deployment platforms

## Solution: Multi-Layer Cache Busting Strategy

### 1. Version-Based Cache Busting in index.html

#### Update Meta Tags
```html
<!-- web/index.html -->
<meta name="version" content="v2.4.0-cache-buster-1757589083">
<meta name="build-time" content="2025-09-11T11:11:27Z">
<meta name="cache-buster" content="1757589083">
```

#### Add Cache Control Headers
```html
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
```

### 2. JavaScript Version Check with Auto-Reload

Add this script to `web/index.html` before `flutter_bootstrap.js`:

```javascript
<!-- Version-based cache busting script -->
<script>
  (function() {
    const currentVersion = 'v2.4.0-cache-buster-1757589083';
    const lastVersion = localStorage.getItem('app-version');
    
    if (lastVersion && lastVersion !== currentVersion) {
      // Version changed, force clear cache and reload
      if ('caches' in window) {
        caches.keys().then(function(names) {
          return Promise.all(names.map(name => caches.delete(name)));
        }).then(() => {
          localStorage.setItem('app-version', currentVersion);
          window.location.reload(true);
        });
      } else {
        localStorage.setItem('app-version', currentVersion);
        window.location.reload(true);
      }
    } else {
      localStorage.setItem('app-version', currentVersion);
    }
  })();
</script>
```

### 3. Force Service Worker Update

Add this script to actively update the service worker:

```javascript
<!-- Force service worker update -->
<script>
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.ready.then(function(registration) {
      registration.update();
    });
    
    // Also check for updates periodically
    setInterval(function() {
      if (navigator.serviceWorker.controller) {
        navigator.serviceWorker.controller.postMessage('skipWaiting');
      }
    }, 60000); // Check every minute
  }
</script>
```

### 4. Generate New Timestamps for Each Deployment

```bash
# Get current Unix timestamp
date +%s
# Example output: 1757589083

# Get current UTC timestamp
date -u +"%Y-%m-%dT%H:%M:%SZ"
# Example output: 2025-09-11T11:11:27Z
```

### 5. Complete Update Process

#### Step 1: Update index.html with new version
```bash
# Update the version string in index.html
# Change both the meta tags AND the JavaScript currentVersion variable
```

#### Step 2: Build with optimization script
```bash
./scripts/build-for-deployment.sh
```

#### Step 3: Deploy
```bash
npx vercel --prod
```

## User-Side Cache Clearing Methods

### For End Users (Instructions to Share)

#### Method 1: Automatic (Wait 1 minute)
The app will automatically check for updates every minute and refresh if needed.

#### Method 2: Add Version Query Parameter
Add `?v=2` (or any number) to the URL:
```
https://www.daegyu.dev/invitation/?v=2
```

#### Method 3: Browser-Specific Hard Refresh

**Desktop:**
- Windows/Linux: `Ctrl + F5` or `Ctrl + Shift + R`
- Mac: `Cmd + Shift + R`

**Mobile iOS Safari:**
1. Settings → Safari
2. Clear History and Website Data

**Mobile Android Chrome:**
1. Settings → Privacy and Security
2. Clear browsing data
3. Select "Cached images and files"
4. Clear data

#### Method 4: Incognito/Private Mode
Open the site in an incognito or private browsing window.

## Developer Testing

### Check Current Cache Status
```javascript
// Run in browser console
if ('caches' in window) {
  caches.keys().then(names => console.log('Cache names:', names));
}

// Check service worker
navigator.serviceWorker.getRegistrations().then(regs => 
  console.log('Service workers:', regs)
);

// Check localStorage version
console.log('Stored version:', localStorage.getItem('app-version'));
```

### Force Clear Everything (Developer Console)
```javascript
// Clear all caches
caches.keys().then(names => {
  names.forEach(name => caches.delete(name));
});

// Unregister service workers
navigator.serviceWorker.getRegistrations().then(regs => {
  regs.forEach(reg => reg.unregister());
});

// Clear localStorage
localStorage.clear();

// Reload
window.location.reload(true);
```

## Important Notes

1. **Always update BOTH**:
   - Meta tag version: `<meta name="version" content="...">`
   - JavaScript version: `const currentVersion = '...';`
   - They MUST match!

2. **Version Format**: Use semantic versioning with timestamp
   - Format: `v{major}.{minor}.{patch}-cache-buster-{timestamp}`
   - Example: `v2.4.0-cache-buster-1757589083`

3. **Service Worker**: The Flutter service worker file (`flutter_service_worker.js`) is auto-generated during build. It contains file hashes that change with each build.

4. **Testing**: Always test in an incognito window first to verify the update works before instructing users.

## Troubleshooting

### Issue: Changes not appearing even after deployment
1. Check if version numbers match in meta tag and JavaScript
2. Verify service worker is updating (check Network tab in DevTools)
3. Check Vercel deployment completed successfully
4. Try adding `?v={timestamp}` to URL

### Issue: Service worker not updating
1. Check if `skipWaiting` is implemented in service worker
2. Verify `registration.update()` is being called
3. Check browser console for service worker errors

### Issue: Mobile devices particularly stubborn
1. Mobile browsers cache more aggressively
2. May need to close browser app completely and reopen
3. Consider implementing shorter cache TTL for mobile user agents

## Quick Reference Commands

```bash
# Generate new timestamp
date +%s

# Build optimized version
./scripts/build-for-deployment.sh

# Deploy to production
npx vercel --prod

# Check deployment
curl -I https://www.daegyu.dev/invitation/ | grep -i cache
```

---

This guide ensures reliable cache updates for Flutter web deployments. Always remember: **Version synchronization is key!**