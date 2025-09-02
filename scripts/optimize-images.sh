#!/bin/bash

# Image optimization script for web deployment
# Requires: brew install imagemagick

echo "🖼️  Optimizing images for web deployment..."

# Create optimized directory
mkdir -p assets/images/optimized

# Function to optimize image
optimize_image() {
    local input="$1"
    local filename=$(basename "$input")
    local output="assets/images/optimized/$filename"
    
    # Skip if already optimized
    if [ -f "$output" ]; then
        echo "⏭️  Skipping $filename (already optimized)"
        return
    fi
    
    echo "🔄 Optimizing $filename..."
    
    # Convert and optimize
    # - Quality 85% for good balance
    # - Strip metadata
    # - Progressive JPEG
    # - Max width 2000px (resize if larger)
    convert "$input" \
        -quality 85 \
        -strip \
        -interlace Plane \
        -resize "2000>" \
        "$output"
        
    # Get file sizes
    original_size=$(du -h "$input" | cut -f1)
    optimized_size=$(du -h "$output" | cut -f1)
    
    echo "✅ $filename: $original_size → $optimized_size"
}

# Optimize all images
shopt -s nullglob
for img in assets/images/*.{jpg,jpeg,png,JPG,JPEG,PNG}; do
    if [ -f "$img" ]; then
        optimize_image "$img"
    fi
done
shopt -u nullglob

echo "📊 Optimization complete!"
echo "🎯 Original images: assets/images/"
echo "✨ Optimized images: assets/images/optimized/"
echo ""
echo "💡 To use optimized images, update your code to reference assets/images/optimized/"