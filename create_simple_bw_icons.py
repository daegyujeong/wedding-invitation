#!/usr/bin/env python3
"""
Create simple black and white icons for reliable display
"""

from PIL import Image, ImageDraw
import os

def create_simple_bw_icon(size):
    """Create a simple black and white wedding icon"""
    
    # Create image with white background
    img = Image.new('RGBA', (size, size), (255, 255, 255, 255))
    draw = ImageDraw.Draw(img)
    
    # Simple black circle border
    margin = size // 8
    draw.ellipse(
        [margin, margin, size-margin, size-margin],
        fill=None,
        outline=(0, 0, 0, 255),
        width=max(2, size // 40)
    )
    
    # Simple heart shape in center using basic shapes
    center_x, center_y = size // 2, size // 2
    heart_size = size // 5
    
    # Two circles for heart top
    circle_radius = heart_size // 3
    # Left circle
    draw.ellipse([
        center_x - heart_size//2, 
        center_y - heart_size//4,
        center_x - heart_size//6,
        center_y + heart_size//6
    ], fill=(0, 0, 0, 255))
    
    # Right circle  
    draw.ellipse([
        center_x + heart_size//6,
        center_y - heart_size//4, 
        center_x + heart_size//2,
        center_y + heart_size//6
    ], fill=(0, 0, 0, 255))
    
    # Triangle for heart bottom
    draw.polygon([
        (center_x - heart_size//2 + circle_radius//2, center_y),
        (center_x + heart_size//2 - circle_radius//2, center_y),
        (center_x, center_y + heart_size//2)
    ], fill=(0, 0, 0, 255))
    
    return img

def main():
    # Create icons directory if it doesn't exist
    icons_dir = "web/icons"
    os.makedirs(icons_dir, exist_ok=True)
    
    # Generate different sizes
    sizes = [192, 512]
    
    for size in sizes:
        print(f"Generating {size}x{size} simple B&W icon...")
        
        # Create simple black and white icon
        icon = create_simple_bw_icon(size)
        
        # Save with high compression
        icon.save(f"{icons_dir}/Icon-{size}.png", "PNG", optimize=True, compress_level=9)
        
        # Maskable version (same icon)
        icon.save(f"{icons_dir}/Icon-maskable-{size}.png", "PNG", optimize=True, compress_level=9)
    
    # Create simple favicon
    favicon = create_simple_bw_icon(32)
    favicon.save("web/favicon.png", "PNG", optimize=True, compress_level=9)
    
    print("Simple B&W wedding icons generated successfully!")
    print("Generated files:")
    for size in sizes:
        print(f"  - web/icons/Icon-{size}.png")
        print(f"  - web/icons/Icon-maskable-{size}.png")
    print("  - web/favicon.png")

if __name__ == "__main__":
    main()