import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../data/services/location_search_service.dart';
import 'multi_map_widget.dart';

class LocationSearchWidget extends StatefulWidget {
  final MapProvider provider;
  final Function(LocationSearchResult) onLocationSelected;
  final String? initialQuery;

  const LocationSearchWidget({
    super.key,
    required this.provider,
    required this.onLocationSelected,
    this.initialQuery,
  });

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final LocationSearchService _searchService = LocationSearchService();
  List<LocationSearchResult> _searchResults = [];
  bool _isLoading = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
  }

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showResults = true;
    });

    try {
      final results = await _searchService.search(
        _searchController.text,
        widget.provider.toString().split('.').last,
      );
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '장소를 검색하세요',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _showResults = false;
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    setState(() {
                      _searchResults = [];
                      _showResults = false;
                    });
                  }
                },
                onSubmitted: (_) => _performSearch(),
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, 
                        size: 16, 
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '웹에서는 주요 장소만 검색 가능합니다.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_showResults) ...[
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else if (_searchResults.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('검색 결과가 없습니다.'),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: _getProviderColor(result.provider),
                    ),
                    title: Text(
                      result.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      result.address,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getProviderColor(result.provider).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        result.provider.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: _getProviderColor(result.provider),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      widget.onLocationSelected(result);
                      setState(() {
                        _showResults = false;
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ],
    );
  }

  Color _getProviderColor(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return Colors.blue;
      case 'kakao':
        return Colors.yellow.shade700;
      case 'naver':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}