// Custom Page Editor screen
// lib/presentation/screens/editor/custom_page_editor_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/custom_widget_model.dart';
import '../../../data/models/page_model.dart';
import '../../viewmodels/editor_viewmodel.dart';
import '../../widgets/custom_widget_factory.dart';
import 'widget_editor_dialog.dart';

class CustomPageEditorScreen extends StatefulWidget {
  final PageModel page;

  const CustomPageEditorScreen({
    super.key,
    required this.page,
  });

  @override
  _CustomPageEditorScreenState createState() => _CustomPageEditorScreenState();
}

class _CustomPageEditorScreenState extends State<CustomPageEditorScreen> {
  late PageModel _editedPage;

  @override
  void initState() {
    super.initState();
    _editedPage = widget.page;
  }

  void _addWidget(WidgetType type) {
    final newWidget = CustomWidgetModel.create(type);
    setState(() {
      _editedPage = _editedPage.copyWith(
        widgets: [..._editedPage.widgets, newWidget],
      );
    });
    _saveChanges();
  }

  void _updateWidget(CustomWidgetModel updatedWidget) {
    final widgetIndex =
        _editedPage.widgets.indexWhere((w) => w.id == updatedWidget.id);

    if (widgetIndex != -1) {
      List<CustomWidgetModel> updatedWidgets = List.from(_editedPage.widgets);
      updatedWidgets[widgetIndex] = updatedWidget;

      setState(() {
        _editedPage = _editedPage.copyWith(
          widgets: updatedWidgets,
        );
      });
      _saveChanges();
    }
  }

  void _deleteWidget(String widgetId) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위젯 삭제'),
        content: const Text('이 위젯을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _editedPage = _editedPage.copyWith(
                  widgets: _editedPage.widgets
                      .where((w) => w.id != widgetId)
                      .toList(),
                );
              });
              _saveChanges();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _editWidgetProperties(CustomWidgetModel widget) {
    showDialog(
      context: context,
      builder: (context) => WidgetEditorDialog(
        widgetModel: widget,
        onSave: _updateWidget,
      ),
    );
  }

  void _saveChanges() {
    final viewModel = Provider.of<EditorViewModel>(context, listen: false);
    // viewModel.updatePageContent(_editedPage.id, _editedPage.settings);
    // For this implementation, widgets are stored in their own field, not in content
    viewModel.updatePageWidgets(_editedPage.id, _editedPage.widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_editedPage.title} 편집'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
              // Implement undo functionality if needed
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('완료', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        color: Colors.grey[100],
        child: Stack(
          children: [
            // Background color/image
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),

            // Widgets
            ..._editedPage.widgets.map((widget) {
              return CustomWidgetFactory.buildWidget(
                widget,
                onEdit: _updateWidget,
                onDelete: _deleteWidget,
                onEditProperties: _editWidgetProperties,
              );
            }),

            // Add a grid overlay for better positioning
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: GridPainter(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_editedPage.widgets.length} 위젯'),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.preview),
                    onPressed: () {
                      // Implement preview functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // Implement page settings
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "customPageEditorFAB",
        onPressed: () {
          _showAddWidgetDialog();
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showAddWidgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위젯 추가'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWidgetOption(WidgetType.text, '텍스트', Icons.text_fields),
              _buildWidgetOption(WidgetType.image, '이미지', Icons.image),
              _buildWidgetOption(
                  WidgetType.divider, '구분선', Icons.horizontal_rule),
              _buildWidgetOption(WidgetType.button, '버튼', Icons.smart_button),
              _buildWidgetOption(WidgetType.countdown, '카운트다운', Icons.timer),
              _buildWidgetOption(WidgetType.map, '지도', Icons.map),
              _buildWidgetOption(
                  WidgetType.gallery, '갤러리', Icons.photo_library),
              _buildWidgetOption(
                  WidgetType.messageBox, '메시지 상자', Icons.message),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetOption(WidgetType type, String name, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        _addWidget(type);
      },
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (int i = 0; i < size.width; i += 20) {
      canvas.drawLine(
          Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 0; i < size.height; i += 20) {
      canvas.drawLine(
          Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
