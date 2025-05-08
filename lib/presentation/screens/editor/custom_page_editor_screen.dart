// Finally, let's create a Custom Page Editor screen
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
    setState(() {
      _editedPage = _editedPage.copyWith(
        widgets: _editedPage.widgets.where((w) => w.id != widgetId).toList(),
      );
    });
    _saveChanges();
  }

  void _editWidget(CustomWidgetModel widget) {
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
    viewModel.updatePageContent(_editedPage.id, _editedPage.content);
    // For this implementation, widgets are stored in their own field, not in content
    viewModel.updatePageWidgets(_editedPage.id, _editedPage.widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_editedPage.title} 편집'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('완료', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            // Background color/image
            Container(
              color: Colors.grey[100],
            ),

            // Widgets
            ..._editedPage.widgets.map((widget) {
              return CustomWidgetFactory.buildWidget(
                widget,
                onEdit: _updateWidget,
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWidgetDialog();
        },
        child: const Icon(Icons.add),
      ),
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
