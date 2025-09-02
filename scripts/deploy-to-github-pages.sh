#!/bin/bash

# Deploy Flutter Web App to GitHub Pages
# This script builds and deploys your Flutter web app to GitHub Pages

set -e

echo "🚀 Starting deployment to GitHub Pages..."

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

# Build the Flutter web app with base href
echo "📦 Building Flutter web app..."
flutter build web --base-href="/mobileinvitation/" --release

# Create necessary files for GitHub Pages
echo "📄 Creating CNAME file..."
echo "daegyu.dev" > build/web/CNAME

echo "📄 Creating 404.html for client-side routing..."
cat > build/web/404.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Redirecting...</title>
  <script>
    // Store the attempted URL
    sessionStorage.redirect = location.href;
  </script>
  <meta http-equiv="refresh" content="0;URL='/mobileinvitation/'">
</head>
</html>
EOF

# Create .nojekyll file to prevent Jekyll processing
echo "📄 Creating .nojekyll file..."
touch build/web/.nojekyll

echo "✅ Build complete!"
echo ""
echo "📋 Next steps:"
echo "1. Commit and push the main branch to trigger GitHub Actions"
echo "2. Or manually deploy by copying build/web contents to gh-pages branch"
echo "3. Configure your repository settings:"
echo "   - Go to Settings → Pages"
echo "   - Set Source to 'GitHub Actions' or 'Deploy from a branch'"
echo "   - Add custom domain: daegyu.dev"
echo "4. Update your DNS records as specified in DEPLOYMENT_GUIDE_GITHUB_PAGES.md"
echo ""
echo "🌐 Your app will be available at: https://daegyu.dev/mobileinvitation/"