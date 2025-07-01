# Flutter Mobile Wedding Invitation

A beautiful, customizable mobile wedding invitation application built with Flutter. Create stunning digital wedding invitations with photos, videos, location maps, and interactive features.

## 🌟 Features

### Core Features
- **🎨 Intuitive Editor**: Drag-and-drop visual editor for creating custom layouts
- **📱 Mobile-First Design**: Optimized for mobile viewing and sharing
- **🖼️ Photo Gallery**: Beautiful image carousels and galleries
- **🎥 Video Support**: Embed wedding videos with custom players
- **🗺️ Interactive Maps**: Location sharing with navigation integration
- **⏰ Countdown Timer**: Real-time countdown to the wedding day
- **💌 Guest Messages**: Collect congratulations from friends and family
- **🔗 Social Sharing**: Easy sharing via KakaoTalk, SMS, and social media

### Widget Types
- **Text Widgets**: Customizable fonts, colors, and alignment
- **Image Widgets**: Support for local assets and network images
- **Video Widgets**: Built-in video player with controls
- **Map Widgets**: OpenStreetMap integration with custom markers
- **Gallery Widgets**: Image carousels with auto-play options
- **Button Widgets**: Interactive buttons with various actions (phone, email, navigation)
- **Countdown Widgets**: Animated countdown timers
- **Message Widgets**: Guest message collection forms

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0.0 or higher
- Dart 2.17.0 or higher
- iOS 12.0+ / Android API level 21+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/daegyujeong/wedding-invitation.git
   cd wedding-invitation
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Setup for Development

1. **Configure Supabase (Optional)**
   - Create a Supabase project
   - Update the configuration in `lib/core/config/supabase_config.dart`

2. **Add your images**
   - Place your wedding photos in `assets/images/`
   - Update the asset references in `pubspec.yaml`

3. **Customize the app**
   - Update bride and groom names in the data models
   - Modify colors and themes in the UI components

## 🛠️ Technology Stack

- **Frontend**: Flutter
- **Backend**: Supabase (Optional)
- **Storage**: Supabase Storage (Optional)
- **Authentication**: Supabase Auth (Optional)
- **Maps**: Flutter Map with OpenStreetMap
- **Video**: Video Player & Chewie
- **State Management**: Provider & Riverpod
- **Architecture**: MVVM (Model-View-ViewModel)

## 📱 Usage

### Creating a Wedding Invitation

1. **Launch the app** and navigate to the editor
2. **Choose a template** or start from scratch
3. **Add widgets** by tapping the "+" button and selecting from categories:
   - **Basic**: Text, Images, Buttons
   - **Info**: Maps, Countdown, Schedule
   - **Media**: Gallery, Video
4. **Customize widgets** by tapping on them and editing properties
5. **Preview** your invitation in real-time
6. **Share** your invitation via URL or QR code

### Widget Customization

#### Text Widgets
- Font size, weight, and color
- Text alignment and formatting
- Background colors and transparency

#### Image Widgets
- Image source (local or network)
- Fit modes (cover, contain, fill)
- Border radius and effects

#### Video Widgets
- Video URL configuration
- Auto-play and loop settings
- Custom controls and muting options

#### Map Widgets
- Location coordinates (latitude/longitude)
- Zoom level and map style
- Custom markers and descriptions

#### Button Widgets
- Action types: URL, Phone, SMS, Email, Navigation
- Custom styling and colors
- Icon and text combinations

### Navigation Features

The app includes dedicated screens for:
- **Gallery**: Photo slideshow with navigation
- **Location**: Interactive map with directions
- **Messages**: Guest message collection
- **Editor**: Full customization interface

## 🎨 Customization

### Themes and Colors
The app uses a romantic pink color scheme by default. You can customize:

```dart
// In your theme configuration
primarySwatch: Colors.pink,
accentColor: Colors.pinkAccent,
```

### Fonts
Configure custom fonts in `pubspec.yaml`:

```yaml
fonts:
  - family: YourCustomFont
    fonts:
      - asset: assets/fonts/YourCustomFont-Regular.ttf
      - asset: assets/fonts/YourCustomFont-Bold.ttf
        weight: 700
```

### Background Images
Replace the default background in `assets/images/background.png` with your custom image.

## 🔧 Configuration

### Environment Setup

1. **iOS Configuration**
   - Update `Info.plist` for camera and location permissions
   - Configure URL schemes for sharing

2. **Android Configuration**
   - Update `AndroidManifest.xml` for permissions
   - Configure intent filters for sharing

### Video Configuration

For video widgets, ensure you have proper video URLs. Supported formats:
- MP4 (recommended)
- WebM
- HLS streams

Example video configuration:
```dart
VideoWidget(
  videoUrl: 'https://example.com/your-video.mp4',
  autoPlay: false,
  showControls: true,
  loop: false,
  muted: false,
)
```

### Map Configuration

For map widgets, configure your location:
```dart
MapWidget(
  latitude: 37.5665,  // Your venue latitude
  longitude: 126.978, // Your venue longitude
  title: 'Wedding Venue',
  description: 'Beautiful venue description',
  zoom: 15.0,
)
```

## 📸 Screenshots

<img src="screenshots/home.png" width="250" alt="Home Screen"> <img src="screenshots/editor.png" width="250" alt="Editor Screen"> <img src="screenshots/gallery.png" width="250" alt="Gallery Screen">

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for backend infrastructure
- OpenStreetMap for map services
- Contributors and wedding couples who inspired this project

## 🐛 Troubleshooting

### Common Issues

1. **Video not playing**
   - Ensure the video URL is accessible
   - Check network connectivity
   - Verify video format compatibility

2. **Map not loading**
   - Check internet connection
   - Verify latitude/longitude coordinates
   - Ensure location permissions are granted

3. **Images not displaying**
   - Verify image paths in `pubspec.yaml`
   - Check if images exist in the assets folder
   - Ensure images are in supported formats (PNG, JPG, WebP)

### Performance Tips

- Optimize images before adding them to assets
- Use appropriate video resolutions for mobile viewing
- Limit the number of widgets per page for smooth performance

## 📞 Support

For support and questions:
- Open an issue on GitHub
- Check the documentation
- Join our community discussions

---

Made with ❤️ for couples starting their beautiful journey together.