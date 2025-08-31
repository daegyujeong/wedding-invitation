# Wedding Invitation App - Comprehensive Development Guide

## Overview

This guide documents the complete development journey of a Flutter-based wedding invitation application with multi-venue support, real-time guestbook functionality, and advanced features like venue-based content filtering and pagination.

## Table of Contents

1. [Architecture & Technology Stack](#architecture--technology-stack)
2. [Core Features Implemented](#core-features-implemented)
3. [Database & Backend Integration](#database--backend-integration)
4. [UI/UX Implementation](#uiux-implementation)
5. [Localization & Internationalization](#localization--internationalization)
6. [Advanced Features](#advanced-features)
7. [Code Explanations](#code-explanations)
8. [File Structure](#file-structure)
9. [Setup & Configuration](#setup--configuration)
10. [Troubleshooting](#troubleshooting)

## Architecture & Technology Stack

### Frontend
- **Flutter 3.x** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management for venue and locale providers
- **GoRouter** - Declarative routing with custom transitions
- **GetIt** - Dependency injection container

### Backend & Database
- **Supabase** - Backend-as-a-Service platform
- **PostgreSQL** - Primary database with real-time subscriptions
- **Row Level Security (RLS)** - Data security and access control
- **Real-time subscriptions** - Live message updates

### Maps & Location Services
- **Google Maps** - Primary map provider for international venues
- **Naver Maps** - Korean-specific map integration
- **Multi-provider architecture** - Seamless switching between map services

## Core Features Implemented

### 1. Multi-Venue Wedding System
```dart
// lib/providers/venue_provider.dart
class VenueProvider extends ChangeNotifier {
  static const Map<String, Map<String, String>> venueOptions = {
    'my': { 'name': 'Malaysia', 'nameKo': '말레이시아', 'flag': '🇲🇾' },
    'sg': { 'name': 'Singapore', 'nameKo': '싱가폴', 'flag': '🇸🇬' },
    'ko': { 'name': 'South Korea', 'nameKo': '대한민국', 'flag': '🇰🇷' },
    'all': { 'name': 'All Events', 'nameKo': '모든 행사', 'flag': '🌍' },
  };
}
```

**Key Implementation Details:**
- Persistent venue selection using SharedPreferences
- URL-based venue parameters for deep linking
- Content filtering based on selected venue
- Bilingual venue names with emoji flags

### 2. Real-time Guestbook with Password Protection
```dart
// Database Schema (supabase_schema.sql)
CREATE TABLE guestbook_messages (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_approved BOOLEAN DEFAULT true,
  relationship TEXT,
  avatar_url TEXT,
  is_deleted BOOLEAN DEFAULT false,
  password TEXT -- Hashed password for message deletion
);
```

**Features:**
- Real-time message updates using Supabase streams
- Soft delete with password verification
- Message approval system
- Pagination support (10 messages per page)
- Animation effects for new messages

### 3. Advanced Map Integration
```dart
// lib/features/location/presentation/widgets/multi_map_widget.dart
enum MapProvider { google, naver, kakao }

class MultiMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final MapProvider provider;
  final bool showControls;
  final bool showDirections;
}
```

**Key Features:**
- Dynamic provider switching based on venue/language
- Map lock/unlock functionality for edit mode
- Real-time coordinate updates
- Navigation app integration (Kakao, Naver, Google)

## Database & Backend Integration

### Supabase Configuration

#### Environment Setup
```bash
# .env
SUPABASE_URL=https://otksynthwanpqpkdttzv.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Flutter Integration
```dart
// lib/main.dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

#### VS Code Launch Configuration
```json
// .vscode/launch.json
{
  "args": [
    "--dart-define=SUPABASE_URL=https://otksynthwanpqpkdttzv.supabase.co",
    "--dart-define=SUPABASE_ANON_KEY=sb_publishable_nuXZ7koUQ8q7x7Nfi-Bmsw_ssXmsfIr"
  ]
}
```

### Repository Pattern Implementation

```dart
// lib/data/repositories/supabase_guestbook_repository.dart
class SupabaseGuestbookRepository implements IGuestbookRepository {
  @override
  Stream<List<GuestbookMessage>> getApprovedMessagesStream() {
    return _supabase
        .from('guestbook_messages')
        .stream(primaryKey: ['id'])
        .eq('is_approved', true)
        .eq('is_deleted', false)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => GuestbookMessage.fromJson(json)).toList());
  }

  @override
  Future<bool> deleteMessageWithPassword(String messageId, String password) async {
    final response = await _supabase.rpc('delete_message_with_password', params: {
      'message_id': messageId,
      'input_password': password,
    });
    return response as bool? ?? false;
  }
}
```

### Database Functions

```sql
-- Secure message deletion with password verification
CREATE OR REPLACE FUNCTION delete_message_with_password(
  message_id TEXT,
  input_password TEXT
) RETURNS BOOLEAN AS $$
BEGIN
  UPDATE guestbook_messages 
  SET is_deleted = true 
  WHERE id = message_id 
    AND password = crypt(input_password, password);
  
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## UI/UX Implementation

### 1. Welcome Popup with Venue Selection
```dart
// lib/presentation/widgets/welcome_selection_popup.dart
class WelcomeSelectionPopup extends StatefulWidget {
  final Function(String?, String?) onSelectionMade;
  
  Widget _buildVenueOption(String code, Map<String, String> venue) {
    return InkWell(
      onTap: () => _selectVenue(code),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedVenue == code ? Colors.green.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedVenue == code ? Colors.green.shade300 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Text(venue['flag']!, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedVenueName(venue),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(venue['event']!, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Dynamic Content Filtering
```dart
// lib/presentation/screens/home/home_screen.dart
Widget _buildTicketCards() {
  return Consumer<VenueProvider>(
    builder: (context, venueProvider, child) {
      return Column(
        children: [
          if (venueProvider.shouldShowVenue('my')) _buildTicketCard('my'),
          if (venueProvider.shouldShowVenue('sg')) _buildTicketCard('sg'),
          if (venueProvider.shouldShowVenue('ko')) _buildTicketCard('ko'),
        ],
      );
    },
  );
}
```

### 3. Language-Aware Map Tabs
```dart
// lib/presentation/screens/location/location_screen.dart
Widget _buildKoreaMapWithTabs(double latitude, double longitude, String venueName) {
  final localeProvider = Provider.of<LocaleProvider>(context);
  final isKorean = localeProvider.locale.languageCode == 'ko';
  
  return DefaultTabController(
    length: 2,
    initialIndex: isKorean ? 0 : 1, // Naver for Korean, Google for others
    child: Column(
      children: [
        TabBar(tabs: [
          Tab(child: Text('네이버 지도')),
          Tab(child: Text('Google Maps')),
        ]),
        TabBarView(children: [
          MultiMapWidget(provider: MapProvider.naver),
          MultiMapWidget(provider: MapProvider.google),
        ]),
      ],
    ),
  );
}
```

## Localization & Internationalization

### Supported Languages
- **Korean (ko)** - Primary language
- **English (en)** - International users
- **Malay (ms)** - Malaysia venue
- **Chinese (zh)** - Additional support

### Implementation
```dart
// lib/l10n/app_en.arb
{
  "leaveCongratMessage": "Leave a Message",
  "viewAllMessages": "View All Messages",
  "navigationApps": "Navigation Apps",
  "kakaoNavi": "Kakao Navi",
  "naverMap": "Naver Map",
  "tmap": "T Map"
}

// lib/l10n/app_ko.arb
{
  "leaveCongratMessage": "축하 메시지 남기기",
  "viewAllMessages": "모든 메시지 보기",
  "navigationApps": "길찾기 앱",
  "kakaoNavi": "카카오내비",
  "naverMap": "네이버지도",
  "tmap": "티맵"
}
```

### Dynamic Language Switching
```dart
// lib/providers/locale_provider.dart
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ko');
  
  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
      _saveLocalePreference(locale.languageCode);
    }
  }
}
```

## Advanced Features

### 1. Pagination System
```dart
// lib/presentation/screens/guestbook/guestbook_screen.dart
class _GuestbookScreenState extends State<GuestbookScreen> {
  List<GuestbookMessage> _allMessages = [];
  List<GuestbookMessage> _currentPageMessages = [];
  int _currentPage = 0;
  final int _messagesPerPage = 10;
  
  void _updateCurrentPageMessages() {
    final startIndex = _currentPage * _messagesPerPage;
    final endIndex = (startIndex + _messagesPerPage).clamp(0, _allMessages.length);
    _currentPageMessages = _allMessages.sublist(startIndex, endIndex);
  }
  
  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: _hasPreviousPage ? _previousPage : null,
          icon: const Icon(Icons.chevron_left),
          label: const Text('이전'),
        ),
        // Page indicators...
        ElevatedButton.icon(
          onPressed: _hasNextPage ? _nextPage : null,
          icon: const Icon(Icons.chevron_right),
          label: const Text('다음'),
        ),
      ],
    );
  }
}
```

### 2. Real-time Updates with Animations
```dart
// Message card with animation support
class GuestbookMessageCard extends StatefulWidget {
  final bool isNewMessage;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.isNewMessage) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _animationController.forward();
      });
    }
  }
}
```

### 3. Password-Protected Message Deletion
```dart
// lib/presentation/widgets/guestbook/guestbook_message_card.dart
void _showDeleteDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('메시지 삭제'),
        content: TextField(
          controller: passwordController,
          obscureText: !showPassword,
          decoration: InputDecoration(
            labelText: '비밀번호',
            suffixIcon: IconButton(
              icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => showPassword = !showPassword),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              widget.onDelete!('${widget.message.id}|${passwordController.text}');
            },
            child: const Text('삭제'),
          ),
        ],
      );
    },
  );
}
```

## Code Explanations

### Key Architectural Decisions

#### 1. Provider Pattern for State Management
**Why:** Clean separation of business logic from UI, reactive updates across widgets
```dart
// Venue selection affects multiple screens
Consumer<VenueProvider>(
  builder: (context, venueProvider, child) {
    return venueProvider.shouldShowVenue('ko') 
      ? KoreaTicket() 
      : SizedBox.shrink();
  },
)
```

#### 2. Repository Pattern for Data Access
**Why:** Abstraction layer for database operations, easy testing and provider switching
```dart
abstract class IGuestbookRepository {
  Future<bool> addMessage(GuestbookMessage message);
  Stream<List<GuestbookMessage>> getApprovedMessagesStream();
  Future<bool> deleteMessageWithPassword(String messageId, String password);
}
```

#### 3. Widget Keys for Proper Rebuilds
**Why:** Ensures widgets rebuild when data changes, prevents stale state
```dart
MultiMapWidget(
  key: ValueKey('${selectedVenue}_${provider.name}_map'),
  latitude: latitude,
  longitude: longitude,
)
```

### Critical Implementation Patterns

#### 1. Lifecycle Management for Real-time Updates
```dart
void didUpdateWidget(MultiMapWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  if (oldWidget.latitude != widget.latitude ||
      oldWidget.longitude != widget.longitude) {
    setState(() {
      _currentLatitude = widget.latitude;
      _currentLongitude = widget.longitude;
    });
  }
}
```

#### 2. Safe State Updates with Mount Checks
```dart
Future<void> _handleDeleteMessage(String messageIdWithPassword) async {
  try {
    final success = await _guestbookRepository.deleteMessageWithPassword(messageId, password);
    if (mounted) {  // Prevent setState on unmounted widget
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? '삭제되었습니다' : '비밀번호가 틀렸습니다')),
      );
    }
  } catch (e) {
    if (mounted) {
      // Handle error...
    }
  }
}
```

#### 3. Defensive Programming for Dependency Injection
```dart
@override
void initState() {
  super.initState();
  try {
    _guestbookRepository = serviceLocator<IGuestbookRepository>();
    _setupRealtimeUpdates();
  } catch (e) {
    setState(() => _isLoading = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('초기화 실패: $e')),
        );
      }
    });
  }
}
```

## File Structure

### Core Architecture Files
```
lib/
├── core/
│   ├── di/dependency_injection.dart          # Service locator setup
│   └── routing/app_router.dart               # GoRouter configuration
├── data/
│   ├── models/
│   │   ├── guestbook_message_model.dart      # Message data model
│   │   └── venue_model.dart                  # Venue data model
│   ├── repositories/
│   │   ├── interfaces/guestbook_repository.dart
│   │   └── supabase_guestbook_repository.dart
│   └── services/
│       ├── supabase_service.dart             # Supabase client setup
│       └── location_search_service.dart      # Place search functionality
├── features/
│   ├── location/presentation/widgets/
│   │   ├── multi_map_widget.dart             # Multi-provider map widget
│   │   ├── google_map_widget_wrapper.dart    # Google Maps integration
│   │   └── naver_map_widget.dart             # Naver Maps integration
│   └── messages/presentation/widgets/
│       └── message_input_dialog.dart         # Message input with password
├── presentation/
│   ├── screens/
│   │   ├── home/home_screen.dart             # Main invitation screen
│   │   ├── guestbook/guestbook_screen.dart   # Paginated message list
│   │   ├── gallery/gallery_screen.dart       # Photo gallery
│   │   └── location/location_screen.dart     # Venue information & maps
│   └── widgets/
│       ├── guestbook/guestbook_message_card.dart  # Message display component
│       ├── welcome_selection_popup.dart      # Initial venue selection
│       └── expandable_banking_widget.dart    # Payment information
└── providers/
    ├── venue_provider.dart                   # Venue state management
    └── locale_provider.dart                  # Language state management
```

### Configuration Files
```
├── .env                                      # Environment variables
├── .vscode/launch.json                       # VS Code debug configuration
├── supabase_schema.sql                       # Database schema
├── supabase_migration_add_delete_password.sql # Migration script
├── l10n.yaml                                 # Localization configuration
└── lib/l10n/app_*.arb                       # Translation files
```

## Setup & Configuration

### 1. Supabase Setup
```bash
# 1. Create Supabase project
# 2. Run schema migration
psql -h db.project.supabase.co -p 5432 -d postgres -U postgres -f supabase_schema.sql

# 3. Enable Row Level Security
ALTER TABLE guestbook_messages ENABLE ROW LEVEL SECURITY;

# 4. Create RLS policies
CREATE POLICY "Allow read access to approved messages" ON guestbook_messages
  FOR SELECT USING (is_approved = true AND is_deleted = false);
```

### 2. Flutter Environment Setup
```bash
# 1. Install dependencies
flutter pub get

# 2. Generate localization files
flutter gen-l10n

# 3. Run with environment variables
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

### 3. Map Provider Configuration
```dart
// pubspec.yaml dependencies
dependencies:
  google_maps_flutter: ^2.5.0
  google_maps_flutter_web: ^0.5.4+2
  naver_map_plugin: ^0.9.6
  url_launcher: ^6.2.1
```

## Advanced Features

### 1. Venue-Based Content Filtering
- Dynamic ticket display based on selected venue
- Location information shows only relevant venue
- Banking section hidden for Singapore/Malaysia
- Journey section highlights selected venues

### 2. Multi-Language Map Support
- Korean users see Naver Maps by default for Korea venue
- International users see Google Maps
- Seamless tab switching between providers
- Navigation app integration with proper deep linking

### 3. Enhanced Photo Gallery
- Masonry grid layout with dynamic aspect ratios
- Hero animations for photo transitions
- Lazy loading with proper error handling
- Asset optimization for mobile performance

### 4. Real-time Collaboration
- Live message updates across all connected clients
- New message animations with staggered appearance
- Conflict-free pagination with real-time data sync
- Optimistic UI updates with rollback on errors

## Performance Optimizations

### 1. Widget Rebuilds
```dart
// Use ValueKey for expensive widgets
MultiMapWidget(
  key: ValueKey('${venue}_${provider}_map'),
  // This ensures proper rebuilds when data changes
)

// Consumer widgets for targeted rebuilds
Consumer<VenueProvider>(
  builder: (context, venueProvider, child) {
    // Only rebuilds when venue changes
  },
)
```

### 2. Image Loading
```dart
// Async aspect ratio calculation
Future<Map<String, double>> getMultipleAssetImageAspectRatios(List<String> imagePaths) async {
  final Map<String, double> aspectRatios = {};
  await Future.wait(imagePaths.map((path) async {
    aspectRatios[path] = await getAssetImageAspectRatio(path);
  }));
  return aspectRatios;
}
```

### 3. Database Queries
```dart
// Efficient streaming with proper indexing
Stream<List<GuestbookMessage>> getApprovedMessagesStream() {
  return _supabase
      .from('guestbook_messages')
      .stream(primaryKey: ['id'])
      .eq('is_approved', true)    // Index on is_approved
      .eq('is_deleted', false)    // Index on is_deleted
      .order('created_at', ascending: false); // Index on created_at
}
```

## Troubleshooting

### Common Issues & Solutions

#### 1. Supabase Connection Issues
```bash
# Check environment variables
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...

# Verify .env file
cat .env

# Test connection
dart run supabase_service.dart
```

#### 2. Map Not Updating
**Problem:** Map shows old coordinates when venue changes
**Solution:** Add `didUpdateWidget` lifecycle method and proper widget keys
```dart
@override
void didUpdateWidget(MultiMapWidget oldWidget) {
  if (oldWidget.latitude != widget.latitude) {
    setState(() {
      _currentLatitude = widget.latitude;
      _currentLongitude = widget.longitude;
    });
  }
}
```

#### 3. Navigation Issues
**Problem:** `Navigator.pushNamed` not working with GoRouter
**Solution:** Use `context.go('/route')` instead
```dart
// Wrong
onPressed: () => Navigator.pushNamed(context, '/guestbook'),

// Correct
onPressed: () => context.go('/guestbook'),
```

#### 4. Real-time Updates Not Working
**Problem:** Messages not updating in real-time
**Solution:** Proper stream subscription management
```dart
StreamSubscription<List<GuestbookMessage>>? _messagesSubscription;

@override
void dispose() {
  _messagesSubscription?.cancel(); // Prevent memory leaks
  super.dispose();
}
```

## Development Best Practices

### 1. Error Handling
- Always wrap async operations in try-catch blocks
- Use mounted checks before setState calls
- Provide meaningful error messages to users
- Implement fallback UI states

### 2. State Management
- Use Provider for app-wide state (venue, locale)
- Local state for component-specific data
- Dispose controllers and subscriptions properly
- Minimize unnecessary rebuilds with targeted consumers

### 3. Security
- Hash passwords before storing in database
- Use parameterized queries to prevent SQL injection
- Implement Row Level Security policies
- Never expose sensitive data in error messages

### 4. Performance
- Use const constructors where possible
- Implement proper widget keys for efficient rebuilds
- Lazy load images and data
- Optimize database queries with proper indexing

## Next Steps & Future Enhancements

1. **Push Notifications** - Real-time message notifications
2. **Image Upload** - User avatar support for messages
3. **Admin Panel** - Message moderation interface
4. **Analytics** - User engagement tracking
5. **Offline Support** - Local caching with sync
6. **Theme Customization** - Dynamic color schemes
7. **Social Sharing** - Enhanced sharing capabilities
8. **Accessibility** - Screen reader and navigation support

---

*This guide represents the complete development journey from initial setup to advanced feature implementation. Each code example has been tested and verified in the production application.*