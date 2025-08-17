// lib/data/repositories/interfaces/widget_repository.dart
import '../../models/editor_widget_model.dart';

/// Abstract repository interface for widget and template operations
abstract class IWidgetRepository {
  /// Get all widgets for a page
  Future<List<EditorWidget>> getWidgetsForPage(String pageId);

  /// Save a widget
  Future<bool> saveWidget(EditorWidget widget, String pageId);

  /// Update widget
  Future<bool> updateWidget(EditorWidget widget);

  /// Delete widget
  Future<bool> deleteWidget(String widgetId, String pageId);

  /// Get widget by ID
  Future<EditorWidget?> getWidgetById(String widgetId);

  /// Reorder widgets on a page
  Future<bool> reorderWidgets(String pageId, List<String> widgetIds);

  /// Get widgets by type
  Future<List<EditorWidget>> getWidgetsByType(WidgetType type);

  /// Duplicate widget
  Future<EditorWidget?> duplicateWidget(String widgetId);

  /// Get template presets
  Future<List<Map<String, dynamic>>> getTemplatePresets();

  /// Save template preset
  Future<bool> saveTemplatePreset(String name, List<EditorWidget> widgets);

  /// Delete template preset
  Future<bool> deleteTemplatePreset(String presetId);

  /// Apply template preset to page
  Future<bool> applyTemplatePreset(String presetId, String pageId);

  /// Export page configuration
  Future<Map<String, dynamic>?> exportPageConfiguration(String pageId);

  /// Import page configuration
  Future<bool> importPageConfiguration(String pageId, Map<String, dynamic> configuration);

  /// Get widget configuration history
  Future<List<Map<String, dynamic>>> getWidgetHistory(String widgetId);

  /// Save widget state for undo/redo
  Future<bool> saveWidgetState(String widgetId, EditorWidget widget);

  /// Get available widget types
  Future<List<WidgetType>> getAvailableWidgetTypes();

  /// Validate widget data
  Future<bool> validateWidgetData(EditorWidget widget);

  /// Get widget usage statistics
  Future<Map<WidgetType, int>> getWidgetUsageStats();

  /// Clear all widgets for a page
  Future<bool> clearPageWidgets(String pageId);

  /// Get default widget configuration
  Future<EditorWidget> getDefaultWidget(WidgetType type);

  /// Check if widget supports feature
  Future<bool> supportsFeature(String widgetId, String feature);
}