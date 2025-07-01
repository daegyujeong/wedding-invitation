// Now, let's create a widget editor dialog
// lib/presentation/screens/editor/widget_editor_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../data/models/custom_widget_model.dart';
import '../../widgets/editor/enhanced_size_editor.dart';

class WidgetEditorDialog extends StatefulWidget {
  final CustomWidgetModel widgetModel;
  final Function(CustomWidgetModel) onSave;

  const WidgetEditorDialog({
    super.key,
    required this.widgetModel,
    required this.onSave,
  });

  @override
  _WidgetEditorDialogState createState() => _WidgetEditorDialogState();
}

class _WidgetEditorDialogState extends State<WidgetEditorDialog> {
  late CustomWidgetModel _editedModel;
  late Map<String, dynamic> _editedProperties;

  @override
  void initState() {
    super.initState();
    _editedModel = widget.widgetModel;
    _editedProperties = Map.from(widget.widgetModel.properties);
  }

  void _updateProperty(String key, dynamic value) {
    setState(() {
      _editedProperties[key] = value;
    });
  }

  void _saveChanges() {
    final updatedModel = _editedModel.copyWith(
      properties: _editedProperties,
    );
    widget.onSave(updatedModel);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${_getWidgetTypeName(_editedModel.type)} 편집'),
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

  String _getWidgetTypeName(WidgetType type) {
    switch (type) {
      case WidgetType.text:
        return '텍스트';
      case WidgetType.image:
        return '이미지';
      case WidgetType.video:
        return '비디오';
      case WidgetType.divider:
        return '구분선';
      case WidgetType.button:
        return '버튼';
      case WidgetType.countdown:
        return '카운트다운';
      case WidgetType.map:
        return '지도';
      case WidgetType.gallery:
        return '갤러리';
      case WidgetType.messageBox:
        return '메시지 상자';
      default:
        return '위젯';
    }
  }

  Widget _buildEditorFields() {
    switch (_editedModel.type) {
      case WidgetType.text:
        return _buildTextEditorFields();
      case WidgetType.image:
        return _buildImageEditorFields();
      case WidgetType.video:
        return _buildVideoEditorFields();
      case WidgetType.divider:
        return _buildDividerEditorFields();
      case WidgetType.button:
        return _buildButtonEditorFields();
      case WidgetType.countdown:
        return _buildCountdownEditorFields();
      case WidgetType.map:
        return _buildMapEditorFields();
      case WidgetType.gallery:
        return _buildGalleryEditorFields();
      case WidgetType.messageBox:
        return _buildMessageBoxEditorFields();
      default:
        return Container(
          child: const Text('편집기를 사용할 수 없습니다.'),
        );
    }
  }

  Widget _buildTextEditorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(labelText: '텍스트'),
          controller: TextEditingController(
              text: _editedProperties['text']?.toString() ?? ''),
          onChanged: (value) => _updateProperty('text', value),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const Text('글꼴 크기'),
        Slider(
          value: (_editedProperties['fontSize'] as num?)?.toDouble() ?? 16.0,
          min: 10,
          max: 40,
          divisions: 30,
          label:
              "${(_editedProperties['fontSize'] as num?)?.toDouble() ?? 16.0}",
          onChanged: (value) => _updateProperty('fontSize', value),
        ),
        const SizedBox(height: 16),
        const Text('글꼴 굵기'),
        DropdownButton<int>(
          value: _editedProperties['fontWeight'] as int? ??
              FontWeight.normal.index,
          items: [
            DropdownMenuItem(
                value: FontWeight.normal.index, child: const Text('보통')),
            DropdownMenuItem(
                value: FontWeight.bold.index, child: const Text('굵게')),
            DropdownMenuItem(
                value: FontWeight.w900.index, child: const Text('더 굵게')),
          ],
          onChanged: (value) => _updateProperty('fontWeight', value),
        ),
        const SizedBox(height: 16),
        const Text('텍스트 정렬'),
        DropdownButton<int>(
          value:
              _editedProperties['textAlign'] as int? ?? TextAlign.center.index,
          items: [
            DropdownMenuItem(
                value: TextAlign.left.index, child: const Text('왼쪽')),
            DropdownMenuItem(
                value: TextAlign.center.index, child: const Text('가운데')),
            DropdownMenuItem(
                value: TextAlign.right.index, child: const Text('오른쪽')),
          ],
          onChanged: (value) => _updateProperty('textAlign', value),
        ),
        const SizedBox(height: 16),
        const Text('텍스트 색상'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(
                  _editedProperties['color'] as int? ?? Colors.black.value),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              _showColorPicker('color');
            },
            child: const Text('색상 선택', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildImageEditorFields() {
    // In a real app, you would use an image picker here
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('이미지 선택'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _editedProperties['imagePath']?.toString() ??
              'assets/images/gallery1.jpg',
          isExpanded: true,
          items: const [
            DropdownMenuItem(
                value: 'assets/images/gallery1.jpg', child: Text('갤러리 이미지 1')),
            DropdownMenuItem(
                value: 'assets/images/gallery2.jpg', child: Text('갤러리 이미지 2')),
            DropdownMenuItem(
                value: 'assets/images/gallery3.jpg', child: Text('갤러리 이미지 3')),
            DropdownMenuItem(
                value: 'assets/images/background.png', child: Text('배경 이미지')),
            DropdownMenuItem(
                value: 'assets/images/placeholder.png', child: Text('플레이스홀더')),
          ],
          onChanged: (value) => _updateProperty('imagePath', value),
        ),
        const SizedBox(height: 16),
        const Text('이미지 피팅'),
        DropdownButton<int>(
          value: _editedProperties['fit'] as int? ?? BoxFit.cover.index,
          items: [
            DropdownMenuItem(
                value: BoxFit.cover.index, child: const Text('Cover')),
            DropdownMenuItem(
                value: BoxFit.contain.index, child: const Text('Contain')),
            DropdownMenuItem(
                value: BoxFit.fill.index, child: const Text('Fill')),
            DropdownMenuItem(
                value: BoxFit.fitWidth.index, child: const Text('Fit Width')),
            DropdownMenuItem(
                value: BoxFit.fitHeight.index, child: const Text('Fit Height')),
          ],
          onChanged: (value) => _updateProperty('fit', value),
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
              width: _editedModel.width,
              height: _editedModel.height,
              onSizeChanged: (width, height) {
                setState(() {
                  _editedModel = _editedModel.copyWith(
                    width: width,
                    height: height,
                  );
                });
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

  Widget _buildVideoEditorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: '비디오 URL',
            hintText: 'https://example.com/video.mp4',
          ),
          controller: TextEditingController(
              text: _editedProperties['videoUrl']?.toString() ?? ''),
          onChanged: (value) => _updateProperty('videoUrl', value),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('자동 재생'),
          value: _editedProperties['autoPlay'] as bool? ?? false,
          onChanged: (value) => _updateProperty('autoPlay', value),
        ),
        SwitchListTile(
          title: const Text('컨트롤 표시'),
          value: _editedProperties['showControls'] as bool? ?? true,
          onChanged: (value) => _updateProperty('showControls', value),
        ),
        SwitchListTile(
          title: const Text('반복 재생'),
          value: _editedProperties['loop'] as bool? ?? false,
          onChanged: (value) => _updateProperty('loop', value),
        ),
        SwitchListTile(
          title: const Text('음소거'),
          value: _editedProperties['muted'] as bool? ?? false,
          onChanged: (value) => _updateProperty('muted', value),
        ),
        const SizedBox(height: 24),

        // Enhanced Size Controls
        const Text(
          '비디오 크기',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 350, // Fixed height for AlertDialog compatibility
          child: SingleChildScrollView(
            child: EnhancedSizeEditor(
              width: _editedModel.width,
              height: _editedModel.height,
              onSizeChanged: (width, height) {
                setState(() {
                  _editedModel = _editedModel.copyWith(
                    width: width,
                    height: height,
                  );
                });
              },
              minWidth: 150,
              maxWidth: 400,
              minHeight: 100,
              maxHeight: 400,
              showRatioControls: true,
              showPresets: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDividerEditorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('두께'),
        Slider(
          value: (_editedProperties['thickness'] as num?)?.toDouble() ?? 1.0,
          min: 1,
          max: 10,
          divisions: 9,
          label:
              "${(_editedProperties['thickness'] as num?)?.toDouble() ?? 1.0}",
          onChanged: (value) => _updateProperty('thickness', value),
        ),
        const SizedBox(height: 16),
        const Text('색상'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(
                  _editedProperties['color'] as int? ?? Colors.grey.value),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              _showColorPicker('color');
            },
            child: const Text('색상 선택', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonEditorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(labelText: '버튼 텍스트'),
          controller: TextEditingController(
              text: _editedProperties['text']?.toString() ?? '버튼'),
          onChanged: (value) => _updateProperty('text', value),
        ),
        const SizedBox(height: 16),
        const Text('배경 색상'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(
                  _editedProperties['color'] as int? ?? Colors.blue.value),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              _showColorPicker('color');
            },
            child:
                const Text('배경 색상 선택', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),
        const Text('텍스트 색상'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(
                  _editedProperties['textColor'] as int? ?? Colors.white.value),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              _showColorPicker('textColor');
            },
            child: Text(
              '텍스트 색상 선택',
              style: TextStyle(
                  color: _getContrastingColor(Color(
                      _editedProperties['textColor'] as int? ??
                          Colors.white.value))),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('버튼 동작'),
        DropdownButton<String>(
          value: _editedProperties['action']?.toString() ?? 'none',
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'none', child: Text('없음')),
            DropdownMenuItem(value: 'url', child: Text('URL 열기')),
            DropdownMenuItem(value: 'phone', child: Text('전화 걸기')),
            DropdownMenuItem(value: 'sms', child: Text('문자 보내기')),
            DropdownMenuItem(value: 'email', child: Text('이메일 보내기')),
            DropdownMenuItem(value: 'map', child: Text('지도 열기')),
          ],
          onChanged: (value) => _updateProperty('action', value),
        ),
        if (_editedProperties['action']?.toString() != 'none' &&
            _editedProperties['action'] != null)
          Column(
            children: [
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: _getActionTargetLabel(_editedProperties['action']?.toString()),
                  hintText: _getActionTargetHint(_editedProperties['action']?.toString()),
                ),
                controller: TextEditingController(
                    text: _editedProperties['actionTarget']?.toString() ?? ''),
                onChanged: (value) => _updateProperty('actionTarget', value),
              ),
            ],
          ),
      ],
    );
  }

  String _getActionTargetLabel(String? action) {
    switch (action) {
      case 'url':
        return 'URL';
      case 'phone':
        return '전화번호';
      case 'sms':
        return '전화번호';
      case 'email':
        return '이메일 주소';
      case 'map':
        return '좌표 (위도,경도)';
      default:
        return '대상';
    }
  }

  String _getActionTargetHint(String? action) {
    switch (action) {
      case 'url':
        return 'https://example.com';
      case 'phone':
        return '010-1234-5678';
      case 'sms':
        return '010-1234-5678';
      case 'email':
        return 'example@email.com';
      case 'map':
        return '37.5665,126.978';
      default:
        return '';
    }
  }

  Widget _buildCountdownEditorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(labelText: '타이틀'),
          controller: TextEditingController(
              text: _editedProperties['title']?.toString() ?? '결혼식까지'),
          onChanged: (value) => _updateProperty('title', value),
        ),
        const SizedBox(height: 16),
        const Text('종료 날짜 및 시간'),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final currentDateStr = _editedProperties['endDate']?.toString();
            final currentDate = currentDateStr != null
                ? DateTime.tryParse(currentDateStr) ??
                    DateTime.now().add(const Duration(days: 30))
                : DateTime.now().add(const Duration(days: 30));

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
                _updateProperty('endDate', newDateTime.toIso8601String());
              }
            }
          },
          child: Text(_editedProperties['endDate'] != null
              ? '선택된 날짜: ${DateTime.tryParse(_editedProperties['endDate'].toString())?.toString().split(' ')[0] ?? '미선택'}'
              : '날짜 및 시간 선택'),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('초 단위 표시'),
          value: _editedProperties['showSeconds'] as bool? ?? true,
          onChanged: (value) => _updateProperty('showSeconds', value),
        ),
      ],
    );
  }

  Widget _buildMapEditorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(labelText: '위도'),
          controller: TextEditingController(
              text: (_editedProperties['latitude'] as num? ?? 37.5665)
                  .toString()),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final doubleValue = double.tryParse(value);
            if (doubleValue != null) {
              _updateProperty('latitude', doubleValue);
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: '경도'),
          controller: TextEditingController(
              text: (_editedProperties['longitude'] as num? ?? 126.978)
                  .toString()),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final doubleValue = double.tryParse(value);
            if (doubleValue != null) {
              _updateProperty('longitude', doubleValue);
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: '제목'),
          controller: TextEditingController(
              text: _editedProperties['title']?.toString() ?? '위치'),
          onChanged: (value) => _updateProperty('title', value),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: '설명'),
          controller: TextEditingController(
              text: _editedProperties['description']?.toString() ?? ''),
          onChanged: (value) => _updateProperty('description', value),
        ),
        const SizedBox(height: 16),
        const Text('줌 레벨'),
        Slider(
          value: (_editedProperties['zoom'] as num?)?.toDouble() ?? 15.0,
          min: 5,
          max: 20,
          divisions: 15,
          label: "${(_editedProperties['zoom'] as num?)?.toDouble() ?? 15.0}",
          onChanged: (value) => _updateProperty('zoom', value),
        ),
        const SizedBox(height: 24),

        // Enhanced Size Controls
        const Text(
          '지도 크기',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 350, // Fixed height for AlertDialog compatibility
          child: SingleChildScrollView(
            child: EnhancedSizeEditor(
              width: _editedModel.width,
              height: _editedModel.height,
              onSizeChanged: (width, height) {
                setState(() {
                  _editedModel = _editedModel.copyWith(
                    width: width,
                    height: height,
                  );
                });
              },
              minWidth: 100,
              maxWidth: 400,
              minHeight: 100,
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
    // In a real app, this would use an image picker to add/remove images
    final images = _editedProperties['images'] ??
        [
          'assets/images/gallery1.jpg',
          'assets/images/gallery2.jpg',
          'assets/images/gallery3.jpg'
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('갤러리 이미지'),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: (images as List).length + 1, // +1 for add button
            itemBuilder: (context, index) {
              if (index == images.length) {
                // Add image button
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // In a real app, this would show an image picker
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('이미지 선택'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                title: const Text('갤러리 이미지 1'),
                                onTap: () {
                                  List<String> newImages = List.from(images);
                                  newImages.add('assets/images/gallery1.jpg');
                                  _updateProperty('images', newImages);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('갤러리 이미지 2'),
                                onTap: () {
                                  List<String> newImages = List.from(images);
                                  newImages.add('assets/images/gallery2.jpg');
                                  _updateProperty('images', newImages);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('갤러리 이미지 3'),
                                onTap: () {
                                  List<String> newImages = List.from(images);
                                  newImages.add('assets/images/gallery3.jpg');
                                  _updateProperty('images', newImages);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text('플레이스홀더'),
                                onTap: () {
                                  List<String> newImages = List.from(images);
                                  newImages
                                      .add('assets/images/placeholder.png');
                                  _updateProperty('images', newImages);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return Stack(
                children: [
                  Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        images[index].toString(),
                        fit: BoxFit.cover,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 150,
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
                        List<String> newImages = List.from(images);
                        newImages.removeAt(index);
                        _updateProperty('images', newImages);
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
        SwitchListTile(
          title: const Text('표시자 표시'),
          value: _editedProperties['showDots'] as bool? ?? true,
          onChanged: (value) => _updateProperty('showDots', value),
        ),
        SwitchListTile(
          title: const Text('자동 스크롤'),
          value: _editedProperties['autoScroll'] as bool? ?? false,
          onChanged: (value) => _updateProperty('autoScroll', value),
        ),
        const SizedBox(height: 24),

        // Enhanced Size Controls
        const Text(
          '갤러리 크기',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 350, // Fixed height for AlertDialog compatibility
          child: SingleChildScrollView(
            child: EnhancedSizeEditor(
              width: _editedModel.width,
              height: _editedModel.height,
              onSizeChanged: (width, height) {
                setState(() {
                  _editedModel = _editedModel.copyWith(
                    width: width,
                    height: height,
                  );
                });
              },
              minWidth: 150,
              maxWidth: 400,
              minHeight: 100,
              maxHeight: 350,
              showRatioControls: true,
              showPresets: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBoxEditorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(labelText: '제목'),
          controller: TextEditingController(
              text: _editedProperties['title']?.toString() ?? '축하 메시지'),
          onChanged: (value) => _updateProperty('title', value),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: '안내 문구'),
          controller: TextEditingController(
              text:
                  _editedProperties['placeholder']?.toString() ?? '메시지를 남겨주세요'),
          onChanged: (value) => _updateProperty('placeholder', value),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('전송 버튼 표시'),
          value: _editedProperties['showSubmitButton'] as bool? ?? true,
          onChanged: (value) => _updateProperty('showSubmitButton', value),
        ),
      ],
    );
  }

  void _showColorPicker(String propertyKey) {
    Color currentColor =
        Color(_editedProperties[propertyKey] as int? ?? Colors.black.value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('색상 선택'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              setState(() {
                _editedProperties[propertyKey] = color.value;
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

  Color _getContrastingColor(Color color) {
    // Calculate the perceptive luminance (based on ITU-R BT.709)
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    // Return black for bright colors and white for dark colors
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}