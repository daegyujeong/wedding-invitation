#!/usr/bin/env python3
"""Generate Open Graph preview image for wedding invitation"""

from PIL import Image, ImageDraw, ImageFont
import io
import os

def create_og_image():
    # Create image (1200x630 is optimal for Open Graph)
    width, height = 1200, 630
    
    # Create gradient background (warm wedding colors)
    image = Image.new('RGB', (width, height), color='#f8f5f0')
    draw = ImageDraw.Draw(image)
    
    # Create gradient effect
    for y in range(height):
        color_intensity = int(255 - (y / height * 30))  # Subtle gradient
        color = f'rgb({min(248, color_intensity)},{min(245, color_intensity-3)},{min(240, color_intensity-8)})'
        draw.line([(0, y), (width, y)], fill=color)
    
    # Add decorative border
    border_color = '#d4a574'
    border_width = 8
    draw.rectangle([border_width//2, border_width//2, width-border_width//2, height-border_width//2], 
                   outline=border_color, width=border_width)
    
    # Draw heart symbol
    heart_size = 80
    heart_x = width // 2
    heart_y = 150
    
    # Simple heart using text (more reliable than drawing)
    try:
        # Try to load a system font
        title_font = ImageFont.truetype("/System/Library/Fonts/Georgia.ttc", 120)
        name_font = ImageFont.truetype("/System/Library/Fonts/Georgia.ttc", 80)  
        date_font = ImageFont.truetype("/System/Library/Fonts/Georgia.ttc", 40)
        heart_font = ImageFont.truetype("/System/Library/Fonts/Georgia.ttc", 80)
    except:
        # Fallback to default font
        title_font = ImageFont.load_default()
        name_font = ImageFont.load_default()
        date_font = ImageFont.load_default()
        heart_font = ImageFont.load_default()
    
    # Draw heart
    heart = "♥"
    heart_bbox = draw.textbbox((0, 0), heart, font=heart_font)
    heart_width = heart_bbox[2] - heart_bbox[0]
    draw.text((heart_x - heart_width//2, heart_y), heart, fill='#8B4B5C', font=heart_font)
    
    # Draw names
    names = "대규 & Irene"
    names_bbox = draw.textbbox((0, 0), names, font=name_font)
    names_width = names_bbox[2] - names_bbox[0]
    draw.text((width//2 - names_width//2, 250), names, fill='#8B4B5C', font=name_font)
    
    # Draw "Wedding Invitation"
    invitation_text = "Wedding Invitation"
    invitation_bbox = draw.textbbox((0, 0), invitation_text, font=date_font)
    invitation_width = invitation_bbox[2] - invitation_bbox[0]
    draw.text((width//2 - invitation_width//2, 350), invitation_text, fill='#8B4B5C', font=date_font)
    
    # Draw date
    date_text = "Join us for our special day"
    date_bbox = draw.textbbox((0, 0), date_text, font=date_font)
    date_width = date_bbox[2] - date_bbox[0]
    draw.text((width//2 - date_width//2, 450), date_text, fill='#666666', font=date_font)
    
    # Add decorative elements
    for i in range(5):
        x = 100 + i * 200
        y = 520
        draw.circle((x, y), 15, fill='#d4a574', outline='#8B4B5C', width=2)
    
    # Save image
    output_path = 'web/og-image.jpg'
    image.save(output_path, 'JPEG', quality=90)
    print(f"Open Graph image created: {output_path}")
    
    return output_path

if __name__ == "__main__":
    create_og_image()