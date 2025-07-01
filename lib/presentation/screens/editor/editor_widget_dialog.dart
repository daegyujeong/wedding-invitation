import 'package:flutter/material.dart';
import '../../../data/models/editor_widget_model.dart';
import '../../widgets/editor/enhanced_size_editor.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditorWidgetDialog extends StatefulWidget {
  final EditorWidget widget;
  final Function(EditorWidget) onSave;

  const EditorWidgetDialog({
    super.key,
    required this.widget,
    required this.onSave,
  });

  @override
  _EditorWidgetDialogState createState() => _EditorWidgetDialogState();
}

class _EditorWidgetDialogState extends State<EditorWidgetDialog> {
  late EditorWidget _editedWidget;
  late Map<String, dynamic> _editedData;

  @override
  void initState() {
    super.initState();
    _editedWidget = widget.widget;
    _editedData = Map.from(widget.widget.data);
  }

  void _updateData(String key, dynamic value) {
    setState(() {
      _editedData[key] = value;
    });
  }

  void _saveChanges() {
    // Create a new widget with updated data
    EditorWidget updatedWidget;

    switch (_editedWidget.type) {
      case WidgetType.Text:
        updatedWidget = TextWidget(id: _editedWidget.id, data: _editedData);
        break;
      case WidgetType.DDay:
        updatedWidget = DDayWidget(id: _editedWidget.id, data: _editedData);
        break;
      case WidgetType.CountdownTimer:
        updatedWidget =
            CountdownWidget(id: _editedWidget.id, data: _editedData);
        break;
      case WidgetType.Image:
        updatedWidget = ImageWidget(id: _editedWidget.id, data: _editedData);
        break;
      case WidgetType.Gallery:
        updatedWidget = GalleryWidget(id: _editedWidget.id, data: _editedData);
        break;
      case WidgetType.Map:
        updatedWidget = MapWidget(id: _editedWidget.id, data: _editedData);
        break;
      case WidgetType.Schedule:
        updatedWidget = ScheduleWidget(id: _editedWidget.id, data: _editedData);
        break;
    }

    widget.onSave(updatedWidget);
    Navigator.of(context).pop();
  }

  String _getWidgetTypeName(WidgetType type) {
    // Check if it's a special text widget (button, video)
    if (type == WidgetType.Text && _editedData['isVideo'] == true) {
      return '비디오 설정';
    } else if (type == WidgetType.Text && _editedData['action'] != null) {
      return '버튼 설정';
    }

    switch (type) {
      case WidgetType.Text:
        return '텍스트 편집';
      case WidgetType.DDay:
        return 'D-day 설정';
      case WidgetType.CountdownTimer:
        return '카운트다운 설정';
      case WidgetType.Image:
        return '이미지 설정';
      case WidgetType.Gallery:
        return '갤러리 설정';
      case WidgetType.Map:
        return '지도 설정';
      case WidgetType.Schedule:
        return '일정 설정';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_getWidgetTypeName(_editedWidget.type)),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: _buildEditorFields(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _saveChanges,
          child: const Text('저장'),
        ),
      ],
    );
  }

  Widget _buildEditorFields() {
    // Check if it's a special text widget
    if (_editedWidget.type == WidgetType.Text) {
      if (_editedData['isVideo'] == true) {
        return _buildVideoEditorFields();
      } else if (_editedData['action'] != null) {
        return _buildButtonEditorFields();
      }
    }

    switch (_editedWidget.type) {
      case WidgetType.Text:
        return _buildTextEditorFields();
      case WidgetType.DDay:
        return _buildDDayEditorFields();
      case WidgetType.CountdownTimer:
        return _buildCountdownEditorFields();
      case WidgetType.Image:
        return _buildImageEditorFields();
      case WidgetType.Gallery:
        return _buildGalleryEditorFields();
      case WidgetType.Map:
        return _buildMapEditorFields();
      case WidgetType.Schedule:
        return _buildScheduleEditorFields();
    }
  }

  Widget _buildTextEditorFields() {
    // Handle text input - support both simple string and multilingual text
    String currentText = '';
    if (_editedData['text'] is String) {
      currentText = _editedData['text'];
    } else if (_editedData['text'] is Map) {
      currentText =
          _editedData['text']['ko'] ?? _editedData['text']['en'] ?? '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('텍스트'),
        TextField(
          controller: TextEditingController(text: currentText),
          decoration: const InputDecoration(
            hintText: '텍스트를 입력하세요',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            // Update both string and multilingual format
            _updateData('text', value);
            _updateData('text', {'ko': value, 'en': value});
          },
        ),
        const SizedBox(height: 16),
        const Text('글자 크기'),
        Slider(
          value: (_editedData['fontSize'] as num?)?.toDouble() ?? 16.0,
          min: 10,
          max: 40,
          divisions: 30,
          label: "${(_editedData['fontSize'] as num?)?.toDouble() ?? 16.0}",
          onChanged: (value) => _updateData('fontSize', value),
        ),
        const SizedBox(height: 16),
        const Text('글꼴'),
        DropdownButton<String>(
          value: _editedData['fontFamily']?.toString() ?? 'Roboto',
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
            DropdownMenuItem(
                value: 'Noto Sans KR', child: Text('Noto Sans KR')),
            DropdownMenuItem(value: 'Arial', child: Text('Arial')),
            DropdownMenuItem(value: 'Helvetica', child: Text('Helvetica')),
          ],
          onChanged: (value) => _updateData('fontFamily', value),
        ),
        const SizedBox(height: 16),
        const Text('색상'),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _parseColor(_editedData['color']?.toString() ?? '#000000'),
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () => _showColorPicker('color'),
            child: const Center(
              child: Text('색상 선택', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonEditorFields() {
    String currentText = '';
    if (_editedData['text'] is Map) {
      currentText = _editedData['text']['ko'] ?? '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('버튼 텍스트'),
        TextField(
          controller: TextEditingController(text: currentText),
          decoration: const InputDecoration(
            hintText: '버튼 텍스트를 입력하세요',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _updateData('text', {'ko': value, 'en': value});
          },
        ),
        const SizedBox(height: 16),
        const Text('버튼 동작'),
        DropdownButton<String>(
          value: _editedData['action']?.toString() ?? 'url',
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'url', child: Text('URL 열기')),
            DropdownMenuItem(value: 'phone', child: Text('전화 걸기')),
            DropdownMenuItem(value: 'sms', child: Text('문자 보내기')),
            DropdownMenuItem(value: 'email', child: Text('이메일 보내기')),
            DropdownMenuItem(value: 'map', child: Text('지도 열기')),
            DropdownMenuItem(value: 'bookmark', child: Text('북마크')),
          ],
          onChanged: (value) => _updateData('action', value),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(
              text: _editedData['actionTarget']?.toString() ?? ''),
          decoration: const InputDecoration(
            labelText: '대상 (URL/전화번호/이메일 등)',
            hintText: '예: https://example.com',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _updateData('actionTarget', value),
        ),
        const SizedBox(height: 16),
        const Text('배경 색상'),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _parseColor(
                _editedData['backgroundColor']?.toString() ?? '#4285F4'),
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () => _showColorPicker('backgroundColor'),
            child: const Center(
              child: Text('배경 색상 선택', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('텍스트 색상'),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _parseColor(_editedData['color']?.toString() ?? '#FFFFFF'),
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () => _showColorPicker('color'),
            child: Center(
              child: Text(
                '텍스트 색상 선택',
                style: TextStyle(
                  color: _getContrastingColor(
                    _parseColor(_editedData['color']?.toString() ?? '#FFFFFF'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoEditorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('비디오 URL'),
        TextField(
          controller: TextEditingController(
              text: _editedData['videoUrl']?.toString() ?? ''),
          decoration: const InputDecoration(
            hintText: 'https://example.com/video.mp4',
            helperText: 'MP4 형식의 비디오 URL을 입력하세요',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _updateData('videoUrl', value),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('자동 재생'),
          value: _editedData['autoPlay'] ?? false,
          onChanged: (value) => _updateData('autoPlay', value),
        ),
        SwitchListTile(
          title: const Text('반복 재생'),
          value: _editedData['loop'] ?? false,
          onChanged: (value) => _updateData('loop', value),
        ),
        SwitchListTile(
          title: const Text('음소거'),
          value: _editedData['muted'] ?? false,
          onChanged: (value) => _updateData('muted', value),
        ),
      ],
    );
  }

  Widget _buildDDayEditorFields() {
    DateTime currentDate;
    try {
      currentDate = DateTime.parse(_editedData['targetDate']?.toString() ?? '');
    } catch (e) {
      currentDate = DateTime.now().add(const Duration(days: 30));
      _updateData('targetDate', currentDate.toIso8601String());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('표시 형식:'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _editedData['format']?.toString() ?? '결혼식까지 {days}일',
          isExpanded: true,
          items: const [
            DropdownMenuItem(
                value: '결혼식까지 {days}일', child: Text('결혼식까지 {days}일')),
            DropdownMenuItem(value: 'D-{days}', child: Text('D-{days}')),
            DropdownMenuItem(value: '{days}일 남음', child: Text('{days}일 남음')),
            DropdownMenuItem(
                value: '{days} days to go', child: Text('{days} days to go')),
          ],
          onChanged: (value) => _updateData('format', value),
        ),
        const SizedBox(height: 16),
        const Text('스타일:'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _editedData['style']?.toString() ?? '기본',
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: '기본', child: Text('기본')),
            DropdownMenuItem(value: '우아한', child: Text('우아한')),
            DropdownMenuItem(value: '현대적', child: Text('현대적')),
            DropdownMenuItem(value: '귀여운', child: Text('귀여운')),
          ],
          onChanged: (value) => _updateData('style', value),
        ),
        const SizedBox(height: 16),
        const Text('목표 날짜:'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );

              if (pickedDate != null) {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(currentDate),
                );

                if (pickedTime != null) {
                  final newDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  _updateData('targetDate', newDateTime.toIso8601String());
                }
              }
            },
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  '${currentDate.year}년 ${currentDate.month}월 ${currentDate.day}일 ${currentDate.hour}:${currentDate.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(
              text: _editedData['title']?.toString() ?? 'D-Day'),
          decoration: const InputDecoration(
            labelText: '제목',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _updateData('title', value),
        ),
      ],
    );
  }

  Widget _buildCountdownEditorFields() {
    DateTime currentDate;
    try {
      currentDate = DateTime.parse(_editedData['targetDate']?.toString() ?? '');
    } catch (e) {
      currentDate = DateTime.now().add(const Duration(days: 30));
      _updateData('targetDate', currentDate.toIso8601String());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('목표 날짜:'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );

              if (pickedDate != null) {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(currentDate),
                );

                if (pickedTime != null) {
                  final newDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  _updateData('targetDate', newDateTime.toIso8601String());
                }
              }
            },
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Text(
                  '${currentDate.year}년 ${currentDate.month}월 ${currentDate.day}일 ${currentDate.hour}:${currentDate.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('표시 형식:'),
        DropdownButton<String>(
          value: _editedData['format']?.toString() ?? 'countdown',
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'countdown', child: Text('카운트다운')),
            DropdownMenuItem(value: 'simple', child: Text('간단')),
            DropdownMenuItem(value: 'detailed', child: Text('상세')),
          ],
          onChanged: (value) => _updateData('format', value),
        ),
      ],
    );
  }

  Widget _buildImageEditorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('이미지 선택:'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _editedData['imageUrl']?.toString() ??
              'assets/images/placeholder.png',
          isExpanded: true,
          items: const [
            DropdownMenuItem(
                value: 'assets/images/placeholder.png', child: Text('플레이스홀더')),
            DropdownMenuItem(
                value: 'assets/images/gallery1.jpg', child: Text('갤러리 이미지 1')),
            DropdownMenuItem(
                value: 'assets/images/gallery2.jpg', child: Text('갤러리 이미지 2')),
            DropdownMenuItem(
                value: 'assets/images/gallery3.jpg', child: Text('갤러리 이미지 3')),
            DropdownMenuItem(
                value: 'assets/images/background.png', child: Text('배경 이미지')),
          ],
          onChanged: (value) => _updateData('imageUrl', value),
        ),
        const SizedBox(height: 24),

        // Enhanced Size Controls
        const Text(
          '이미지 크기',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 350, // Fixed height for AlertDialog compatibility
          child: SingleChildScrollView(
            child: EnhancedSizeEditor(
              width: (_editedData['width'] as num?)?.toDouble() ?? 200.0,
              height: (_editedData['height'] as num?)?.toDouble() ?? 200.0,
              onSizeChanged: (width, height) {
                _updateData('width', width);
                _updateData('height', height);
              },
              minWidth: 50,
              maxWidth: 400,
              minHeight: 50,
              maxHeight: 400,
              showRatioControls: true,
              showPresets: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryEditorFields() {
    List<String> imageUrls = [];
    try {
      imageUrls = List<String>.from(_editedData['imageUrls'] ?? []);
    } catch (e) {
      imageUrls = ['assets/images/placeholder.png'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('갤러리 스타일:'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _editedData['style']?.toString() ?? 'carousel',
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'carousel', child: Text('캐러셀 (슬라이드)')),
            DropdownMenuItem(value: 'grid', child: Text('그리드 (격자)')),
            DropdownMenuItem(value: 'masonry', child: Text('메이슨리 (벽돌)')),
            DropdownMenuItem(value: 'modern', child: Text('모던 (오버레이)')),
          ],
          onChanged: (value) => _updateData('style', value),
        ),
        const SizedBox(height: 16),
        const Text('갤러리 이미지:'),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length + 1,
            itemBuilder: (context, index) {
              if (index == imageUrls.length) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _showImageSelectionDialog((selectedImage) {
                        imageUrls.add(selectedImage);
                        _updateData('imageUrls', imageUrls);
                      });
                    },
                  ),
                );
              }

              return Stack(
                children: [
                  Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        imageUrls.removeAt(index);
                        _updateData('imageUrls', imageUrls);
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_editedData['style'] == 'carousel') ...[
          SwitchListTile(
            title: const Text('인디케이터 표시'),
            value: _editedData['showIndicators'] ?? true,
            onChanged: (value) => _updateData('showIndicators', value),
          ),
          SwitchListTile(
            title: const Text('자동 재생'),
            value: _editedData['autoPlay'] ?? false,
            onChanged: (value) => _updateData('autoPlay', value),
          ),
        ],
      ],
    );
  }

  Widget _buildMapEditorFields() {
    double latitude = (_editedData['latitude'] as num?)?.toDouble() ?? 37.5665;
    double longitude =
        (_editedData['longitude'] as num?)?.toDouble() ?? 126.9780;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('장소 이름:'),
        TextField(
          controller: TextEditingController(
              text: _editedData['venue']?.toString() ?? ''),
          decoration: const InputDecoration(
            hintText: '예: 그랜드 호텔',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _updateData('venue', value);
            _updateData('title', value); // Also update title
          },
        ),
        const SizedBox(height: 16),
        const Text('위도:'),
        TextField(
          controller: TextEditingController(text: latitude.toString()),
          decoration: const InputDecoration(
            hintText: '예: 37.5665',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final doubleValue = double.tryParse(value);
            if (doubleValue != null) {
              _updateData('latitude', doubleValue);
            }
          },
        ),
        const SizedBox(height: 16),
        const Text('경도:'),
        TextField(
          controller: TextEditingController(text: longitude.toString()),
          decoration: const InputDecoration(
            hintText: '예: 126.9780',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final doubleValue = double.tryParse(value);
            if (doubleValue != null) {
              _updateData('longitude', doubleValue);
            }
          },
        ),
        const SizedBox(height: 16),
        const Text('지도 유형:'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _editedData['mapType']?.toString() ?? 'openstreetmap',
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'openstreetmap', child: Text('오픈스트리트맵')),
            DropdownMenuItem(value: 'standard', child: Text('표준')),
            DropdownMenuItem(value: 'satellite', child: Text('위성')),
            DropdownMenuItem(value: 'terrain', child: Text('지형')),
          ],
          onChanged: (value) => _updateData('mapType', value),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('길찾기 표시'),
          value: _editedData['showDirections'] == true,
          onChanged: (value) => _updateData('showDirections', value),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            // Popular wedding venues in Seoul
            _showLocationPresetsDialog();
          },
          icon: const Icon(Icons.location_city),
          label: const Text('인기 웨딩홀 선택'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 45),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleEditorFields() {
    List<Map<String, dynamic>> events = [];
    try {
      events = List<Map<String, dynamic>>.from(_editedData['events'] ?? []);
    } catch (e) {
      events = [
        {'time': '14:00', 'description': '결혼식'},
        {'time': '15:30', 'description': '피로연'},
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('일정:'),
        const SizedBox(height: 8),
        ...events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: TextEditingController(
                        text: event['time']?.toString() ?? ''),
                    decoration: const InputDecoration(
                      labelText: '시간',
                      isDense: true,
                    ),
                    onChanged: (value) {
                      events[index]['time'] = value;
                      _updateData('events', events);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: TextEditingController(
                        text: event['description']?.toString() ?? ''),
                    decoration: const InputDecoration(
                      labelText: '설명',
                      isDense: true,
                    ),
                    onChanged: (value) {
                      events[index]['description'] = value;
                      _updateData('events', events);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    events.removeAt(index);
                    _updateData('events', events);
                  },
                ),
              ],
            ),
          );
        }),
        ElevatedButton.icon(
          onPressed: () {
            events.add({'time': '00:00', 'description': '새 일정'});
            _updateData('events', events);
          },
          icon: const Icon(Icons.add),
          label: const Text('일정 추가'),
        ),
      ],
    );
  }

  void _showImageSelectionDialog(Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('갤러리 이미지 1'),
              onTap: () {
                onSelect('assets/images/gallery1.jpg');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('갤러리 이미지 2'),
              onTap: () {
                onSelect('assets/images/gallery2.jpg');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('갤러리 이미지 3'),
              onTap: () {
                onSelect('assets/images/gallery3.jpg');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('메인 이미지'),
              onTap: () {
                onSelect('assets/images/background.png');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_not_supported),
              title: const Text('플레이스홀더'),
              onTap: () {
                onSelect('assets/images/placeholder.png');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPresetsDialog() {
    final presets = [
      {'name': '그랜드 호텔 서울', 'lat': 37.5642, 'lng': 126.9758},
      {'name': '신라호텔', 'lat': 37.5558, 'lng': 126.9998},
      {'name': '롯데호텔 서울', 'lat': 37.5656, 'lng': 126.9810},
      {'name': '그랜드 하얏트 서울', 'lat': 37.5392, 'lng': 127.0068},
      {'name': '파크하얏트 서울', 'lat': 37.5345, 'lng': 127.0032},
      {'name': '더 플라자', 'lat': 37.5650, 'lng': 126.9779},
      {'name': 'JW 메리어트 서울', 'lat': 37.5050, 'lng': 127.0588},
      {'name': '웨스틴조선 서울', 'lat': 37.5656, 'lng': 126.9810},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('인기 웨딩홀 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final preset = presets[index];
              return ListTile(
                title: Text(preset['name'] as String),
                onTap: () {
                  _updateData('venue', preset['name']);
                  _updateData('title', preset['name']);
                  _updateData('latitude', preset['lat']);
                  _updateData('longitude', preset['lng']);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse('FF${colorString.substring(1)}', radix: 16));
      } else {
        return Color(int.parse(colorString));
      }
    } catch (e) {
      return Colors.black;
    }
  }

  Color _getContrastingColor(Color color) {
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _showColorPicker(String propertyKey) {
    Color currentColor =
        _parseColor(_editedData[propertyKey]?.toString() ?? '#000000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('색상 선택'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (Color color) {
              setState(() {
                _editedData[propertyKey] =
                    '#${color.value.toRadixString(16).substring(2)}';
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
