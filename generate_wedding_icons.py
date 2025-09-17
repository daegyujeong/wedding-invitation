#!/usr/bin/env python3
"""
Generate colorful wedding-themed icons for the wedding invitation app
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_wedding_icon(size):
    """Create a colorful wedding icon with hearts and rings"""
    
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Wedding colors
    primary_pink = (214, 51, 132)  # #D63384
    light_pink = (252, 196, 165)  # #F8C4A5
    gold = (212, 165, 116)        # #D4A574
    white = (255, 255, 255)
    
    # Draw circular background with gradient effect
    center = size // 2
    radius = size // 2 - 10
    
    # Background circle
    draw.ellipse(
        [10, 10, size-10, size-10],
        fill=primary_pink,
        outline=gold,
        width=3
    )
    
    # Draw wedding rings
    ring_size = size // 6
    ring1_center = (center - ring_size//2, center - ring_size//3)
    ring2_center = (center + ring_size//2, center + ring_size//3)
    
    # Ring 1
    draw.ellipse(
        [ring1_center[0] - ring_size//2, ring1_center[1] - ring_size//2,
         ring1_center[0] + ring_size//2, ring1_center[1] + ring_size//2],
        fill=None,
        outline=gold,
        width=max(2, size // 40)
    )
    
    # Ring 2 (overlapping)
    draw.ellipse(
        [ring2_center[0] - ring_size//2, ring2_center[1] - ring_size//2,
         ring2_center[0] + ring_size//2, ring2_center[1] + ring_size//2],
        fill=None,
        outline=white,
        width=max(2, size // 40)
    )
    
    # Draw hearts
    heart_size = size // 10
    
    def draw_heart(x, y, size, color):
        # Simple heart shape using circles and triangle
        # Two circles for top of heart
        circle_radius = size // 3
        draw.ellipse([x - circle_radius, y - circle_radius//2, 
                     x + circle_radius, y + circle_radius + circle_radius//2], 
                     fill=color)
        draw.ellipse([x + circle_radius//2, y - circle_radius//2, 
                     x + circle_radius + circle_radius, y + circle_radius + circle_radius//2], 
                     fill=color)
        # Triangle for bottom of heart
        draw.polygon([
            (x - circle_radius, y + circle_radius//2),
            (x + circle_radius + circle_radius//2, y + circle_radius//2),
            (x + circle_radius//2, y + size)
        ], fill=color)
    
    # Draw small hearts around the rings
    heart_positions = [
        (center - size//4, center - size//3),
        (center + size//4, center - size//4),
        (center - size//3, center + size//4),
        (center + size//3, center + size//3)
    ]
    
    colors = [light_pink, white, light_pink, white]
    for i, (hx, hy) in enumerate(heart_positions):
        draw_heart(hx, hy, heart_size, colors[i % len(colors)])
    
    return img

def main():
    # Create icons directory if it doesn't exist
    icons_dir = "web/icons"
    os.makedirs(icons_dir, exist_ok=True)
    
    # Generate different sizes
    sizes = [192, 512]
    
    for size in sizes:
        print(f"Generating {size}x{size} icon...")
        
        # Regular icon
        icon = create_wedding_icon(size)
        icon.save(f"{icons_dir}/Icon-{size}.png", "PNG")
        
        # Maskable icon (with extra padding for safe zone)
        maskable_size = int(size * 1.2)  # Add 20% padding
        maskable = Image.new('RGBA', (maskable_size, maskable_size), (0, 0, 0, 0))
        
        # Paste the icon in center with padding
        offset = (maskable_size - size) // 2
        maskable.paste(icon, (offset, offset), icon)
        
        # Resize back to original size
        maskable = maskable.resize((size, size), Image.Resampling.LANCZOS)
        maskable.save(f"{icons_dir}/Icon-maskable-{size}.png", "PNG")
    
    # Also update favicon
    favicon = create_wedding_icon(32)
    favicon.save("web/favicon.png", "PNG")
    
    print("Wedding icons generated successfully!")
    print("Generated files:")
    for size in sizes:
        print(f"  - web/icons/Icon-{size}.png")
        print(f"  - web/icons/Icon-maskable-{size}.png")
    print("  - web/favicon.png")

if __name__ == "__main__":
    main()