import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/models/editor_widget_model.dart' as model;

class MapEditorDialog extends StatefulWidget {
  final model.MapWidget mapWidget;

  const MapEditorDialog({
    super.key,
    required this.mapWidget,
  });

  @override
  State<MapEditorDialog> createState() => _MapEditorDialogState();
}

class _MapEditorDialogState extends State<MapEditorDialog> {
  late TextEditingController _venueController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late String _selectedProvider;
  late bool _showDirections;
  late bool _showControls;

  @override
  void initState() {
    super.initState();
    _venueController = TextEditingController(text: widget.mapWidget.venue);
    _latitudeController = TextEditingController(
      text: widget.mapWidget.latitude.toString(),
    );
    _longitudeController = TextEditingController(
      text: widget.mapWidget.longitude.toString(),
    );
    _selectedProvider = widget.mapWidget.mapProvider;
    _showDirections = widget.mapWidget.showDirections;
    _showControls = widget.mapWidget.showControls;
  }

  @override
  void dispose() {
    _venueController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('지도 위젯 설정'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Provider Selection
            const Text(
              '지도 제공자',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildProviderChip('google', 'Google Maps', Colors.blue),
                const SizedBox(width: 8),
                _buildProviderChip('naver', 'Naver Maps', Colors.green),
                const SizedBox(width: 8),
                _buildProviderChip('kakao', 'Kakao Maps', Colors.yellow.shade700),
              ],
            ),
            const SizedBox(height: 16),

            // Venue Name
            TextField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: '장소명',
                hintText: '결혼식장 이름을 입력하세요',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 16),

            // Coordinates
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: '위도',
                      hintText: '37.5665',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.gps_fixed),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^-?\d*\.?\d*'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: '경도',
                      hintText: '126.9780',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.gps_fixed),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^-?\d*\.?\d*'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Popular Locations
            const Text(
              '주요 장소',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildLocationChip('서울시청', 37.5665, 126.9780),
                _buildLocationChip('부산역', 35.1153, 129.0413),
                _buildLocationChip('제주공항', 33.5070, 126.4923),
              ],
            ),
            const SizedBox(height: 16),

            // Options
            SwitchListTile(
              title: const Text('길찾기 버튼 표시'),
              subtitle: const Text('각 지도 앱으로 연결되는 버튼을 표시합니다'),
              value: _showDirections,
              onChanged: (value) {
                setState(() {
                  _showDirections = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('지도 컨트롤 표시'),
              subtitle: const Text('확대/축소 등 지도 조작 버튼을 표시합니다'),
              value: _showControls,
              onChanged: (value) {
                setState(() {
                  _showControls = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('저장'),
        ),
      ],
    );
  }

  Widget _buildProviderChip(String provider, String label, Color color) {
    final isSelected = _selectedProvider == provider;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedProvider = provider;
          });
        }
      },
    );
  }

  Widget _buildLocationChip(String label, double lat, double lng) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _latitudeController.text = lat.toString();
          _longitudeController.text = lng.toString();
        });
      },
    );
  }

  void _saveChanges() {
    final venue = _venueController.text.trim();
    final latitudeStr = _latitudeController.text.trim();
    final longitudeStr = _longitudeController.text.trim();

    if (venue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장소명을 입력해주세요')),
      );
      return;
    }

    try {
      final latitude = double.parse(latitudeStr);
      final longitude = double.parse(longitudeStr);

      // Validate coordinates
      if (latitude < -90 || latitude > 90) {
        throw const FormatException('위도는 -90에서 90 사이여야 합니다');
      }
      if (longitude < -180 || longitude > 180) {
        throw const FormatException('경도는 -180에서 180 사이여야 합니다');
      }

      // Update widget data
      widget.mapWidget.setLocation(latitude, longitude, venue);
      widget.mapWidget.setMapProvider(_selectedProvider);
      widget.mapWidget.data['showDirections'] = _showDirections;
      widget.mapWidget.data['showControls'] = _showControls;

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('올바른 좌표를 입력해주세요: $e')),
      );
    }
  }
}
