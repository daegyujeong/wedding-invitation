import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:wedding_invitation/data/models/editor_widget_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

/// 위젯 편집 다이얼로그
class WidgetEditorDialog extends StatefulWidget {
  final EditorWidget? widget;
  final Function(EditorWidget) onSave;

  const WidgetEditorDialog({
    Key? key,
    this.widget,
    required this.onSave,
  }) : super(key: key);

  @override
  State<WidgetEditorDialog> createState() => _WidgetEditorDialogState();
}

class _WidgetEditorDialogState extends State<WidgetEditorDialog> {
  late WidgetType _selectedType;
  late Map<String, dynamic> _editedProperties;
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    // 위젯이 있으면 해당 위젯의 속성 로드, 없으면 기본값
    _selectedType = widget.widget?.type ?? WidgetType.Text;
    _editedProperties = widget.widget != null 
      ? Map<String, dynamic>.from(widget.widget!.data)
      : _getDefaultProperties(_selectedType);
  }
  
  Map<String, dynamic> _getDefaultProperties(WidgetType type) {
    switch (type) {
      case WidgetType.Text:
        return {
          'text': {
            'translations': {'ko': '새 텍스트'},
            'default_language': 'ko',
          },
          'fontSize': 16.0,
          'fontFamily': 'Roboto',
          'color': '#000000',
          'position': {
            'dx': 100.0,
            'dy': 100.0,
          },
        };
      case WidgetType.DDay:
        return {
          'eventId': '',
          'format': 'D-{days}',
          'style': 'default',
          'position': {
            'dx': 100.0,
            'dy': 100.0,
          },
        };
      case WidgetType.Map:
        return {
          'venueId': '',
          'mapType': 'google',
          'showDirections': true,
          'position': {
            'dx': 100.0,
            'dy': 100.0,
          },
        };
      case WidgetType.CountdownTimer:
        return {
          'targetDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'format': 'standard',
          'position': {
            'dx': 100.0,
            'dy': 100.0,
          },
        };
      case WidgetType.Image:
        return {
          'imageUrl': '',
          'width': 200.0,
          'height': 200.0,
          'position': {
            'dx': 100.0,
            'dy': 100.0,
          },
        };
      case WidgetType.Gallery:
        return {
          'imageUrls': [],
          'layoutType': 'horizontal',
          'position': {
            'dx': 100.0,
            'dy': 100.0,
          },
        };
      case WidgetType.Schedule:
        return {
          'events': [
            {
              'time': '12:00',
              'description': '식전 행사',
            },
            {
              'time': '13:00',
              'description': '본식',
            },
          ],
          'position': {
            'dx': 100.0,
            'dy': 100.0,
          },
        };
      default:
        return {
          'position': {
            'dx': 100.0,
            'dy': 100.0,
          },
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.widget == null ? '위젯 추가' : '위젯 편집'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 위젯 타입 선택 (새 위젯 추가시에만)
              if (widget.widget == null) _buildWidgetTypeSelector(),
              
              const SizedBox(height: 16),
              
              // 위젯 타입에 따른 편집 필드
              _buildEditFields(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveWidget,
          child: const Text('저장'),
        ),
      ],
    );
  }

  Widget _buildWidgetTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('위젯 타입', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<WidgetType>(
          value: _selectedType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: [
            DropdownMenuItem(
              value: WidgetType.Text,
              child: Text('텍스트'),
            ),
            DropdownMenuItem(
              value: WidgetType.DDay,
              child: Text('D-day'),
            ),
            DropdownMenuItem(
              value: WidgetType.Map,
              child: Text('지도'),
            ),
            DropdownMenuItem(
              value: WidgetType.CountdownTimer,
              child: Text('카운트다운'),
            ),
            DropdownMenuItem(
              value: WidgetType.Image,
              child: Text('이미지'),
            ),
            DropdownMenuItem(
              value: WidgetType.Gallery,
              child: Text('갤러리'),
            ),
            DropdownMenuItem(
              value: WidgetType.Schedule,
              child: Text('일정'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedType = value;
                _editedProperties = _getDefaultProperties(value);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildEditFields() {
    switch (_selectedType) {
      case WidgetType.Text:
        return _buildTextEditorFields();
      case WidgetType.DDay:
        return _buildDDayEditorFields();
      case WidgetType.Map:
        return _buildMapEditorFields();
      case WidgetType.CountdownTimer:
        return _buildCountdownEditorFields();
      case WidgetType.Image:
        return _buildImageEditorFields();
      case WidgetType.Gallery:
        return _buildGalleryEditorFields();
      case WidgetType.Schedule:
        return _buildScheduleEditorFields();
      default:
        return const Text('지원되지 않는 위젯 타입입니다.');
    }
  }

  Widget _buildTextEditorFields() {
    String text = '';
    if (_editedProperties['text'] is Map) {
      final textMap = _editedProperties['text'] as Map;
      if (textMap['translations'] is Map) {
        final translations = textMap['translations'] as Map;
        text = translations['ko'] as String? ?? '';
      }
    }
    
    final fontSize = (_editedProperties['fontSize'] as num?)?.toDouble() ?? 16.0;
    final color = _editedProperties['color'] ?? '#000000';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: text,
          decoration: const InputDecoration(
            labelText: '텍스트',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '텍스트를 입력해주세요';
            }
            return null;
          },
          onChanged: (value) {
            if (_editedProperties['text'] is! Map) {
              _editedProperties['text'] = {
                'translations': {'ko': value},
                'default_language': 'ko',
              };
            } else {
              final textMap = Map<String, dynamic>.from(_editedProperties['text'] as Map);
              if (textMap['translations'] is! Map) {
                textMap['translations'] = {'ko': value};
              } else {
                final translations = Map<String, dynamic>.from(textMap['translations'] as Map);
                translations['ko'] = value;
                textMap['translations'] = translations;
              }
              _editedProperties['text'] = textMap;
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        const Text('글자 크기', style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: fontSize,
          min: 8,
          max: 40,
          divisions: 32,
          label: fontSize.round().toString(),
          onChanged: (value) {
            setState(() {
              _editedProperties['fontSize'] = value;
            });
          },
        ),
        
        const SizedBox(height: 16),
        
        _buildDividerEditorFields(),
      ],
    );
  }

  Widget _buildDividerEditorFields() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _getColorFromHex(_editedProperties['color'] ?? '#000000'),
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

  Widget _buildDDayEditorFields() {
    final format = _editedProperties['format'] ?? 'D-{days}';
    final style = _editedProperties['style'] ?? 'default';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('표시 형식', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: format,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
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
                _editedProperties['format'] = value;
              });
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        const Text('스타일', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: style,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
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
                _editedProperties['style'] = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildMapEditorFields() {
    final mapType = _editedProperties['mapType'] ?? 'google';
    final showDirections = _editedProperties['showDirections'] ?? true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('지도 유형', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: mapType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(
              value: 'google',
              child: Text('구글 지도'),
            ),
            DropdownMenuItem(
              value: 'kakao',
              child: Text('카카오 지도'),
            ),
            DropdownMenuItem(
              value: 'naver',
              child: Text('네이버 지도'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _editedProperties['mapType'] = value;
              });
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        SwitchListTile(
          title: const Text('경로 안내 표시'),
          value: showDirections,
          onChanged: (value) {
            setState(() {
              _editedProperties['showDirections'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCountdownEditorFields() {
    final targetDateStr = _editedProperties['targetDate'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String();
    final targetDate = DateTime.tryParse(targetDateStr) ?? DateTime.now().add(const Duration(days: 30));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('목표 날짜', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: targetDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
            );
            
            if (pickedDate != null) {
              setState(() {
                _editedProperties['targetDate'] = pickedDate.toIso8601String();
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${targetDate.year}/${targetDate.month}/${targetDate.day}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageEditorFields() {
    final imageUrl = _editedProperties['imageUrl'] ?? '';
    final width = (_editedProperties['width'] as num?)?.toDouble() ?? 200.0;
    final height = (_editedProperties['height'] as num?)?.toDouble() ?? 200.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: width / height,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl.isEmpty
                ? const Icon(Icons.image, size: 50, color: Colors.grey)
                : null,
          ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('이미지 선택'),
            onPressed: () async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              
              if (pickedFile != null) {
                // 실제 구현에서는 파일을 업로드하고 URL을 받아와야 함
                setState(() {
                  // 임시로 파일 경로를 URL처럼 저장
                  _editedProperties['imageUrl'] = pickedFile.path;
                });
              }
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: width.toString(),
                decoration: const InputDecoration(
                  labelText: '너비',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    setState(() {
                      _editedProperties['width'] = parsed;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: height.toString(),
                decoration: const InputDecoration(
                  labelText: '높이',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    setState(() {
                      _editedProperties['height'] = parsed;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGalleryEditorFields() {
    final List<String> imageUrls = List<String>.from(_editedProperties['imageUrls'] ?? []);
    final layoutType = _editedProperties['layoutType'] ?? 'horizontal';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('이미지 목록', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: imageUrls.isEmpty
              ? const Center(child: Text('이미지를 추가해주세요'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(imageUrls[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  imageUrls.removeAt(index);
                                  _editedProperties['imageUrls'] = imageUrls;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('이미지 추가'),
            onPressed: () async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              
              if (pickedFile != null) {
                // 실제 구현에서는 파일을 업로드하고 URL을 받아와야 함
                setState(() {
                  // 임시로 파일 경로를 URL처럼 저장
                  imageUrls.add(pickedFile.path);
                  _editedProperties['imageUrls'] = imageUrls;
                });
              }
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        const Text('레이아웃', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: layoutType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(
              value: 'horizontal',
              child: Text('가로 스크롤'),
            ),
            DropdownMenuItem(
              value: 'grid',
              child: Text('그리드'),
            ),
            DropdownMenuItem(
              value: 'slider',
              child: Text('슬라이더'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _editedProperties['layoutType'] = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildScheduleEditorFields() {
    final List<Map<String, dynamic>> events = List<Map<String, dynamic>>.from(_editedProperties['events'] ?? []);
    
    if (events.isEmpty) {
      events.add({'time': '', 'description': ''});
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('일정 목록', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: events[index]['time'],
                      decoration: const InputDecoration(
                        labelText: '시간',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          events[index]['time'] = value;
                          _editedProperties['events'] = events;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      initialValue: events[index]['description'],
                      decoration: const InputDecoration(
                        labelText: '설명',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          events[index]['description'] = value;
                          _editedProperties['events'] = events;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        events.removeAt(index);
                        _editedProperties['events'] = events;
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
        
        const SizedBox(height: 8),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('일정 추가'),
            onPressed: () {
              setState(() {
                events.add({'time': '', 'description': ''});
                _editedProperties['events'] = events;
              });
            },
          ),
        ),
      ],
    );
  }

  void _showColorPicker(String propertyName) {
    final currentColor = _getColorFromHex(_editedProperties[propertyName] ?? '#000000');
    Color pickedColor = currentColor;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
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
                  _editedProperties[propertyName] = '#${pickedColor.value.toRadixString(16).substring(2)}';
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

  Color _getColorFromHex(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.black;
    }
  }

  void _saveWidget() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    final uuid = const Uuid();
    final id = widget.widget?.id ?? uuid.v4();
    
    EditorWidget editorWidget;
    
    switch (_selectedType) {
      case WidgetType.Text:
        editorWidget = TextWidget(id: id, data: _editedProperties);
        break;
      case WidgetType.DDay:
        editorWidget = DDayWidget(id: id, data: _editedProperties);
        break;
      case WidgetType.Map:
        editorWidget = MapWidget(id: id, data: _editedProperties);
        break;
      case WidgetType.CountdownTimer:
        editorWidget = CountdownWidget(id: id, data: _editedProperties);
        break;
      case WidgetType.Image:
        editorWidget = ImageWidget(id: id, data: _editedProperties);
        break;
      case WidgetType.Gallery:
        editorWidget = GalleryWidget(id: id, data: _editedProperties);
        break;
      case WidgetType.Schedule:
        editorWidget = ScheduleWidget(id: id, data: _editedProperties);
        break;
      default:
        editorWidget = TextWidget(id: id, data: _editedProperties);
    }
    
    widget.onSave(editorWidget);
    Navigator.pop(context);
  }
}