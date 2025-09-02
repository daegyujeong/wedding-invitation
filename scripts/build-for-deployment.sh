#!/bin/bash

# Build script for deploying Flutter web app to subdirectory

echo "🚀 Building Flutter web app for deployment..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web with optimizations
echo "🔨 Building web app with optimizations..."
flutter build web --release \
  --dart-define=SUPABASE_URL=https://otksynthwanpqpkdttzv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90a3N5bnRod2FucHFwa2R0dHp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzE5NTIsImV4cCI6MjA3MTYwNzk1Mn0.95A7liurnMMaxcErcQIoTCjXUQypQuoJ3y25JTO9R6w \
  --web-renderer canvaskit

# Create deployment info file
echo "📝 Creating deployment info..."
echo "{
  \"buildDate\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
  \"version\": \"1.0.0\"
}" > build/web/build-info.json

# Check build size
echo ""
echo "📊 Build Statistics:"
TOTAL_SIZE=$(du -sh build/web | cut -f1)
echo "   Total build size: $TOTAL_SIZE"

# Show large assets
echo ""
echo "📦 Largest assets:"
find build/web -type f -size +1M -exec du -h {} \; | sort -hr | head -10

echo ""
echo "✅ Build complete! Ready for deployment."
echo "📁 Build output: build/web/"
echo ""
echo "🚀 Next step: Deploy with 'npx vercel --prod'"