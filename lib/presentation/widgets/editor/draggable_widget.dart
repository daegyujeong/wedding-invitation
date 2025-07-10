import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/editor_widget_model.dart';
import 'widget_renderer.dart';
import 'draggable_widget_controller.dart';

class DraggableWidget extends StatefulWidget {
  final EditorWidget editorWidget;
  final Function(EditorWidget) onWidgetChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Size? canvasSize;
  final int zIndex;

  const DraggableWidget({
    super.key,
    required this.editorWidget,
    required this.onWidgetChanged,
    required this.onEdit,
    required this.onDelete,
    this.canvasSize,
    this.zIndex = 0,
  });

  @override
  _DraggableWidgetState createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget>
    with TickerProviderStateMixin {
  late DraggableWidgetController _controller;

  late AnimationController _elevationController;
  late AnimationController _scaleController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  // Track drag start position to calculate proper offset
  Offset? _dragStartPosition;

  @override
  void initState() {
    super.initState();

    _controller = DraggableWidgetController(
      editorWidget: widget.editorWidget,
      onWidgetChanged: widget.onWidgetChanged,
      canvasSize: widget.canvasSize,
    );

    _controller.addListener(_onControllerStateChanged);

    _elevationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(DraggableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editorWidget != widget.editorWidget) {
      _controller.syncWithWidget(widget.editorWidget);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    _controller.dispose();
    _elevationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onControllerStateChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild when controller state changes
      });
    }
  }

  void _onDragStarted() {
    _controller.setDragging(true);
    _dragStartPosition = _controller.position;
    _elevationController.forward();
    _scaleController.forward();
  }

  void _onDragEnd(DraggableDetails details) {
    _controller.setDragging(false);
    _dragStartPosition = null;
    _elevationController.reverse();
    _scaleController.reverse();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Update position using delta from pan gesture
    final Offset currentPosition = _controller.position;
    final Offset newPosition = currentPosition + details.delta;
    _controller.updatePosition(newPosition, immediate: false);
  }

  void _onTap() {
    _controller.setSelected(!_controller.isSelected);
  }

  Widget _buildDraggableContent() {
    return AnimatedBuilder(
      animation: Listenable.merge([_elevationAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            elevation: _elevationAnimation.value,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              decoration: BoxDecoration(
                border: _controller.isSelected
                    ? Border.all(color: Colors.blue, width: 2)
                    : _controller.isDragging
                        ? Border.all(
                            color: Colors.blue.withOpacity(0.5), width: 1)
                        : null,
                borderRadius: BorderRadius.circular(4),
                boxShadow: _controller.isDragging
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                          spreadRadius: 2,
                        ),
                      ]
                    : _controller.isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
              ),
              child: Stack(
                children: [
                  WidgetRenderer(
                    widget: widget.editorWidget,
                    isEditMode: true,
                    onWidgetUpdated: widget.onWidgetChanged,
                  ),
                  if (_controller.isSelected && !_controller.isDragging)
                    _buildControlOverlay(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              top: -8,
              child: Row(
                children: [
                  _buildControlButton(
                    icon: Icons.edit,
                    color: Colors.blue,
                    onTap: widget.onEdit,
                  ),
                  const SizedBox(width: 4),
                  _buildControlButton(
                    icon: Icons.delete,
                    color: Colors.red,
                    onTap: widget.onDelete,
                  ),
                ],
              ),
            ),
            Positioned(
              left: -8,
              top: -8,
              child: Column(
                children: [
                  _buildControlButton(
                    icon: Icons.keyboard_arrow_up,
                    color: Colors.green,
                    onTap: () => _controller.bringToFront(),
                    tooltip: 'Bring to front',
                  ),
                  const SizedBox(height: 4),
                  if (_controller.canUndo)
                    _buildControlButton(
                      icon: Icons.undo,
                      color: Colors.orange,
                      onTap: () => _controller.undo(),
                      tooltip: 'Undo',
                    ),
                  if (_controller.canRedo)
                    _buildControlButton(
                      icon: Icons.redo,
                      color: Colors.orange,
                      onTap: () => _controller.redo(),
                      tooltip: 'Redo',
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.drag_indicator,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
            if (kDebugMode)
              Positioned(
                bottom: -8,
                left: -8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'Z:${_controller.zIndex}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );

    return tooltip != null ? Tooltip(message: tooltip, child: button) : button;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _controller.position.dx,
      top: _controller.position.dy,
      child: GestureDetector(
        onTap: _onTap,
        onPanStart: (details) => _onDragStarted(),
        onPanUpdate: _onPanUpdate,
        onPanEnd: (details) => _onDragEnd(DraggableDetails(
          wasAccepted: false,
          velocity: details.velocity,
          offset: Offset.zero, // Not used anymore
        )),
        child: _buildDraggableContent(),
      ),
    );
  }
}
