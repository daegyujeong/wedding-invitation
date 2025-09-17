#!/usr/bin/env python3
"""
Create simple emoji-based wedding icons with minimal file size
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_emoji_icon(size, emoji="💒"):
    """Create a simple emoji-based icon"""
    
    # Create image with white background
    img = Image.new('RGBA', (size, size), (255, 255, 255, 255))
    draw = ImageDraw.Draw(img)
    
    # Try to load a system font that supports emoji
    try:
        # Try different emoji fonts based on system
        font_paths = [
            "/System/Library/Fonts/Apple Color Emoji.ttc",  # macOS
            "/System/Library/Fonts/Helvetica.ttc",          # macOS fallback
            "C:/Windows/Fonts/seguiemj.ttf",                # Windows
            "/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf",  # Linux
        ]
        
        font = None
        font_size = int(size * 0.6)  # 60% of icon size
        
        for font_path in font_paths:
            if os.path.exists(font_path):
                try:
                    font = ImageFont.truetype(font_path, font_size)
                    break
                except:
                    continue
        
        if font is None:
            # Fallback to default font
            font = ImageFont.load_default()
            
    except Exception:
        # Ultimate fallback
        font = ImageFont.load_default()
    
    # Calculate text position (center)
    # For emoji, we'll use a simple text approach
    text = emoji
    
    # Get text bounding box
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Center the text
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    
    # Draw the emoji
    draw.text((x, y), text, font=font, fill=(0, 0, 0, 255))
    
    return img

def create_simple_wedding_icon(size):
    """Create a simple wedding icon using basic shapes and wedding colors"""
    
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Wedding colors - use simpler, web-safe colors
    primary = (220, 20, 60)   # Crimson
    accent = (255, 182, 193)  # Light pink
    
    # Draw simple circular background
    margin = size // 8
    draw.ellipse(
        [margin, margin, size-margin, size-margin],
        fill=primary,
        outline=accent,
        width=2
    )
    
    # Draw simple heart in center
    center_x, center_y = size // 2, size // 2
    heart_size = size // 4
    
    # Simple heart using two circles and a triangle
    # Left circle
    draw.ellipse([
        center_x - heart_size//2 - heart_size//4, 
        center_y - heart_size//4,
        center_x - heart_size//4,
        center_y + heart_size//4
    ], fill=accent)
    
    # Right circle  
    draw.ellipse([
        center_x + heart_size//4,
        center_y - heart_size//4, 
        center_x + heart_size//2 + heart_size//4,
        center_y + heart_size//4
    ], fill=accent)
    
    # Bottom triangle
    draw.polygon([
        (center_x - heart_size//2, center_y),
        (center_x + heart_size//2, center_y),
        (center_x, center_y + heart_size//2)
    ], fill=accent)
    
    return img

def main():
    # Create icons directory if it doesn't exist
    icons_dir = "web/icons"
    os.makedirs(icons_dir, exist_ok=True)
    
    # Generate different sizes
    sizes = [192, 512]
    
    for size in sizes:
        print(f"Generating {size}x{size} icon...")
        
        # Create simple wedding icon (not emoji-based to avoid font issues)
        icon = create_simple_wedding_icon(size)
        
        # Save with optimization
        icon.save(f"{icons_dir}/Icon-{size}.png", "PNG", optimize=True)
        
        # Maskable version (same icon, as it's already designed for masking)
        icon.save(f"{icons_dir}/Icon-maskable-{size}.png", "PNG", optimize=True)
    
    # Create simple favicon
    favicon = create_simple_wedding_icon(32)
    favicon.save("web/favicon.png", "PNG", optimize=True)
    
    print("Simple wedding icons generated successfully!")
    print("Generated files:")
    for size in sizes:
        print(f"  - web/icons/Icon-{size}.png")
        print(f"  - web/icons/Icon-maskable-{size}.png")
    print("  - web/favicon.png")

if __name__ == "__main__":
    main()