// Now, let's create a widget editor dialog
// lib/presentation/screens/editor/widget_editor_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../data/models/custom_widget_model.dart';

class WidgetEditorDialog extends StatefulWidget {
  final CustomWidgetModel widgetModel;
  final Function(CustomWidgetModel) onSave;

  const WidgetEditorDialog({
    Key? key,
    required this.widgetModel,
    required this.onSave,
  }) : super(key: key);

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
          controller:
              TextEditingController(text: _editedProperties['text'] ?? ''),
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
          value: _editedProperties['fontWeight'] ?? 0,
          items: const [
            DropdownMenuItem(value: 0, child: Text('보통')),
            DropdownMenuItem(value: 1, child: Text('굵게')),
            DropdownMenuItem(value: 2, child: Text('더 굵게')),
          ],
          onChanged: (value) => _updateProperty('fontWeight', value),
        ),
        const SizedBox(height: 16),
        const Text('텍스트 정렬'),
        DropdownButton<int>(
          value: _editedProperties['textAlign'] ?? TextAlign.center.index,
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
              backgroundColor:
                  Color(_editedProperties['color'] ?? Colors.black.value),
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
          value: _editedProperties['imagePath'] ?? 'assets/images/gallery1.jpg',
          isExpanded: true,
          items: const [
            DropdownMenuItem(
                value: 'assets/images/gallery1.jpg', child: Text('갤러리 이미지 1')),
            DropdownMenuItem(
                value: 'assets/images/gallery2.jpg', child: Text('갤러리 이미지 2')),
            DropdownMenuItem(
                value: 'assets/images/gallery3.jpg', child: Text('갤러리 이미지 3')),
            DropdownMenuItem(
                value: 'assets/images/main.jpg', child: Text('메인 이미지')),
          ],
          onChanged: (value) => _updateProperty('imagePath', value),
        ),
        const SizedBox(height: 16),
        const Text('이미지 피팅'),
        DropdownButton<int>(
          value: _editedProperties['fit'] ?? BoxFit.cover.index,
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
              backgroundColor:
                  Color(_editedProperties['color'] ?? Colors.grey.value),
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
          controller:
              TextEditingController(text: _editedProperties['text'] ?? '버튼'),
          onChanged: (value) => _updateProperty('text', value),
        ),
        const SizedBox(height: 16),
        const Text('배경 색상'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Color(_editedProperties['color'] ?? Colors.blue.value),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              _showColorPicker('color');
            },
            child: const Text('배경 색상 선택', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),
        const Text('텍스트 색상'),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Color(_editedProperties['textColor'] ?? Colors.white.value),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              _showColorPicker('textColor');
            },
            child: Text(
              '텍스트 색상 선택',
              style: TextStyle(
                  color: _getContrastingColor(Color(
                      _editedProperties['textColor'] ?? Colors.white.value))),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('버튼 동작'),
        DropdownButton<String>(
          value: _editedProperties['action'] ?? 'none',
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
        if (_editedProperties['action'] != 'none' &&
            _editedProperties['action'] != null)
          TextField(
            decoration: const InputDecoration(labelText: '대상 (URL/전화번호/이메일 등)'),
            controller: TextEditingController(
                text: _editedProperties['actionTarget'] ?? ''),
            onChanged: (value) => _updateProperty('actionTarget', value),
          ),
      ],
    );
  }

  Widget _buildCountdownEditorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: const InputDecoration(labelText: '타이틀'),
          controller: TextEditingController(
              text: _editedProperties['title'] ?? '결혼식까지'),
          onChanged: (value) => _updateProperty('title', value),
        ),
        const SizedBox(height: 16),
        const Text('종료 날짜 및 시간'),
        // In a real app, this would be a date time picker
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final currentDate = _editedProperties['endDate'] != null
                ? DateTime.parse(_editedProperties['endDate'])
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
          child: const Text('날짜 및 시간 선택'),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('초 단위 표시'),
          value: _editedProperties['showSeconds'] ?? true,
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
              text: (_editedProperties['latitude'] ?? 37.5665).toString()),
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
              text: (_editedProperties['longitude'] ?? 126.978).toString()),
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
          controller:
              TextEditingController(text: _editedProperties['title'] ?? '위치'),
          onChanged: (value) => _updateProperty('title', value),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: '설명'),
          controller: TextEditingController(
              text: _editedProperties['description'] ?? ''),
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
      ],
    );
  }

  Widget _buildGalleryEditorFields() {
    // In a real app, this would use an image picker to add/remove images
    final images = _editedProperties['images'] ??
        ['assets/images/gallery1.jpg', 'assets/images/gallery2.jpg'];

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
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.cover,
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
          value: _editedProperties['showDots'] ?? true,
          onChanged: (value) => _updateProperty('showDots', value),
        ),
        SwitchListTile(
          title: const Text('자동 스크롤'),
          value: _editedProperties['autoScroll'] ?? false,
          onChanged: (value) => _updateProperty('autoScroll', value),
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
              text: _editedProperties['title'] ?? '축하 메시지'),
          onChanged: (value) => _updateProperty('title', value),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: '안내 문구'),
          controller: TextEditingController(
              text: _editedProperties['placeholder'] ?? '메시지를 남겨주세요'),
          onChanged: (value) => _updateProperty('placeholder', value),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('전송 버튼 표시'),
          value: _editedProperties['showSubmitButton'] ?? true,
          onChanged: (value) => _updateProperty('showSubmitButton', value),
        ),
      ],
    );
  }

  void _showColorPicker(String propertyKey) {
    Color currentColor =
        Color(_editedProperties[propertyKey] ?? Colors.black.value);

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
    double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    
    // Return black for bright colors and white for dark colors
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}