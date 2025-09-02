// lib/presentation/widgets/location/google_place_picker_web.dart
import 'package:flutter/material.dart';
import '../../../data/services/google_places_web_service.dart';
import '../../../data/models/location_model.dart';

class GooglePlacePickerWeb extends StatefulWidget {
  final Function(LocationModel) onPlacePicked;
  final String? initialQuery;
  final String? hintText;
  final Widget? searchIcon;
  final bool showSearchButton;

  const GooglePlacePickerWeb({
    super.key,
    required this.onPlacePicked,
    this.initialQuery,
    this.hintText = '장소를 검색하세요...',
    this.searchIcon,
    this.showSearchButton = true,
  });

  @override
  State<GooglePlacePickerWeb> createState() => _GooglePlacePickerWebState();
}

class _GooglePlacePickerWebState extends State<GooglePlacePickerWeb> {
  final TextEditingController _searchController = TextEditingController();
  final GooglePlacesWebService _placesService = GooglePlacesWebService();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = false;
  bool _showResults = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    
    // Add listener for text changes to trigger search
    _searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_searchController.text.length > 2) {
      _performSearch(_searchController.text);
    } else if (_searchController.text.isEmpty) {
      setState(() {
        _predictions = [];
        _showResults = false;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _showResults = true;
    });

    try {
      final predictions = await _placesService.getPlacePredictions(query);
      
      if (mounted) {
        setState(() {
          _predictions = predictions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _predictions = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('검색 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  Future<void> _selectPlace(Map<String, dynamic> prediction) async {
    final placeId = prediction['place_id'];
    if (placeId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final placeDetails = await _placesService.getPlaceDetails(placeId);
      
      if (placeDetails != null && mounted) {
        final location = LocationModel(
          id: placeId,
          name: placeDetails['name'] ?? prediction['description'] ?? '',
          address: placeDetails['formatted_address'] ?? prediction['description'] ?? '',
          latitude: placeDetails['geometry']?['location']?['lat']?.toDouble() ?? 0.0,
          longitude: placeDetails['geometry']?['location']?['lng']?.toDouble() ?? 0.0,
          placeId: placeId,
          phoneNumber: placeDetails['formatted_phone_number'],
          website: placeDetails['website'],
        );
        
        _searchController.text = location.name;
        setState(() {
          _showResults = false;
          _isLoading = false;
        });
        
        widget.onPlacePicked(location);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('장소 정보를 가져오는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _predictions = [];
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Search icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: widget.searchIcon ?? 
                  Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
              ),
              
              // Text input
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _performSearch(value);
                    }
                  },
                ),
              ),
              
              // Clear button
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                ),
              
              // Search button
              if (widget.showSearchButton)
                Container(
                  margin: const EdgeInsets.all(4),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      if (_searchController.text.isNotEmpty) {
                        _performSearch(_searchController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('검색'),
                  ),
                ),
            ],
          ),
        ),
        
        // Search results
        if (_showResults)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _predictions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            '검색 결과가 없습니다',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _predictions.length,
                        itemBuilder: (context, index) {
                          final prediction = _predictions[index];
                          return _buildPredictionItem(prediction);
                        },
                      ),
          ),
      ],
    );
  }

  Widget _buildPredictionItem(Map<String, dynamic> prediction) {
    final mainText = prediction['structured_formatting']?['main_text'] ?? 
                     prediction['description'] ?? '';
    final secondaryText = prediction['structured_formatting']?['secondary_text'] ?? '';
    final types = prediction['types'] as List<dynamic>? ?? [];
    
    IconData icon = Icons.place;
    if (types.contains('establishment')) {
      icon = Icons.business;
    } else if (types.contains('geocode')) {
      icon = Icons.location_on;
    }

    return InkWell(
      onTap: () => _selectPlace(prediction),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            // Location icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.blue.shade600,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Place details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  if (secondaryText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        secondaryText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}