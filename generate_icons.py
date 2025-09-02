#!/usr/bin/env python3
"""
Generate wedding-themed icons for the Flutter web app
Creates favicon.png and icon files with a wedding theme
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_wedding_icon(size, output_path):
    """Create a wedding-themed icon with specified size"""
    
    # Create image with soft wedding colors
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Background gradient (soft pink to rose gold effect)
    for i in range(size):
        for j in range(size):
            # Create gradient effect
            distance = ((i - size/2)**2 + (j - size/2)**2)**0.5
            max_distance = (size/2) * 1.4
            ratio = min(distance / max_distance, 1)
            
            # Wedding theme colors
            r = int(254 - ratio * 30)  # 254 to 224
            g = int(247 - ratio * 51)  # 247 to 196  
            b = int(243 - ratio * 127) # 243 to 116
            
            img.putpixel((i, j), (r, g, b, 255))
    
    # Add decorative circle border
    border_width = max(1, size // 16)
    draw.ellipse([border_width, border_width, size-border_width, size-border_width], 
                outline=(212, 165, 116, 255), width=border_width)
    
    # Add wedding symbol in center
    try:
        # Try to use a nice font
        font_size = size // 2
        font = ImageFont.truetype("Arial.ttf", font_size)
    except:
        # Fallback to default font
        font = ImageFont.load_default()
    
    # Draw wedding rings or heart symbol
    symbol = "♥"  # Heart symbol (more reliable than emoji)
    
    # Get text size for centering
    bbox = draw.textbbox((0, 0), symbol, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Center the symbol
    x = (size - text_width) // 2
    y = (size - text_height) // 2
    
    # Draw shadow for depth
    draw.text((x+2, y+2), symbol, fill=(139, 69, 19, 128), font=font)
    # Draw main text
    draw.text((x, y), symbol, fill=(139, 69, 19, 255), font=font)
    
    # Save the image
    img.save(output_path, 'PNG')
    print(f"Created icon: {output_path} ({size}x{size})")

def main():
    """Generate all required wedding icons"""
    web_dir = "/Users/jeongdaegyu/Documents/wedding_invitation/web"
    icons_dir = os.path.join(web_dir, "icons")
    
    # Create icons directory if it doesn't exist
    os.makedirs(icons_dir, exist_ok=True)
    
    # Generate all required sizes
    icon_sizes = [
        (32, os.path.join(web_dir, "favicon.png")),
        (192, os.path.join(icons_dir, "Icon-192.png")),
        (512, os.path.join(icons_dir, "Icon-512.png")),
        (192, os.path.join(icons_dir, "Icon-maskable-192.png")),
        (512, os.path.join(icons_dir, "Icon-maskable-512.png")),
    ]
    
    for size, path in icon_sizes:
        create_wedding_icon(size, path)
    
    print("\n✅ All wedding icons created successfully!")
    print("🎨 Wedding theme: Soft pink gradient with heart symbol")
    print("📱 Ready for deployment!")

if __name__ == "__main__":
    main()