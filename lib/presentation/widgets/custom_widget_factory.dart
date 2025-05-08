import 'package:flutter/material.dart';
import '../../data/models/custom_widget_model.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CustomWidgetFactory {
  static Widget buildWidget(
      CustomWidgetModel model, {Function(CustomWidgetModel)? onEdit}) {
    // Wrap in a positioned widget if we're in the editor
    Widget widget = _buildWidgetByType(model);
    
    if (onEdit != null) {
      // We're in edit mode, add a draggable container with edit controls
      return Positioned(
        left: model.positionX,
        top: model.positionY,
        child: GestureDetector(
          onPanUpdate: (details) {
            final updatedModel = model.copyWith(
              positionX: model.positionX + details.delta.dx,
              positionY: model.positionY + details.delta.dy,
            );
            onEdit(updatedModel);
          },
          child: Container(
            width: model.width,
            height: model.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Stack(
              children: [
                Positioned.fill(child: widget),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.blue,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 14),
                          onPressed: () {
                            // Show edit dialog
                            // This would be implemented in the editor screen
                          },
                          iconSize: 14,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white, size: 14),
                          onPressed: () {
                            // Delete widget
                            // This would be implemented in the editor screen
                          },
                          iconSize: 14,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Resize handles
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      final updatedModel = model.copyWith(
                        width: model.width + details.delta.dx,
                        height: model.height + details.delta.dy,
                      );
                      onEdit(updatedModel);
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.open_with, color: Colors.white, size: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Just return the positioned widget for normal viewing
      return Positioned(
        left: model.positionX,
        top: model.positionY,
        width: model.width,
        height: model.height,
        child: widget,
      );
    }
  }

  static Widget _buildWidgetByType(CustomWidgetModel model) {
    switch (model.type) {
      case WidgetType.text:
        return _buildTextWidget(model);
      case WidgetType.image:
        return _buildImageWidget(model);
      case WidgetType.divider:
        return _buildDividerWidget(model);
      case WidgetType.button:
        return _buildButtonWidget(model);
      case WidgetType.countdown:
        return _buildCountdownWidget(model);
      case WidgetType.map:
        return _buildMapWidget(model);
      case WidgetType.gallery:
        return _buildGalleryWidget(model);
      case WidgetType.messageBox:
        return _buildMessageBoxWidget(model);
      default:
        return Container(
          child: const Center(child: Text('지원되지 않는 위젯 유형')),
        );
    }
  }

  static Widget _buildTextWidget(CustomWidgetModel model) {
    final text = model.properties['text'] ?? '';
    final fontSize = (model.properties['fontSize'] as num?)?.toDouble() ?? 16.0;
    final fontWeightIndex = model.properties['fontWeight'] ?? 0;
    final colorValue = model.properties['color'] ?? Colors.black.value;
    final textAlignIndex = model.properties['textAlign'] ?? TextAlign.center.index;

    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.values[fontWeightIndex],
          color: Color(colorValue),
        ),
        textAlign: TextAlign.values[textAlignIndex],
      ),
    );
  }

  static Widget _buildImageWidget(CustomWidgetModel model) {
    final imagePath = model.properties['imagePath'] ?? 'assets/images/gallery1.jpg';
    final fitIndex = model.properties['fit'] ?? BoxFit.cover.index;

    return Image.asset(
      imagePath,
      fit: BoxFit.values[fitIndex],
      width: model.width,
      height: model.height,
    );
  }

  static Widget _buildDividerWidget(CustomWidgetModel model) {
    final thickness = (model.properties['thickness'] as num?)?.toDouble() ?? 1.0;
    final colorValue = model.properties['color'] ?? Colors.grey.value;

    return Center(
      child: Container(
        width: model.width,
        height: thickness,
        color: Color(colorValue),
      ),
    );
  }

  static Widget _buildButtonWidget(CustomWidgetModel model) {
    final text = model.properties['text'] ?? '버튼';
    final colorValue = model.properties['color'] ?? Colors.blue.value;
    final textColorValue = model.properties['textColor'] ?? Colors.white.value;

    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Handle button action based on model.properties['action']
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(colorValue),
          foregroundColor: Color(textColorValue),
          minimumSize: Size(model.width, model.height),
        ),
        child: Text(text),
      ),
    );
  }

  static Widget _buildCountdownWidget(CustomWidgetModel model) {
    final title = model.properties['title'] ?? '결혼식까지';
    final endDateStr = model.properties['endDate'] ?? 
      DateTime.now().add(const Duration(days: 30)).toIso8601String();
    final endDate = DateTime.parse(endDateStr);
    final showSeconds = model.properties['showSeconds'] ?? true;

    return CountdownWidget(
      title: title,
      endDate: endDate,
      showSeconds: showSeconds,
    );
  }

  static Widget _buildMapWidget(CustomWidgetModel model) {
    final latitude = (model.properties['latitude'] as num?)?.toDouble() ?? 37.5665;
    final longitude = (model.properties['longitude'] as num?)?.toDouble() ?? 126.978;
    final title = model.properties['title'] ?? '위치';

    // Placeholder for actual map
    return Container(
      width: model.width,
      height: model.height,
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 50),
            const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(_editedProperties['color'] ?? Colors.blue.value),
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
              backgroundColor: Color(_editedProperties['textColor'] ?? Colors.white.value),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              _showColorPicker('textColor');
            },
            child: Text('텍스트 색상 선택', 
              style: TextStyle(
                color: _getContrastingColor(Color(_editedProperties['textColor'] ?? Colors.white.value))
              ),
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
        if (_editedProperties['action'] != 'none' && _editedProperties['action'] != null)
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
          decoration: const InputDecoration(labelText: '카운트다운 제목'),
          controller: TextEditingController(
              text: _editedProperties['title'] ?? '결혼식까지'),
          onChanged: (value) => _updateProperty('title', value),
        ),
        const SizedBox(height: 16),
        const Text('종료 날짜 및 시간'),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final currentDate = DateTime.parse(_editedProperties['endDate'] ?? 
              DateTime.now().add(const Duration(days: 30)).toIso8601String());
            
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: currentDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            
            if (pickedDate != null) {
              final TimeOfDay? pickedTime = await showTimePicker(
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
          decoration: const InputDecoration(labelText: '위치 제목'),
          controller: TextEditingController(
              text: _editedProperties['title'] ?? '위치'),
          onChanged: (value) => _updateProperty('title', value),
        ),
        TextField(
          decoration: const InputDecoration(labelText: '위치 설명'),
          controller: TextEditingController(
              text: _editedProperties['description'] ?? ''),
          onChanged: (value) => _updateProperty('description', value),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(labelText: '위도'),
                controller: TextEditingController(
                    text: (_editedProperties['latitude'] ?? 37.5665).toString()),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateProperty('latitude', double.tryParse(value) ?? 37.5665),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(labelText: '경도'),
                controller: TextEditingController(
                    text: (_editedProperties['longitude'] ?? 126.978).toString()),
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateProperty('longitude', double.tryParse(value) ?? 126.978),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('확대 레벨'),
        Slider(
          value: (_editedProperties['zoom'] as num?)?.toDouble() ?? 15.0,
          min: 1,
          max: 20,
          divisions: 19,
          label: "${(_editedProperties['zoom'] as num?)?.toDouble() ?? 15.0}",
          onChanged: (value) => _updateProperty('zoom', value),
        ),
      ],
    );
  }

  Widget _buildGalleryEditorFields() {
    // For simplicity, we'll use a predefined list of images
    final List<String> selectedImages = List<String>.from(
      _editedProperties['images'] ?? ['assets/images/gallery1.jpg']);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('갤러리 이미지 선택'),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildImageSelectionItem('assets/images/gallery1.jpg', selectedImages),
              _buildImageSelectionItem('assets/images/gallery2.jpg', selectedImages),
              _buildImageSelectionItem('assets/images/gallery3.jpg', selectedImages),
              _buildImageSelectionItem('assets/images/main.jpg', selectedImages),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('인디케이터 점 표시'),
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

  Widget _buildImageSelectionItem(String imagePath, List<String> selectedImages) {
    final isSelected = selectedImages.contains(imagePath);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            // Don't allow removing the last image
            if (selectedImages.length > 1) {
              selectedImages.remove(imagePath);
            }
          } else {
            selectedImages.add(imagePath);
          }
          _updateProperty('images', selectedImages);
        });
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Stack(
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: 120,
              height: 200,
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
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
          decoration: const InputDecoration(labelText: '입력 힌트'),
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
    final currentColor = Color(_editedProperties[propertyKey] ?? Colors.black.value);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) {
                setState(() {
                  _editedProperties[propertyKey] = color.value;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  Color _getContrastingColor(Color color) {
    // Calculate the perceptive luminance (based on ITU-R BT.709)
    double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    
    // Return black for bright colors and white for dark colors
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
