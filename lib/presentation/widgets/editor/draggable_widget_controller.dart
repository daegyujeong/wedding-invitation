import 'package:flutter/material.dart';
import 'dart:async';
import '../../../data/models/editor_widget_model.dart';

/// Controller class that manages draggable widget state independently from UI
/// Implements state persistence mechanism and debounced updates
class DraggableWidgetController extends ChangeNotifier {
  final EditorWidget editorWidget;
  final Size? canvasSize;
  final Function(EditorWidget) onWidgetChanged;

  // Internal state
  Offset _position = Offset.zero;
  bool _isSelected = false;
  bool _isDragging = false;
  int _zIndex = 0;

  // Debouncing for performance
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 100);

  // State history for undo/redo functionality
  final List<Map<String, dynamic>> _stateHistory = [];
  int _currentHistoryIndex = -1;
  static const int _maxHistorySize = 20;

  DraggableWidgetController({
    required this.editorWidget,
    required this.onWidgetChanged,
    this.canvasSize,
  }) {
    _initializeState();
  }

  // Getters for state access
  Offset get position => _position;
  bool get isSelected => _isSelected;
  bool get isDragging => _isDragging;
  int get zIndex => _zIndex;

  // History management
  bool get canUndo => _currentHistoryIndex > 0;
  bool get canRedo => _currentHistoryIndex < _stateHistory.length - 1;

  /// Initialize state from widget data
  void _initializeState() {
    _position = _extractPositionFromData();
    _zIndex = editorWidget.data['zIndex'] as int? ?? 0;
    _saveStateToHistory();
  }

  /// Extract position from widget data with fallback
  Offset _extractPositionFromData() {
    final positionData = editorWidget.data['position'];
    if (positionData != null) {
      try {
        return Offset(
          (positionData['dx'] as num).toDouble(),
          (positionData['dy'] as num).toDouble(),
        );
      } catch (e) {
        debugPrint('Error parsing position data: $e');
      }
    }
    return const Offset(100, 100); // Default position
  }

  /// Update position with boundary constraints and debouncing
  void updatePosition(Offset newPosition, {bool immediate = false}) {
    final constrainedPosition = _constrainPosition(newPosition);

    if (_position != constrainedPosition) {
      _position = constrainedPosition;
      notifyListeners();

      if (immediate) {
        _persistPosition();
      } else {
        _debouncedPersistPosition();
      }
    }
  }

  /// Apply boundary constraints to position
  Offset _constrainPosition(Offset newPosition) {
    if (canvasSize == null) return newPosition;

    // Estimate widget size (could be improved with actual measurements)
    const Size estimatedWidgetSize = Size(100, 50);

    final double maxX = canvasSize!.width - estimatedWidgetSize.width;
    final double maxY = canvasSize!.height - estimatedWidgetSize.height;

    return Offset(
      newPosition.dx
          .clamp(0.0, maxX.isNaN || maxX.isInfinite ? newPosition.dx : maxX),
      newPosition.dy
          .clamp(0.0, maxY.isNaN || maxY.isInfinite ? newPosition.dy : maxY),
    );
  }

  /// Debounced position persistence for performance
  void _debouncedPersistPosition() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _persistPosition();
    });
  }

  /// Persist position to widget data
  void _persistPosition() {
    editorWidget.data['position'] = {
      'dx': _position.dx,
      'dy': _position.dy,
    };
    onWidgetChanged(editorWidget);
    _saveStateToHistory();
  }

  /// Update selection state
  void setSelected(bool selected) {
    if (_isSelected != selected) {
      _isSelected = selected;
      notifyListeners();

      if (selected) {
        bringToFront();
      }
    }
  }

  /// Update dragging state
  void setDragging(bool dragging) {
    if (_isDragging != dragging) {
      _isDragging = dragging;
      notifyListeners();

      if (dragging) {
        bringToFront();
      }
    }
  }

  /// Bring widget to front by setting high z-index
  void bringToFront() {
    const int frontZIndex = 1000;
    updateZIndex(frontZIndex);
  }

  /// Update z-index
  void updateZIndex(int newZIndex) {
    if (_zIndex != newZIndex) {
      _zIndex = newZIndex;
      editorWidget.data['zIndex'] = newZIndex;
      notifyListeners();
      onWidgetChanged(editorWidget);
      _saveStateToHistory();
    }
  }

  /// Save current state to history for undo/redo
  void _saveStateToHistory() {
    // Remove any future history if we're not at the end
    if (_currentHistoryIndex < _stateHistory.length - 1) {
      _stateHistory.removeRange(_currentHistoryIndex + 1, _stateHistory.length);
    }

    // Add current state
    final stateSnapshot = {
      'position': {'dx': _position.dx, 'dy': _position.dy},
      'zIndex': _zIndex,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _stateHistory.add(stateSnapshot);
    _currentHistoryIndex = _stateHistory.length - 1;

    // Limit history size
    if (_stateHistory.length > _maxHistorySize) {
      _stateHistory.removeAt(0);
      _currentHistoryIndex--;
    }
  }

  /// Undo last state change
  void undo() {
    if (canUndo) {
      _currentHistoryIndex--;
      _restoreStateFromHistory();
    }
  }

  /// Redo next state change
  void redo() {
    if (canRedo) {
      _currentHistoryIndex++;
      _restoreStateFromHistory();
    }
  }

  /// Restore state from history
  void _restoreStateFromHistory() {
    if (_currentHistoryIndex >= 0 &&
        _currentHistoryIndex < _stateHistory.length) {
      final state = _stateHistory[_currentHistoryIndex];

      final positionData = state['position'] as Map<String, dynamic>;
      _position = Offset(
        (positionData['dx'] as num).toDouble(),
        (positionData['dy'] as num).toDouble(),
      );

      _zIndex = state['zIndex'] as int;

      // Update widget data
      editorWidget.data['position'] = positionData;
      editorWidget.data['zIndex'] = _zIndex;

      notifyListeners();
      onWidgetChanged(editorWidget);
    }
  }

  /// Sync with external widget changes
  void syncWithWidget(EditorWidget newWidget) {
    final newPosition = _extractPositionFromData();
    final newZIndex = newWidget.data['zIndex'] as int? ?? 0;

    bool hasChanges = false;

    if (_position != newPosition) {
      _position = newPosition;
      hasChanges = true;
    }

    if (_zIndex != newZIndex) {
      _zIndex = newZIndex;
      hasChanges = true;
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Reset to initial state
  void reset() {
    _position = _extractPositionFromData();
    _zIndex = editorWidget.data['zIndex'] as int? ?? 0;
    _isSelected = false;
    _isDragging = false;
    _stateHistory.clear();
    _currentHistoryIndex = -1;
    _saveStateToHistory();
    notifyListeners();
  }

  /// Get current state as a map for debugging
  Map<String, dynamic> getStateSnapshot() {
    return {
      'position': {'dx': _position.dx, 'dy': _position.dy},
      'isSelected': _isSelected,
      'isDragging': _isDragging,
      'zIndex': _zIndex,
      'historySize': _stateHistory.length,
      'historyIndex': _currentHistoryIndex,
    };
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
