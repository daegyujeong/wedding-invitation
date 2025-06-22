import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/models/editor_widget_model.dart';
import '../../../../data/models/page_model.dart';
import '../../../viewmodels/editor_viewmodel.dart';
import '../../../widgets/editor/draggable_widget.dart';
import '../widget_selector_screen.dart';

class CustomDraggableEditor extends StatefulWidget {
  final PageModel page;
  final EditorViewModel viewModel;

  const CustomDraggableEditor({
    super.key,
    required this.page,
    required this.viewModel,
  });

  @override
  _CustomDraggableEditorState createState() => _CustomDraggableEditorState();
}

class _CustomDraggableEditorState extends State<CustomDraggableEditor> {
  late List<EditorWidget> _widgets;
  late Color _backgroundColor;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Initialize widgets from page content
    _loadWidgetsFromPageContent();

    // Initialize background color
    _backgroundColor = widget.page.settings['backgroundColor'] != null
        ? Color(
            int.parse(widget.page.backgroundColor.replaceFirst('#', '0xFF')))
        : Colors.white;
  }

  void _loadWidgetsFromPageContent() {
    final widgetsJson = widget.page.settings['widgets'] as List<dynamic>? ?? [];

    _widgets = widgetsJson
        .map((json) => EditorWidget.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  void _savePageContent() {
    final updatedSettings = Map<String, dynamic>.from(widget.page.settings);

    // Save widgets
    updatedSettings['widgets'] = _widgets.map((w) => w.toJson()).toList();

    // Save background color
    updatedSettings['backgroundColor'] =
        '#${_backgroundColor.value.toRadixString(16).substring(2)}';

    final updatedPage = widget.page.copyWith(settings: updatedSettings);
    widget.viewModel.updatePage(updatedPage);
    Navigator.pop(context);
  }

  void _addWidget(EditorWidget widget) {
    setState(() {
      _widgets.add(widget);
    });
  }

  void _removeWidget(String id) {
    setState(() {
      _widgets.removeWhere((widget) => widget.id == id);
    });
  }

  void _updateWidgetPosition(String id, Offset position) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      final widget = _widgets[index];
      final updatedData = Map<String, dynamic>.from(widget.data);
      updatedData['position'] = {
        'dx': position.dx,
        'dy': position.dy,
      };

      // Create updated widget
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
        case WidgetType.Map:
          updatedWidget = MapWidget(
            id: widget.id,
            data: updatedData,
          );
          break;
        case WidgetType.Image:
          updatedWidget = ImageWidget(
            id: widget.id,
            data: updatedData,
          );
          break;
        case WidgetType.Gallery:
          updatedWidget = GalleryWidget(
            id: widget.id,
            data: updatedData,
          );
          break;
        case WidgetType.Schedule:
          updatedWidget = ScheduleWidget(
            id: widget.id,
            data: updatedData,
          );
          break;
        case WidgetType.CountdownTimer:
          updatedWidget = CountdownWidget(
            id: widget.id,
            data: updatedData,
          );
          break;
      }

      setState(() {
        _widgets[index] = updatedWidget;
      });
    }
  }

  void _editWidget(String id) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index == -1) return;

    final widget = _widgets[index];

    // Different edit dialog based on widget type
    switch (widget.type) {
      case WidgetType.Text:
        _showTextEditDialog(widget as TextWidget, index);
        break;
      case WidgetType.DDay:
        _showDDayEditDialog(widget as DDayWidget, index);
        break;
      case WidgetType.Map:
        _showMapEditDialog(widget as MapWidget, index);
        break;
      // Add more edit dialogs for other widget types
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이 위젯 유형은 편집할 수 없습니다.')),
        );
    }
  }

  void _showTextEditDialog(TextWidget widget, int index) {
    final textController = TextEditingController(
      text: widget.text.getText('ko'), // Use current language
    );

    double fontSize = widget.fontSize;
    String fontFamily = widget.fontFamily;
    Color textColor =
        Color(int.parse('FF${widget.color.substring(1)}', radix: 16));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
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
                            setDialogState(() {
                              fontSize = value;
                            });
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
                                      setDialogState(() {
                                        textColor = color;
                                      });
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: fontFamily,
                    decoration: const InputDecoration(
                      labelText: '글꼴',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Roboto',
                        child: Text('Roboto'),
                      ),
                      DropdownMenuItem(
                        value: 'NotoSansKR',
                        child: Text('Noto Sans KR'),
                      ),
                      DropdownMenuItem(
                        value: 'NanumGothic',
                        child: Text('Nanum Gothic'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          fontFamily = value;
                        });
                      }
                    },
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
                  updatedData['color'] =
                      '#${textColor.value.toRadixString(16).substring(2)}';

                  setState(() {
                    _widgets[index] = TextWidget(
                      id: widget.id,
                      data: updatedData,
                    );
                  });

                  Navigator.pop(context);
                },
                child: const Text('저장'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showDDayEditDialog(DDayWidget widget, int index) {
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
                    setState(() {
                      format = value;
                    });
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
                    setState(() {
                      style = value;
                    });
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

                setState(() {
                  _widgets[index] = DDayWidget(
                    id: widget.id,
                    data: updatedData,
                  );
                });

                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void _showMapEditDialog(MapWidget widget, int index) {
    // Implementation for map widget editing
    String venueId = widget.venueId;
    bool showDirections = widget.showDirections;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('지도 설정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: venueId.isEmpty ? 'main_venue' : venueId,
                decoration: const InputDecoration(
                  labelText: '장소',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'main_venue',
                    child: Text('메인 결혼식장'),
                  ),
                  DropdownMenuItem(
                    value: 'after_party',
                    child: Text('2차 장소'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      venueId = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('길 찾기 표시'),
                value: showDirections,
                onChanged: (value) {
                  setState(() {
                    showDirections = value;
                  });
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
                updatedData['venueId'] = venueId;
                updatedData['showDirections'] = showDirections;

                setState(() {
                  _widgets[index] = MapWidget(
                    id: widget.id,
                    data: updatedData,
                  );
                });

                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // Create a text widget with default properties
  TextWidget _createDefaultTextWidget() {
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

  // Create a D-day widget with default properties
  DDayWidget _createDefaultDDayWidget() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.page.title} 편집'),
        actions: [
          TextButton(
            onPressed: _savePageContent,
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: _backgroundColor,
          ),

          // Widget canvas
          Stack(
            children: _widgets.map((widget) {
              return DraggableWidget(
                key: ValueKey(widget.id),
                editorWidget: widget,
                onPositionChanged: (offset) {
                  _updateWidgetPosition(widget.id, offset);
                },
                onEdit: () {
                  _editWidget(widget.id);
                },
                onDelete: () {
                  _removeWidget(widget.id);
                },
              );
            }).toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "customDraggableEditorFAB",
        child: const Icon(Icons.add),
        onPressed: () async {
          // Show widget selector
          final result = await Navigator.push<EditorWidget>(
            context,
            MaterialPageRoute(
              builder: (context) => WidgetSelectorScreen(
                pageId: widget.page.id,
                viewModel: widget.viewModel,
              ),
            ),
          );

          // If a widget was selected, add it to the local list
          if (result != null) {
            _addWidget(result);
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.color_lens),
                onPressed: () {
                  _showBackgroundColorPicker();
                },
                tooltip: '배경 색상 변경',
              ),
              IconButton(
                icon: const Icon(Icons.text_fields),
                onPressed: () {
                  // Shortcut to add text widget
                  _addWidget(_createDefaultTextWidget());
                },
                tooltip: '텍스트 추가',
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  // Shortcut to add D-day widget
                  _addWidget(_createDefaultDDayWidget());
                },
                tooltip: 'D-day 추가',
              ),
              IconButton(
                icon: const Icon(Icons.photo_library),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('준비 중인 기능입니다.')),
                  );
                },
                tooltip: '이미지 추가',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBackgroundColorPicker() {
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
                setState(() {
                  _backgroundColor = pickedColor;
                });
                Navigator.pop(context);
              },
              child: const Text('선택'),
            ),
          ],
        );
      },
    );
  }
}
