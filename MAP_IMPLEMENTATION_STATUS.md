# Map Implementation Status & Usage Guide

## Current Map Usage

### Primary Map Interface (Active)
**Location**: `lib/presentation/screens/home/home_screen.dart` (lines 1498+)
- **Status**: ✅ **ACTIVELY USED** - Main user interface
- **Implementation**: Embedded map section within home screen
- **Features**:
  - Venue tabs: Malaysia, Singapore, Korea
  - Language-based provider switching (Naver for Korean, Google for others)
  - Navigation buttons: Kakao, Naver, T-Map, Google Maps
  - Venue filtering based on selected venue from welcome popup

### Secondary Map Interface (Available but Unused)
**Location**: `lib/presentation/screens/location/location_screen.dart`
- **Status**: ⚠️ **DEFINED BUT NOT USED** - Accessible via `/location` route
- **Implementation**: Standalone location screen with detailed venue info
- **Features**:
  - Full venue cards with address, phone numbers
  - Interactive maps with dual Google/Naver tabs for Korea
  - Transportation guide (MRT, Cable Car, Car)
  - All venues view when no specific venue selected

## Recent Updates Applied To

### ✅ LocationScreen (Standalone `/location` page)
**Recent Enhancements**:
- Smaller Naver Maps markers (32x40px vs 48x60px)
- Address display instead of coordinates in marker info windows
- Specific Naver Maps place URL for 일월의정원
- Enhanced marker styling with custom SVG and animations

### ⚠️ HomeScreen (Main interface) - NOT UPDATED
**Current State**:
- Still uses basic map implementation
- May not have enhanced Naver Maps features
- Uses older marker styling and info windows

## Map Provider Implementation

### Google Maps
- **Web**: Uses Google Maps JavaScript API
- **Mobile**: Uses google_maps_flutter package
- **Wrapper**: `lib/features/location/presentation/widgets/google_map_widget_wrapper.dart`

### Naver Maps
- **Web**: Custom JavaScript implementation (`web/naver_map.js`)
- **Mobile**: Stub implementation (not fully supported)
- **Features**: Custom SVG markers, styled info windows, bounce animations
- **Korean Venue URL**: https://map.naver.com/p/entry/place/1391329941?c=15.00,0,0,0,dh&placePath=/home?from=map&fromPanelNum=1&additionalHeight=76&timestamp=202508311942&locale=ko&svcName=map_pcv5

### Kakao Maps
- **Status**: Placeholder implementation only
- **Display**: Shows "Kakao Map (Not Available)" message

## Venue Data Structure

```dart
static const Map<String, Map<String, dynamic>> _venues = {
  'my': {
    'name': 'AC Hotel Kuantan',
    'latitude': 3.816691981866172,
    'longitude': 103.33681728473105,
    'address': 'Jalan Teluk Sisek, Kuantan, Pahang, Malaysia',
  },
  'sg': {
    'name': 'Arbora',
    'latitude': 1.2713102232292395,
    'longitude': 103.81929169938385,
    'address': '109 Mount Faber Road, Singapore 099203',
  },
  'ko': {
    'name': '일월의정원',
    'latitude': 35.62885057440548,
    'longitude': 129.21897305040977,
    'address': '울산광역시 울주군 두동면 은편리 891',
  },
};
```

## Navigation Routes

### Available Routes
- `/` - Home screen (primary interface with embedded maps)
- `/location` - Standalone location screen (detailed venue info)
- `/gallery` - Photo gallery
- `/guestbook` - Guest messages
- `/share` - Social sharing

### Menu Access
- **Invitation Screen**: Has menu item linking to `/location` route
- **Home Screen**: Direct embedded map interaction (no navigation needed)

## Action Items for Consistency

### If HomeScreen Maps Need Enhancement:
1. **Apply Naver Maps enhancements to HomeScreen**:
   - Update `MultiMapWidget` instances in home_screen.dart
   - Add address parameter support
   - Ensure consistent marker styling
   - Apply specific Korean venue URL

2. **Coordinate Updates**:
   - HomeScreen uses: `35.62885057440548, 129.21897305040977`
   - LocationScreen uses: `35.6288349, 129.2087028` (more precise)
   - Consider standardizing coordinates across both screens

3. **Feature Parity**:
   - Transportation guide (currently only in LocationScreen)
   - Enhanced info windows with addresses
   - Consistent navigation button styling

### If LocationScreen Should Be Removed:
1. **Remove unused route** from router configuration
2. **Remove menu item** from invitation screen
3. **Keep only HomeScreen** map implementation
4. **Move any unique features** from LocationScreen to HomeScreen if needed

## File Locations

### Core Map Files
- `lib/features/location/presentation/widgets/multi_map_widget.dart` - Main widget
- `lib/features/location/presentation/widgets/naver_map_widget.dart` - Naver interface
- `lib/features/location/presentation/widgets/naver_map_widget_web.dart` - Web implementation
- `web/naver_map.js` - JavaScript implementation

### Screen Files
- `lib/presentation/screens/home/home_screen.dart` - **PRIMARY INTERFACE**
- `lib/presentation/screens/location/location_screen.dart` - Secondary interface

### Configuration Files
- `lib/core/routing/app_router.dart` - Route definitions
- `lib/providers/venue_provider.dart` - Venue state management
- `lib/providers/locale_provider.dart` - Language state management