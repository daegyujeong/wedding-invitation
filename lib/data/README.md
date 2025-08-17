# Data Layer Architecture

This directory contains the data layer implementation following Clean Architecture principles.

## Structure

```
data/
├── models/           # Data models with serialization
│   ├── index.dart    # Centralized exports
│   ├── invitation_model.dart
│   ├── venue_model.dart
│   ├── message_model.dart
│   ├── guestbook_message_model.dart
│   ├── editor_widget_model.dart
│   ├── language_model.dart
│   ├── navigation_model.dart
│   └── page_model.dart
│
├── repositories/     # Repository pattern implementation
│   ├── index.dart    # Centralized exports
│   ├── interfaces/   # Abstract repository contracts
│   ├── guestbook_repository.dart
│   ├── message_repository.dart
│   └── saved_locations_repository.dart
│
└── services/         # External API and service integrations
    ├── index.dart    # Centralized exports
    ├── google_places_web_service.dart
    ├── location_search_service.dart
    └── map_service.dart
```

## Design Principles

### Models
- **Single Responsibility**: Each model represents one business entity
- **Immutability**: Models are immutable with copyWith methods
- **Serialization**: All models support JSON serialization/deserialization
- **Error Handling**: Robust parsing with fallback values
- **Multi-language Support**: Using MultiLanguageText for internationalization

### Repositories
- **Repository Pattern**: Abstract interfaces with concrete implementations
- **Dependency Inversion**: Depend on abstractions, not concretions
- **Single Data Source**: Each repository manages one type of data
- **Error Handling**: Graceful failure with meaningful error responses

### Services
- **External Integration**: Handle third-party API communications
- **Platform Abstraction**: Abstract platform-specific implementations
- **Async Operations**: All operations are asynchronous with proper error handling

## Usage

```dart
// Import all models
import 'package:wedding_invitation/data/models/index.dart';

// Import all repositories
import 'package:wedding_invitation/data/repositories/index.dart';

// Import all services
import 'package:wedding_invitation/data/services/index.dart';
```

## Key Features

### Multi-language Support
- `MultiLanguageText` class for internationalization
- Supports Korean, English, Chinese, Malay, Tamil
- Fallback to default language if translation missing

### Widget System
- Comprehensive editor widget system with 17+ widget types
- Inheritance-based widget architecture
- Type-safe widget creation and serialization
- Support for complex widgets (maps, galleries, countdown timers)

### Location Services
- Real-time Google Places API integration
- Support for multiple map providers (Google, Naver, Kakao)
- Location search with debouncing
- Coordinate-based venue management

### Data Persistence
- SharedPreferences for local storage
- JSON serialization for complex data structures
- Automatic data migration and error recovery