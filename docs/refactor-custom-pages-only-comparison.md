# Branch Comparison: main vs refactor/custom-pages-only

## Overview
This document summarizes the differences between the current `main` branch and the `refactor/custom-pages-only` branch.

## Key Changes Summary

### 1. **Project Management & Development Workflow**
- **Added Task Master AI Integration**
  - `.taskmaster/` directory with configuration and task management
  - `CLAUDE.md` - Claude Code integration guide
  - Multiple IDE-specific configurations (`.clinerules/`, `.cursor/`, `.windsurf/`, etc.)
  - Development workflow documentation across multiple directories

### 2. **Core Application Architecture**

#### New Core Structure
- **Routing**: Added `lib/core/routes/app_router.dart`
- **Utilities**: 
  - `lib/core/utils/date_formatter.dart`
  - `lib/core/utils/debug_helper.dart`
  - `lib/core/utils/validators.dart`
- **Configuration**: `lib/core/config/environment.dart` for environment variables
- **Common Widgets**:
  - `lib/core/widgets/empty_widget.dart`
  - `lib/core/widgets/loading_widget.dart`

### 3. **Feature Modules (New Structure)**

#### Gallery Feature
- `lib/features/gallery/presentation/screens/gallery_screen.dart`
- `lib/features/gallery/presentation/widgets/photo_viewer.dart`

#### Location Feature
- **Screens**:
  - `combined_map_screen.dart` - Multi-map view
  - `google_map_screen.dart`, `kakao_map_screen.dart`, `naver_map_screen.dart`
  - `location_screen.dart` - Main location feature
  - `map_test_screen.dart` - Testing interface
- **Widgets**:
  - Map widgets for Google, Kakao, and Naver
  - `location_search_widget.dart` - Advanced location search
  - `multi_map_widget.dart` - Combined map display
  - `map_navigation_helper.dart` - Navigation utilities
  - `transport_info.dart` - Transportation information

#### Messages Feature
- `lib/features/messages/presentation/screens/messages_screen.dart`
- `lib/features/messages/presentation/widgets/message_card.dart`
- `lib/features/messages/presentation/widgets/message_input_dialog.dart`

#### Invitation Feature
- `lib/features/invitation/presentation/screens/invitation_view_screen.dart`

#### Share Feature
- `lib/features/share/presentation/screens/share_screen.dart`

### 4. **Data Layer Changes**

#### Removed Models
- `lib/data/models/custom_widget_model.dart` - Completely removed

#### Updated Models
- **`editor_widget_model.dart`**: Significantly expanded (580+ lines added)
- **`message_model.dart`**: Modified structure
- **`venue_model.dart`**: Enhanced with new properties
- **`page_model.dart`**: Updated structure
- **`navigation_model.dart`**: Minor updates

#### New Services
- **`location_search_service.dart`**: Comprehensive location search (1269+ lines)
- **`saved_locations_repository.dart`**: Location persistence

#### Removed Services
- `widget_template_service.dart` - Removed entirely

### 5. **Editor System Overhaul**

#### Removed
- `custom_page_editor_screen.dart`
- `widget_editor_dialog.dart`
- `custom_widget_factory.dart`

#### Enhanced/Added
- **`custom_draggable_editor.dart`**: Massively expanded (2300+ lines)
- **New Editor Components**:
  - `common_editor_fields.dart` - Reusable editor fields
  - `enhanced_size_editor.dart` - Advanced size editing
  - `map_editor_dialog.dart` - Map-specific editing
  - `draggable_widget_controller.dart` - Widget control logic
- **`widget_renderer.dart`**: Significantly expanded (900+ lines added)
- **`widget_selector_screen.dart`**: Enhanced functionality

### 6. **Web Platform Enhancements**
- `web/google_maps_style_fix.js` - Google Maps styling fixes
- `web/suppress_maps_warning.js` - Warning suppression
- Enhanced `index.html` with additional scripts

### 7. **Documentation**
- **New Documentation**:
  - `Google_Maps_Flutter_Web_Issues_Solutions.md`
  - `PROJECT_STATUS.md`
  - `TESTING_MAPS.md`
  - `TROUBLESHOOTING_JSON.md`
  - `docs/API_KEYS_SETUP.md`
  - `docs/MAP_SETUP_GUIDE.md`
- **Enhanced README.md**

### 8. **Dependencies & Configuration**
- **New Dependencies** (in pubspec.yaml):
  - Map-related packages (google_maps_flutter, etc.)
  - HTTP and API packages
  - Additional UI/UX packages
- **Environment Configuration**:
  - `.env.example` for API keys
  - Platform-specific configurations (iOS Info.plist, Android manifest)

### 9. **Testing & Development Tools**
- Removed basic `test/widget_test.dart`
- Added comprehensive testing documentation
- Multiple MCP (Model Context Protocol) configurations

## Major Architectural Shifts

1. **From Custom Widgets to Feature Modules**: The branch shows a complete restructuring from a custom widget-based architecture to a feature-based modular architecture.

2. **Multi-Map Integration**: Added support for Google Maps, Kakao Maps, and Naver Maps with a unified interface.

3. **Enhanced Editor System**: Complete overhaul of the widget editing system with better controls, draggable functionality, and enhanced size editing.

4. **Task Management Integration**: Full integration with Task Master AI for project management and development workflow.

5. **Improved Web Support**: Specific fixes and enhancements for web platform, especially for map rendering.

## Migration Considerations

1. **Breaking Changes**:
   - Removal of `custom_widget_model.dart`
   - Complete restructuring of editor components
   - Service layer changes

2. **New Requirements**:
   - API keys for map services
   - Environment configuration setup
   - Task Master AI setup (optional)

3. **Data Migration**:
   - Widget models need to be migrated to new `editor_widget_model.dart` structure
   - Location data structure changes
   - Message model updates

## Conclusion

The `refactor/custom-pages-only` branch represents a major architectural overhaul focusing on:
- Feature-based modular structure
- Enhanced map integration
- Improved editor capabilities
- Better development workflow with AI integration
- Comprehensive documentation

This refactoring significantly improves the codebase organization, adds powerful new features (especially maps), and provides better developer experience with extensive tooling and documentation.