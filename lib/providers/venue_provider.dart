import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VenueProvider extends ChangeNotifier {
  static const String _venueKey = 'selected_venue';
  static const String _hasSelectedKey = 'has_made_selection';
  
  String? _selectedVenue;
  bool _hasUserMadeSelection = false;
  bool _isParentsMode = false;
  
  String? get selectedVenue => _selectedVenue;
  bool get hasUserMadeSelection => _hasUserMadeSelection;
  bool get isParentsMode => _isParentsMode;
  
  // Venue options
  static const Map<String, Map<String, String>> venueOptions = {
    'my': {
      'code': 'my',
      'name': 'Malaysia',
      'nameKo': '말레이시아',
      'flag': '🇲🇾',
      'date': 'Sep 12, 2025',
      'event': 'Dinner Party',
    },
    'sg': {
      'code': 'sg', 
      'name': 'Singapore',
      'nameKo': '싱가폴',
      'flag': '🇸🇬',
      'date': 'Nov 9, 2025',
      'event': 'Registry of Marriage',
    },
    'ko': {
      'code': 'ko',
      'name': 'South Korea', 
      'nameKo': '대한민국',
      'flag': '🇰🇷',
      'date': 'Nov 30, 2025',
      'event': 'After Party',
    },
    'all': {
      'code': 'all',
      'name': 'All Events',
      'nameKo': '모든 행사',
      'flag': '🌍',
      'date': 'All Dates',
      'event': 'Complete Journey',
    },
  };
  
  VenueProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Don't load preferences if we're going to be in parents mode
      // The URL parameters will set the correct state
      _selectedVenue = prefs.getString(_venueKey);
      _hasUserMadeSelection = prefs.getBool(_hasSelectedKey) ?? false;
      debugPrint('Loaded preferences: venue=$_selectedVenue, hasSelection=$_hasUserMadeSelection');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading venue preferences: $e');
    }
  }
  
  Future<void> setVenue(String? venue) async {
    if (_selectedVenue == venue) return;
    
    _selectedVenue = venue;
    _hasUserMadeSelection = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      if (venue != null) {
        await prefs.setString(_venueKey, venue);
      } else {
        await prefs.remove(_venueKey);
      }
      await prefs.setBool(_hasSelectedKey, true);
    } catch (e) {
      debugPrint('Error saving venue preference: $e');
    }
  }
  
  Future<void> setFromUrlParams(String? venueParam, {bool isParentsMode = false}) async {
    debugPrint('VenueProvider setFromUrlParams: isParentsMode=$isParentsMode, venueParam=$venueParam');
    _isParentsMode = isParentsMode;
    
    if (isParentsMode) {
      // For parents mode, force Malaysia venue and clear previous preferences
      _selectedVenue = 'my';
      _hasUserMadeSelection = true;
      debugPrint('Parents mode activated: venue set to my');
      
      // Clear previous preferences since parents mode overrides everything
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_venueKey);
        await prefs.remove(_hasSelectedKey);
        debugPrint('Cleared preferences for parents mode');
      } catch (e) {
        debugPrint('Error clearing preferences for parents mode: $e');
      }
    } else if (venueParam != null && venueOptions.containsKey(venueParam)) {
      _selectedVenue = venueParam;
      _hasUserMadeSelection = true;
      
      // Save preferences for normal mode
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_venueKey, _selectedVenue!);
        await prefs.setBool(_hasSelectedKey, true);
      } catch (e) {
        debugPrint('Error saving venue from URL: $e');
      }
    }
    
    notifyListeners();
  }
  
  bool shouldShowVenue(String venueCode) {
    // In parents mode, only show Malaysia
    if (_isParentsMode) {
      return venueCode == 'my';
    }
    return _selectedVenue == null || _selectedVenue == 'all' || _selectedVenue == venueCode;
  }
  
  bool shouldShowSelectionPopup() {
    // Don't show popup in parents mode
    return !_hasUserMadeSelection && !_isParentsMode;
  }
  
  void resetSelection() {
    _selectedVenue = null;
    _hasUserMadeSelection = false;
    notifyListeners();
    
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_venueKey);
      prefs.remove(_hasSelectedKey);
    });
  }
}