import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wedding_invitation/data/models/editor_widget_model.dart';
import 'package:wedding_invitation/presentation/viewmodels/editor_viewmodel.dart';
import 'package:wedding_invitation/presentation/screens/editor/widget_selector_screen.dart';
import 'package:wedding_invitation/presentation/widgets/editor/draggable_widget.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  @override
  void initState() {
    super.initState();
    // Load saved design if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EditorViewModel>(context, listen: false).loadDesign();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('청첩장 편집'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Provider.of<EditorViewModel>(context, listen: false).saveDesign();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('저장되었습니다!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: () {
              // Navigate to preview screen
              Navigator.pushNamed(context, '/preview');
            },
          ),
        ],
      ),
      body: Consumer<EditorViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              // Background (can be customized later)
              Container(
                decoration: BoxDecoration(
                  color: viewModel.backgroundColor,
                  image: viewModel.backgroundImage != null
                      ? DecorationImage(
                          image: FileImage(viewModel.backgroundImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              
              // Widget canvas - where widgets are placed
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: viewModel.widgets.map((widget) {
                    return DraggableWidget(
                      key: ValueKey(widget.id),
                      editorWidget: widget,
                      onPositionChanged: (offset) {
                        viewModel.updateWidgetPosition(widget.id, offset);
                      },
                      onEdit: () {
                        viewModel.editWidget(widget.id, context);
                      },
                      onDelete: () {
                        viewModel.removeWidget(widget.id);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Show widget selector
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WidgetSelectorScreen(
                onWidgetSelected: (widget) {
                  Provider.of<EditorViewModel>(context, listen: false)
                      .addWidget(widget);
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () {
                  Provider.of<EditorViewModel>(context, listen: false)
                      .pickBackgroundImage();
                },
                tooltip: '배경 이미지 변경',
              ),
              IconButton(
                icon: const Icon(Icons.color_lens),
                onPressed: () {
                  Provider.of<EditorViewModel>(context, listen: false)
                      .pickBackgroundColor(context);
                },
                tooltip: '배경 색상 변경',
              ),
              IconButton(
                icon: const Icon(Icons.text_fields),
                onPressed: () {
                  // Shortcut to add text widget
                  final viewModel = Provider.of<EditorViewModel>(context, listen: false);
                  viewModel.addWidget(viewModel.createDefaultTextWidget());
                },
                tooltip: '텍스트 추가',
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  // Shortcut to add D-day widget
                  final viewModel = Provider.of<EditorViewModel>(context, listen: false);
                  viewModel.addWidget(viewModel.createDefaultDDayWidget());
                },
                tooltip: 'D-day 추가',
              ),
            ],
          ),
        ),
      ),
    );
  }
}