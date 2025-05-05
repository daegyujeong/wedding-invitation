import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';
import 'package:wedding_invitation/data/models/editor_widget_model.dart';
import 'package:wedding_invitation/data/services/design_storage_service.dart';

class EditorViewModel extends ChangeNotifier {
  List<EditorWidget> _widgets = [];
  Color _backgroundColor = Colors.white;
  File? _backgroundImage;
  final Uuid _uuid = const Uuid();
  final DesignStorageService _storage = DesignStorageService();

  List<EditorWidget> get widgets => _widgets;
  Color get backgroundColor => _backgroundColor;
  File? get backgroundImage => _backgroundImage;

  // Initialize with sample data or load from storage
  EditorViewModel() {
    // Could be empty initially or load from storage
  }

  // Load a saved design
  Future<void> loadDesign() async {
    try {
      final design = await _storage.loadDesign();
      if (design != null) {
        _widgets = design.widgets;
        _backgroundColor = design.backgroundColor;
        // Background image would need special handling
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading design: $e');
      // Handle error (could show a toast, etc.)
    }
  }

  // Save the current design
  Future<void> saveDesign() async {
    try {
      await _storage.saveDesign(
        WeddingDesign(
          widgets: _widgets,
          backgroundColor: _backgroundColor,
          backgroundImagePath: _backgroundImage?.path,
        ),
      );
    } catch (e) {
      debugPrint('Error saving design: $e');
      // Handle error
    }
  }

  // Add a widget to the canvas
  void addWidget(EditorWidget widget) {
    // If the widget doesn't have a position, set a default
    final currentData = Map<String, dynamic>.from(widget.data);
    if (!currentData.containsKey('position')) {
      currentData['position'] = {
        'dx': 100.0,
        'dy': 100.0,
      };
    }
    
    // Create a new widget with updated data
    EditorWidget updatedWidget;
    switch (widget.type) {
      case WidgetType.Text:
        updatedWidget = TextWidget(
          id: widget.id,
          data: currentData,
        );
        break;
      case WidgetType.DDay:
        updatedWidget = DDayWidget(
          id: widget.id,
          data: currentData,
        );
        break;
      // Add cases for other widget types
      default:
        // Generic fallback
        updatedWidget = widget;
    }
    
    _widgets.add(updatedWidget);
    notifyListeners();
  }

  // Remove a widget from the canvas
  void removeWidget(String id) {
    _widgets.removeWhere((widget) => widget.id == id);
    notifyListeners();
  }

  // Update widget position
  void updateWidgetPosition(String id, Offset position) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      final widget = _widgets[index];
      final updatedData = Map<String, dynamic>.from(widget.data);
      updatedData['position'] = {
        'dx': position.dx,
        'dy': position.dy,
      };
      
      // Create updated widget with new position
      EditorWidget updatedWidget;
      switch (widget.type) {
        case WidgetType.Text:
          updatedWidget = TextWidget(
            id: widget.id,
            data: updatedData,
          );
          break;
        case WidgetType.DDay:
          updatedWidget = DDayWidget(
            id: widget.id,
            data: updatedData,
          );
          break;
        // Add cases for other widget types
        default:
          // Generic fallback that preserves the widget type
          updatedWidget = EditorWidget.fromJson({
            'id': widget.id,
            'type': widget.type.toString().split('.').last,
            'data': updatedData,
          });
      }
      
      _widgets[index] = updatedWidget;
      notifyListeners();
    }
  }

  // Edit a widget
  void editWidget(String id, BuildContext context) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      final widget = _widgets[index];
      
      // Different edit dialog based on widget type
      switch (widget.type) {
        case WidgetType.Text:
          _showTextEditDialog(context, widget as TextWidget, index);
          break;
        case WidgetType.DDay:
          _showDDayEditDialog(context, widget as DDayWidget, index);
          break;
        // Add cases for other widget types
        default:
          // Generic edit dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이 위젯 유형은 편집할 수 없습니다.')),
          );
      }
    }
  }

  // Dialog to edit text widget
  void _showTextEditDialog(BuildContext context, TextWidget widget, int index) {
    final textController = TextEditingController(
      text: widget.text.getText('ko'), // Use current language
    );
    
    double fontSize = widget.fontSize;
    String fontFamily = widget.fontFamily;
    Color textColor = Color(int.parse('FF${widget.color.substring(1)}', radix: 16));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('텍스트 편집'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(labelText: '텍스트'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('글자 크기:'),
                    Expanded(
                      child: Slider(
                        value: fontSize,
                        min: 8,
                        max: 40,
                        divisions: 32,
                        label: fontSize.round().toString(),
                        onChanged: (value) {
                          fontSize = value;
                          // Using setState in the dialog context
                          (context as Element).markNeedsBuild();
                        },
                      ),
                    ),
                    Text('${fontSize.round()}'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('색상:'),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('색상 선택'),
                              content: SingleChildScrollView(
                                child: ColorPicker(
                                  pickerColor: textColor,
                                  onColorChanged: (color) {
                                    textColor = color;
                                  },
                                  pickerAreaHeightPercent: 0.8,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('선택'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: textColor,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // Update the widget
                final updatedData = Map<String, dynamic>.from(widget.data);
                updatedData['text'] = {
                  'translations': {'ko': textController.text},
                  'default_language': 'ko',
                };
                updatedData['fontSize'] = fontSize;
                updatedData['fontFamily'] = fontFamily;
                updatedData['color'] = '#${textColor.value.toRadixString(16).substring(2)}';
                
                _widgets[index] = TextWidget(
                  id: widget.id,
                  data: updatedData,
                );
                
                notifyListeners();
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // Dialog to edit D-day widget
  void _showDDayEditDialog(BuildContext context, DDayWidget widget, int index) {
    // Implementation for D-day widget editing
    String format = widget.format;
    String style = widget.style;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('D-day 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('표시 형식:'),
              DropdownButton<String>(
                value: format,
                items: const [
                  DropdownMenuItem(
                    value: 'D-{days}',
                    child: Text('D-{days}'),
                  ),
                  DropdownMenuItem(
                    value: '결혼식까지 {days}일',
                    child: Text('결혼식까지 {days}일'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    format = value;
                    // Force rebuild
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('스타일:'),
              DropdownButton<String>(
                value: style,
                items: const [
                  DropdownMenuItem(
                    value: 'default',
                    child: Text('기본'),
                  ),
                  DropdownMenuItem(
                    value: 'minimal',
                    child: Text('미니멀'),
                  ),
                  DropdownMenuItem(
                    value: 'fancy',
                    child: Text('장식'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    style = value;
                    // Force rebuild
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // Update the widget
                final updatedData = Map<String, dynamic>.from(widget.data);
                updatedData['format'] = format;
                updatedData['style'] = style;
                
                _widgets[index] = DDayWidget(
                  id: widget.id,
                  data: updatedData,
                );
                
                notifyListeners();
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // Pick a background image
  Future<void> pickBackgroundImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      _backgroundImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  // Pick a background color
  void pickBackgroundColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        Color pickedColor = _backgroundColor;
        return AlertDialog(
          title: const Text('배경 색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _backgroundColor,
              onColorChanged: (color) {
                pickedColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _backgroundColor = pickedColor;
                notifyListeners();
                Navigator.pop(context);
              },
              child: const Text('선택'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to create a default text widget
  TextWidget createDefaultTextWidget() {
    return TextWidget(
      id: _uuid.v4(),
      data: {
        'text': {
          'translations': {'ko': '새 텍스트'},
          'default_language': 'ko',
        },
        'fontFamily': 'Roboto',
        'fontSize': 16.0,
        'color': '#000000',
        'position': {
          'dx': 100.0,
          'dy': 100.0,
        },
      },
    );
  }

  // Helper method to create a default D-day widget
  DDayWidget createDefaultDDayWidget() {
    return DDayWidget(
      id: _uuid.v4(),
      data: {
        'eventId': '',
        'format': 'D-{days}',
        'style': 'default',
        'position': {
          'dx': 100.0,
          'dy': 100.0,
        },
      },
    );
  }
}

// Class to represent a complete design
class WeddingDesign {
  final List<EditorWidget> widgets;
  final Color backgroundColor;
  final String? backgroundImagePath;

  WeddingDesign({
    required this.widgets,
    required this.backgroundColor,
    this.backgroundImagePath,
  });
}