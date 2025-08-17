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
        // Provide user-friendly error message
        String errorMessage = '검색 중 오류가 발생했습니다';
        if (e.toString().contains('XMLHttpRequest')) {
          errorMessage = '네트워크 연결을 확인해주세요';
        } else if (e.toString().contains('timeout')) {
          errorMessage = '검색 시간이 초과되었습니다';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showAddCustomVenueDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_location_alt, color: Colors.blue),
              SizedBox(width: 8),
              Text('사용자 정의 장소 추가'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '원하는 장소를 찾을 수 없으신가요? 직접 추가해보세요.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '장소명 *',
                  hintText: '예: 그랜드 웨딩홀',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: '주소 *',
                  hintText: '예: 서울특별시 강남구 테헤란로 123',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, 
                      size: 16, 
                      color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '추가된 장소는 이 세션에서만 사용됩니다.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty && 
                    addressController.text.trim().isNotEmpty) {
                  _addCustomVenue(nameController.text.trim(), addressController.text.trim());
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('장소명과 주소를 모두 입력해주세요'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void _addCustomVenue(String name, String address) {
    final customVenue = LocationSearchResult(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      address: address,
      latitude: 37.5665, // Default Seoul coordinates
      longitude: 126.9780,
      provider: 'custom',
    );
    
    widget.onLocationSelected(customVenue);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('사용자 정의 장소 "$name"이 추가되었습니다')),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '웨딩홀, 호텔, 이벤트홀 등을 검색하세요',
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
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: '원하는 장소를 찾을 수 없나요?\n직접 장소를 추가할 수 있습니다',
                    child: IconButton(
                      onPressed: _showAddCustomVenueDialog,
                      icon: Icon(
                        Icons.add_location_alt,
                        color: Colors.blue.shade600,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.rocket_launch, 
                            size: 18, 
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '🔥 실시간 Google Places 검색 사용하기',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Google Maps처럼 모든 장소를 실시간으로 검색하려면:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1. F12 키로 개발자 도구 열기',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              '2. Console 탭 클릭',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              '3. 다음 명령어 입력:',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              'testPlaceSearch("스타벅스 강남점")',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade800,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.info_outline, 
                            size: 14, 
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '실시간 검색을 Flutter에 완전히 통합하려면 추가 설정이 필요합니다',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.search, 
                            size: 16, 
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '현재 검색 가능한 장소들:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• 웨딩홀: Lotte Hotel, Shilla Hotel, Grand Hyatt 등\n• 이벤트홀: CJ BlossomPark, Seoul Arts Center 등\n• 해외: Marina Bay Sands, Ritz Carlton 등',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade600,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '검색 결과가 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '다른 검색어를 시도해보세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (kIsWeb) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Text(
                        '예시: "Lotte Hotel", "신라호텔", "Grand Hyatt", "웨딩홀"',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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