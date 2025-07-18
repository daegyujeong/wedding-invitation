import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:uuid/uuid.dart';
import '../../../../data/models/editor_widget_model.dart';
import '../../../../data/models/page_model.dart';
import '../../../viewmodels/editor_viewmodel.dart';
import '../../../widgets/editor/draggable_widget.dart';
import '../../../widgets/editor/enhanced_size_editor.dart';
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

  // Currently unused - position updates are handled automatically by DraggableWidget
  // void _updateWidgetPosition(String id, Offset position) {
  //   final index = _widgets.indexWhere((widget) => widget.id == id);
  //   if (index != -1) {
  //     final widget = _widgets[index];
  //     final updatedData = Map<String, dynamic>.from(widget.data);
  //     updatedData['position'] = {
  //       'dx': position.dx,
  //       'dy': position.dy,
  //     };

  //     // Create updated widget
  //     EditorWidget updatedWidget;
  //     switch (widget.type) {
  //       case WidgetType.Text:
  //         updatedWidget = TextWidget(
  //           id: widget.id,
  //           data: updatedData,
  //         );
  //         break;
  //       case WidgetType.DDay:
  //         updatedWidget = DDayWidget(
  //           id: widget.id,
  //           data: updatedData,
  //         );
  //         break;
  //       case WidgetType.Map:
  //         updatedWidget = MapWidget(
  //           id: widget.id,
  //           data: updatedData,
  //         );
  //         break;
  //       case WidgetType.Image:
  //         updatedWidget = ImageWidget(
  //           id: widget.id,
  //           data: updatedData,
  //         );
  //         break;
  //       case WidgetType.Gallery:
  //         updatedWidget = GalleryWidget(
  //           id: widget.id,
  //           data: updatedData,
  //         );
  //         break;
  //       case WidgetType.Schedule:
  //         updatedWidget = ScheduleWidget(
  //           id: widget.id,
  //           data: updatedData,
  //         );
  //         break;
  //       case WidgetType.CountdownTimer:
  //         updatedWidget = CountdownWidget(
  //           id: widget.id,
  //           data: updatedData,
  //         );
  //         break;
  //       case WidgetType.Video:
  //         updatedWidget = VideoWidget(
  //           id: widget.id,
  //           data: updatedData,
  //         );
  //         break;
  //       case WidgetType.Button:
  //         updatedWidget = ButtonWidget(
  //           id: widget.id,
  //           data: updatedData,
  //         );
  //         break;
  //     }

  //     setState(() {
  //       _widgets[index] = updatedWidget;
  //     });
  //   }
  // }

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
      case WidgetType.GoogleMap:
        _showGoogleMapEditDialog(widget as GoogleMapWidget, index);
        break;
      case WidgetType.NaverMap:
        _showNaverMapEditDialog(widget as NaverMapWidget, index);
        break;
      case WidgetType.KakaoMap:
        _showKakaoMapEditDialog(widget as KakaoMapWidget, index);
        break;
      case WidgetType.Image:
        _showImageEditDialog(widget as ImageWidget, index);
        break;
      case WidgetType.Gallery:
        _showGalleryEditDialog(widget as GalleryWidget, index);
        break;
      case WidgetType.Schedule:
        _showScheduleEditDialog(widget as ScheduleWidget, index);
        break;
      case WidgetType.CountdownTimer:
        _showCountdownEditDialog(widget as CountdownWidget, index);
        break;
      case WidgetType.Video:
        _showVideoEditDialog(widget as VideoWidget, index);
        break;
      case WidgetType.Button:
        _showButtonEditDialog(widget as ButtonWidget, index);
        break;
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
    Color? backgroundColor;
    String textAlign = widget.data['textAlign'] ?? 'left';
    FontWeight fontWeight = FontWeight.values[widget.data['fontWeight'] ?? 3];
    double letterSpacing = widget.data['letterSpacing']?.toDouble() ?? 0.0;
    double lineHeight = widget.data['lineHeight']?.toDouble() ?? 1.5;
    
    if (widget.data['backgroundColor'] != null) {
      try {
        backgroundColor = Color(int.parse('FF${widget.data['backgroundColor'].substring(1)}', radix: 16));
      } catch (e) {
        backgroundColor = null;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.text_fields, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('텍스트 편집'),
              ],
            ),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Content Section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.edit, 
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '내용',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: textController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: '텍스트',
                                hintText: '텍스트를 입력하세요',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Typography Section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.format_size, 
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '서체 설정',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: fontFamily,
                              decoration: InputDecoration(
                                labelText: '글꼴',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                                  child: Text('나눔고딕'),
                                ),
                                DropdownMenuItem(
                                  value: 'NanumMyeongjo',
                                  child: Text('나눔명조'),
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
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('글자 크기'),
                                    Text(
                                      '${fontSize.toInt()}px',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: fontSize,
                                  min: 8,
                                  max: 72,
                                  divisions: 64,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      fontSize = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<FontWeight>(
                              segments: const [
                                ButtonSegment(
                                  value: FontWeight.w300,
                                  label: Text('가늘게'),
                                ),
                                ButtonSegment(
                                  value: FontWeight.normal,
                                  label: Text('보통'),
                                ),
                                ButtonSegment(
                                  value: FontWeight.bold,
                                  label: Text('굵게'),
                                ),
                              ],
                              selected: {fontWeight},
                              onSelectionChanged: (Set<FontWeight> newSelection) {
                                setDialogState(() {
                                  fontWeight = newSelection.first;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Style Section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.palette, 
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '스타일',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('텍스트 색상'),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
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
                                                  ),
                                                ),
                                                actions: [
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
                                        },
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: textColor,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('배경 색상'),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('배경 색상 선택'),
                                                content: SingleChildScrollView(
                                                  child: ColorPicker(
                                                    pickerColor: backgroundColor ?? Colors.transparent,
                                                    onColorChanged: (color) {
                                                      setDialogState(() {
                                                        backgroundColor = color;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('투명'),
                                                    onPressed: () {
                                                      setDialogState(() {
                                                        backgroundColor = null;
                                                      });
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
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
                                        },
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: backgroundColor ?? Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          child: backgroundColor == null
                                              ? const Center(
                                                  child: Text(
                                                    '투명',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('정렬'),
                            const SizedBox(height: 8),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'left',
                                  icon: Icon(Icons.format_align_left),
                                  label: Text('왼쪽'),
                                ),
                                ButtonSegment(
                                  value: 'center',
                                  icon: Icon(Icons.format_align_center),
                                  label: Text('가운데'),
                                ),
                                ButtonSegment(
                                  value: 'right',
                                  icon: Icon(Icons.format_align_right),
                                  label: Text('오른쪽'),
                                ),
                              ],
                              selected: {textAlign},
                              onSelectionChanged: (Set<String> newSelection) {
                                setDialogState(() {
                                  textAlign = newSelection.first;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Live Preview
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.preview, 
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '미리보기',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: backgroundColor ?? Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                textController.text.isEmpty ? '텍스트를 입력하세요' : textController.text,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontFamily: fontFamily,
                                  color: textColor,
                                  fontWeight: fontWeight,
                                  letterSpacing: letterSpacing,
                                  height: lineHeight,
                                ),
                                textAlign: TextAlign.values.firstWhere(
                                  (align) => align.name == textAlign,
                                  orElse: () => TextAlign.left,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
              ElevatedButton(
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
                  updatedData['backgroundColor'] = backgroundColor != null
                      ? '#${backgroundColor!.value.toRadixString(16).substring(2)}'
                      : null;
                  updatedData['textAlign'] = textAlign;
                  updatedData['fontWeight'] = fontWeight.index;
                  updatedData['letterSpacing'] = letterSpacing;
                  updatedData['lineHeight'] = lineHeight;

                  setState(() {
                    _widgets[index] = TextWidget(
                      id: widget.id,
                      data: updatedData,
                    );
                  });

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
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
        return StatefulBuilder(builder: (context, setDialogState) {
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
                      setDialogState(() {
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
                      setDialogState(() {
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
        });
      },
    );
  }

  void _showMapEditDialog(MapWidget widget, int index) {
    // Implementation for map widget editing
    String venueId = widget.venueId;
    bool showDirections = widget.showDirections;
    bool showControls = widget.showControls;
    double height = widget.height;
    String mapProvider = widget.mapProvider;
    double latitude = widget.latitude;
    double longitude = widget.longitude;
    String venue = widget.venue;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.map, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('지도 설정'),
              ],
            ),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Information Section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, 
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '위치 정보',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: TextEditingController(text: venue),
                              decoration: InputDecoration(
                                labelText: '장소명',
                                prefixIcon: const Icon(Icons.business),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              onChanged: (value) {
                                venue = value;
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(
                                      text: latitude.toString(),
                                    ),
                                    decoration: InputDecoration(
                                      labelText: '위도',
                                      prefixIcon: const Icon(Icons.explore),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      latitude = double.tryParse(value) ?? latitude;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(
                                      text: longitude.toString(),
                                    ),
                                    decoration: InputDecoration(
                                      labelText: '경도',
                                      prefixIcon: const Icon(Icons.explore),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      longitude = double.tryParse(value) ?? longitude;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, 
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '지도에서 직접 위치를 검색하고 선택할 수 있습니다.',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Map Provider Section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.layers, 
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '지도 제공자',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'google',
                                  label: Text('Google'),
                                  icon: Icon(Icons.g_mobiledata),
                                ),
                                ButtonSegment(
                                  value: 'naver',
                                  label: Text('Naver'),
                                  icon: Icon(Icons.map),
                                ),
                                ButtonSegment(
                                  value: 'kakao',
                                  label: Text('Kakao'),
                                  icon: Icon(Icons.map),
                                ),
                              ],
                              selected: {mapProvider},
                              onSelectionChanged: (Set<String> newSelection) {
                                setDialogState(() {
                                  mapProvider = newSelection.first;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Display Options Section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.settings, 
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '표시 옵션',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              title: const Text('길 찾기 버튼'),
                              subtitle: const Text('외부 지도 앱으로 연결되는 버튼을 표시합니다'),
                              value: showDirections,
                              onChanged: (value) {
                                setDialogState(() {
                                  showDirections = value;
                                });
                              },
                              secondary: const Icon(Icons.directions),
                            ),
                            SwitchListTile(
                              title: const Text('지도 컨트롤'),
                              subtitle: const Text('확대/축소 등의 컨트롤을 표시합니다'),
                              value: showControls,
                              onChanged: (value) {
                                setDialogState(() {
                                  showControls = value;
                                });
                              },
                              secondary: const Icon(Icons.control_camera),
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '지도 높이',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      '${height.toInt()}px',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: Theme.of(context).primaryColor,
                                    thumbColor: Theme.of(context).primaryColor,
                                    overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                  ),
                                  child: Slider(
                                    value: height,
                                    min: 200,
                                    max: 600,
                                    divisions: 40,
                                    onChanged: (value) {
                                      setDialogState(() {
                                        height = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Update the widget
                  final updatedData = Map<String, dynamic>.from(widget.data);
                  updatedData['venueId'] = venueId;
                  updatedData['showDirections'] = showDirections;
                  updatedData['showControls'] = showControls;
                  updatedData['height'] = height;
                  updatedData['mapProvider'] = mapProvider;
                  updatedData['latitude'] = latitude;
                  updatedData['longitude'] = longitude;
                  updatedData['venue'] = venue;

                  setState(() {
                    _widgets[index] = MapWidget(
                      id: widget.id,
                      data: updatedData,
                    );
                  });

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('저장'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showGoogleMapEditDialog(GoogleMapWidget widget, int index) {
    // Implementation for Google Maps widget editing
    String venueId = widget.venueId;
    bool showDirections = widget.showDirections;
    bool showControls = widget.showControls;
    double height = widget.height;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Google 지도 설정'),
            content: SingleChildScrollView(
              child: Column(
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
                        setDialogState(() {
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
                      setDialogState(() {
                        showDirections = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('지도 컨트롤 표시'),
                    value: showControls,
                    onChanged: (value) {
                      setDialogState(() {
                        showControls = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('지도 높이: ${height.toInt()}px'),
                  Slider(
                    value: height,
                    min: 200,
                    max: 600,
                    divisions: 40,
                    onChanged: (value) {
                      setDialogState(() {
                        height = value;
                      });
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
                  updatedData['venueId'] = venueId;
                  updatedData['showDirections'] = showDirections;
                  updatedData['showControls'] = showControls;
                  updatedData['height'] = height;

                  setState(() {
                    _widgets[index] = GoogleMapWidget(
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

  void _showNaverMapEditDialog(NaverMapWidget widget, int index) {
    // Implementation for Naver Maps widget editing
    String venueId = widget.venueId;
    bool showDirections = widget.showDirections;
    bool showControls = widget.showControls;
    double height = widget.height;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('네이버 지도 설정'),
            content: SingleChildScrollView(
              child: Column(
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
                        setDialogState(() {
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
                      setDialogState(() {
                        showDirections = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('지도 컨트롤 표시'),
                    value: showControls,
                    onChanged: (value) {
                      setDialogState(() {
                        showControls = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('지도 높이: ${height.toInt()}px'),
                  Slider(
                    value: height,
                    min: 200,
                    max: 600,
                    divisions: 40,
                    onChanged: (value) {
                      setDialogState(() {
                        height = value;
                      });
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
                  updatedData['venueId'] = venueId;
                  updatedData['showDirections'] = showDirections;
                  updatedData['showControls'] = showControls;
                  updatedData['height'] = height;

                  setState(() {
                    _widgets[index] = NaverMapWidget(
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

  void _showKakaoMapEditDialog(KakaoMapWidget widget, int index) {
    // Implementation for Kakao Maps widget editing
    String venueId = widget.venueId;
    bool showDirections = widget.showDirections;
    bool showControls = widget.showControls;
    double height = widget.height;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('카카오 지도 설정'),
            content: SingleChildScrollView(
              child: Column(
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
                        setDialogState(() {
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
                      setDialogState(() {
                        showDirections = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('지도 컨트롤 표시'),
                    value: showControls,
                    onChanged: (value) {
                      setDialogState(() {
                        showControls = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('지도 높이: ${height.toInt()}px'),
                  Slider(
                    value: height,
                    min: 200,
                    max: 600,
                    divisions: 40,
                    onChanged: (value) {
                      setDialogState(() {
                        height = value;
                      });
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
                  updatedData['venueId'] = venueId;
                  updatedData['showDirections'] = showDirections;
                  updatedData['showControls'] = showControls;
                  updatedData['height'] = height;

                  setState(() {
                    _widgets[index] = KakaoMapWidget(
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

  void _showImageEditDialog(ImageWidget widget, int index) {
    final imageUrlController = TextEditingController(text: widget.imageUrl);
    double width = widget.width;
    double height = widget.height;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('이미지 편집'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: '이미지 경로',
                      hintText: 'assets/images/example.jpg',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Enhanced Size Controls
                  const Text(
                    '이미지 크기',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // Wrap in Container with height constraint for AlertDialog compatibility
                  SizedBox(
                    height:
                        400, // Fixed height to prevent viewport issues in AlertDialog
                    child: SingleChildScrollView(
                      child: EnhancedSizeEditor(
                        width: width,
                        height: height,
                        onSizeChanged: (newWidth, newHeight) {
                          setDialogState(() {
                            width = newWidth;
                            height = newHeight;
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
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  final updatedData = Map<String, dynamic>.from(widget.data);
                  updatedData['imageUrl'] = imageUrlController.text;
                  updatedData['width'] = width;
                  updatedData['height'] = height;

                  setState(() {
                    _widgets[index] = ImageWidget(
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

  void _showGalleryEditDialog(GalleryWidget widget, int index) {
    final imageUrls = List<String>.from(widget.imageUrls);
    String layoutType = widget.layoutType;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('갤러리 편집'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('레이아웃 타입:'),
                  DropdownButton<String>(
                    value: layoutType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'carousel',
                        child: Text('캐러셀'),
                      ),
                      DropdownMenuItem(
                        value: 'grid',
                        child: Text('그리드'),
                      ),
                      DropdownMenuItem(
                        value: 'masonry',
                        child: Text('메이슨리'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          layoutType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('이미지 목록:'),
                  const SizedBox(height: 8),
                  ...imageUrls.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final url = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: url),
                              decoration: InputDecoration(
                                labelText: '이미지 ${idx + 1}',
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                imageUrls[idx] = value;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setDialogState(() {
                                imageUrls.removeAt(idx);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('이미지 추가'),
                    onPressed: () {
                      setDialogState(() {
                        imageUrls.add(
                            'assets/images/gallery${imageUrls.length + 1}.jpg');
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  final updatedData = Map<String, dynamic>.from(widget.data);
                  updatedData['imageUrls'] = imageUrls;
                  updatedData['layoutType'] = layoutType;

                  setState(() {
                    _widgets[index] = GalleryWidget(
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

  void _showScheduleEditDialog(ScheduleWidget widget, int index) {
    final events = List<Map<String, dynamic>>.from(widget.events);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('일정 편집'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('일정 목록:'),
                  const SizedBox(height: 8),
                  ...events.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final event = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller:
                                  TextEditingController(text: event['time']),
                              decoration: const InputDecoration(
                                labelText: '시간',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                events[idx]['time'] = value;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: TextEditingController(
                                  text: event['description']),
                              decoration: const InputDecoration(
                                labelText: '내용',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                events[idx]['description'] = value;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setDialogState(() {
                                events.removeAt(idx);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('일정 추가'),
                    onPressed: () {
                      setDialogState(() {
                        events.add({
                          'time': '00:00',
                          'description': '새 일정',
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  final updatedData = Map<String, dynamic>.from(widget.data);
                  updatedData['events'] = events;

                  setState(() {
                    _widgets[index] = ScheduleWidget(
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

  void _showVideoEditDialog(VideoWidget widget, int index) {
    final videoUrlController = TextEditingController(text: widget.videoUrl);
    bool autoPlay = widget.autoPlay;
    bool showControls = widget.showControls;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('비디오 편집'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: videoUrlController,
                  decoration: const InputDecoration(labelText: '비디오 URL'),
                ),
                SwitchListTile(
                  title: const Text('자동 재생'),
                  value: autoPlay,
                  onChanged: (value) => setDialogState(() => autoPlay = value),
                ),
                SwitchListTile(
                  title: const Text('컨트롤 표시'),
                  value: showControls,
                  onChanged: (value) =>
                      setDialogState(() => showControls = value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  final updatedData = Map<String, dynamic>.from(widget.data);
                  updatedData['videoUrl'] = videoUrlController.text;
                  updatedData['autoPlay'] = autoPlay;
                  updatedData['showControls'] = showControls;

                  setState(() {
                    _widgets[index] =
                        VideoWidget(id: widget.id, data: updatedData);
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

  void _showButtonEditDialog(ButtonWidget widget, int index) {
    final textController =
        TextEditingController(text: widget.text.getText('ko'));
    final actionController = TextEditingController(text: widget.actionTarget);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('버튼 편집'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(labelText: '버튼 텍스트'),
              ),
              TextField(
                controller: actionController,
                decoration: const InputDecoration(labelText: '링크 URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final updatedData = Map<String, dynamic>.from(widget.data);
                updatedData['text'] = {
                  'translations': {'ko': textController.text},
                  'default_language': 'ko',
                };
                updatedData['actionTarget'] = actionController.text;

                setState(() {
                  _widgets[index] =
                      ButtonWidget(id: widget.id, data: updatedData);
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

  void _showCountdownEditDialog(CountdownWidget widget, int index) {
    DateTime targetDate = widget.targetDate;
    String format = widget.format;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('카운트다운 편집'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('목표 날짜:'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: targetDate,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        targetDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(text: format),
                  decoration: const InputDecoration(
                    labelText: '표시 형식',
                    hintText: '예: 결혼식까지 {days}일 {hours}시간',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    format = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  final updatedData = Map<String, dynamic>.from(widget.data);
                  updatedData['targetDate'] = targetDate.toIso8601String();
                  updatedData['format'] = format;

                  setState(() {
                    _widgets[index] = CountdownWidget(
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

  // Create image widget with default properties
  ImageWidget _createDefaultImageWidget() {
    return ImageWidget(
      id: _uuid.v4(),
      data: {
        'imageUrl': 'assets/images/gallery1.jpg',
        'width': 200.0,
        'height': 200.0,
        'position': {
          'dx': 100.0,
          'dy': 100.0,
        },
      },
    );
  }

  // Create map widget with default properties
  MapWidget _createDefaultMapWidget() {
    return MapWidget(
      id: _uuid.v4(),
      data: {
        'venueId': 'main_venue',
        'mapProvider': 'google',  // Changed from mapType: 'openstreetmap'
        'showDirections': true,
        'showControls': true,
        'latitude': 37.5642, // The Plaza Hotel Seoul (popular wedding venue)
        'longitude': 126.9758,
        'venue': '그랜드 호텔',
        'height': 300.0,
        'position': {
          'dx': 100.0,
          'dy': 200.0,
        },
      },
    );
  }

  // Create Google Maps widget with default properties
  GoogleMapWidget _createDefaultGoogleMapWidget() {
    return GoogleMapWidget(
      id: _uuid.v4(),
      data: {
        'venueId': 'main_venue',
        'showDirections': true,
        'showControls': true,
        'latitude': 37.5642, // The Plaza Hotel Seoul (popular wedding venue)
        'longitude': 126.9758,
        'venue': '그랜드 호텔',
        'height': 300.0,
        'position': {
          'dx': 100.0,
          'dy': 200.0,
        },
      },
    );
  }

  // Create Naver Maps widget with default properties
  NaverMapWidget _createDefaultNaverMapWidget() {
    return NaverMapWidget(
      id: _uuid.v4(),
      data: {
        'venueId': 'main_venue',
        'showDirections': true,
        'showControls': true,
        'latitude': 37.5642, // The Plaza Hotel Seoul (popular wedding venue)
        'longitude': 126.9758,
        'venue': '그랜드 호텔',
        'height': 300.0,
        'position': {
          'dx': 100.0,
          'dy': 200.0,
        },
      },
    );
  }

  // Create Kakao Maps widget with default properties
  KakaoMapWidget _createDefaultKakaoMapWidget() {
    return KakaoMapWidget(
      id: _uuid.v4(),
      data: {
        'venueId': 'main_venue',
        'showDirections': true,
        'showControls': true,
        'latitude': 37.5642, // The Plaza Hotel Seoul (popular wedding venue)
        'longitude': 126.9758,
        'venue': '그랜드 호텔',
        'height': 300.0,
        'position': {
          'dx': 100.0,
          'dy': 200.0,
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
                onWidgetChanged: (updatedWidget) {
                  final index =
                      _widgets.indexWhere((w) => w.id == updatedWidget.id);
                  if (index != -1) {
                    setState(() {
                      _widgets[index] = updatedWidget;
                    });
                  }
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
                icon: const Icon(Icons.image),
                onPressed: () {
                  // Add image widget
                  _addWidget(_createDefaultImageWidget());
                },
                tooltip: '이미지 추가',
              ),
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  // Add map widget
                  _addWidget(_createDefaultMapWidget());
                },
                tooltip: '지도 추가',
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
