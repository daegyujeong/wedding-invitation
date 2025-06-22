import 'package:flutter/material.dart';
import '../../../data/models/editor_widget_model.dart';
import 'widget_renderer.dart';

class DraggableWidget extends StatefulWidget {
  final EditorWidget editorWidget;
  final Function(Offset) onPositionChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DraggableWidget({
    Key? key,
    required this.editorWidget,
    required this.onPositionChanged,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  _DraggableWidgetState createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  late Offset position;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    // Get position from the widget's data or default to center
    position = widget.editorWidget.data['position'] != null
        ? Offset(
            widget.editorWidget.data['position']['dx'],
            widget.editorWidget.data['position']['dy'],
          )
        : const Offset(100, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position = Offset(
              position.dx + details.delta.dx,
              position.dy + details.delta.dy,
            );
            widget.onPositionChanged(position);
          });
        },
        onTap: () {
          setState(() {
            isSelected = !isSelected;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: Stack(
            children: [
              // Actual widget content
              WidgetRenderer(widget: widget.editorWidget),
              
              // Control buttons (visible when selected)
              if (isSelected)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onEdit,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 16,
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
    );
  }
}
