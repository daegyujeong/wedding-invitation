#!/bin/bash

# Prepare assets for web deployment without external dependencies

echo "🚀 Preparing assets for web deployment..."

# Create build directory if it doesn't exist
mkdir -p build/web/assets/images

# Copy all images to build directory
echo "📁 Copying images to build directory..."
cp -r assets/images/* build/web/assets/images/ 2>/dev/null || true

# Count images
IMAGE_COUNT=$(find assets/images -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.JPG" -o -name "*.JPEG" -o -name "*.PNG" \) | wc -l)

echo "✅ Copied $IMAGE_COUNT images"

# Display large images that might need optimization
echo ""
echo "⚠️  Large images (>5MB) that may benefit from optimization:"
find assets/images -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.JPG" -o -name "*.JPEG" -o -name "*.PNG" \) -size +5M -exec du -h {} \; | sort -hr

echo ""
echo "💡 Tips for image optimization:"
echo "   - Use online tools like tinypng.com or squoosh.app"
echo "   - Consider using WebP format for better compression"
echo "   - Aim for images under 2MB for web performance"
echo ""
echo "📦 Assets ready for deployment!"