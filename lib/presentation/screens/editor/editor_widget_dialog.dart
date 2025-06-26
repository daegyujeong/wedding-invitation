import 'package:flutter/material.dart';
import '../../../data/models/editor_widget_model.dart';

class EditorWidgetDialog extends StatefulWidget {
  final EditorWidget widget;
  final Function(EditorWidget) onSave;

  const EditorWidgetDialog({
    Key? key,
    required this.widget,
    required this.onSave,
  }) : super(key: key);

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
        updatedWidget = CountdownWidget(id: _editedWidget.id, data: _editedData);
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
      currentText = _editedData['text']['ko'] ?? _editedData['text']['en'] ?? '';
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
            DropdownMenuItem(value: 'Noto Sans KR', child: Text('Noto Sans KR')),
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
            DropdownMenuItem(value: '{days} days to go', child: Text('{days} days to go')),
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
          controller: TextEditingController(text: _editedData['title']?.toString() ?? 'D-Day'),
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
          value: _editedData['imageUrl']?.toString() ?? 'assets/images/placeholder.png',
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
          ],
          onChanged: (value) => _updateData('imageUrl', value),
        ),
        const SizedBox(height: 16),
        const Text('너비:'),
        Slider(
          value: (_editedData['width'] as num?)?.toDouble() ?? 200.0,
          min: 50,
          max: 400,
          divisions: 35,
          label: "${(_editedData['width'] as num?)?.toDouble() ?? 200.0}",
          onChanged: (value) => _updateData('width', value),
        ),
        const SizedBox(height: 16),
        const Text('높이:'),
        Slider(
          value: (_editedData['height'] as num?)?.toDouble() ?? 200.0,
          min: 50,
          max: 400,
          divisions: 35,
          label: "${(_editedData['height'] as num?)?.toDouble() ?? 200.0}",
          onChanged: (value) => _updateData('height', value),
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
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Add more image selection logic here
                      imageUrls.add('assets/images/placeholder.png');
                      _updateData('imageUrls', imageUrls);
                    },
                  ),
                );
              }
              
              return Stack(
                children: [
                  Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
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
      ],
    );
  }

  Widget _buildMapEditorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('지도 유형:'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _editedData['mapType']?.toString() ?? 'standard',
          isExpanded: true,
          items: const [
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
                    controller: TextEditingController(text: event['time']?.toString() ?? ''),
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
                    controller: TextEditingController(text: event['description']?.toString() ?? ''),
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
        ElevatedButton(
          onPressed: () {
            events.add({'time': '00:00', 'description': '새 일정'});
            _updateData('events', events);
          },
          child: const Text('일정 추가'),
        ),
      ],
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

  void _showColorPicker(String propertyKey) {
    // Simple color picker - you can enhance this with flutter_colorpicker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('색상 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildColorOption(Colors.black, '검정', propertyKey),
            _buildColorOption(Colors.white, '흰색', propertyKey),
            _buildColorOption(Colors.red, '빨강', propertyKey),
            _buildColorOption(Colors.blue, '파랑', propertyKey),
            _buildColorOption(Colors.green, '초록', propertyKey),
            _buildColorOption(Colors.orange, '주황', propertyKey),
            _buildColorOption(Colors.purple, '보라', propertyKey),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color, String name, String propertyKey) {
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey),
          shape: BoxShape.circle,
        ),
      ),
      title: Text(name),
      onTap: () {
        _updateData(propertyKey, '#${color.value.toRadixString(16).substring(2)}');
        Navigator.pop(context);
      },
    );
  }
}
