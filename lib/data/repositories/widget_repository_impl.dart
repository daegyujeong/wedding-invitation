// lib/data/repositories/widget_repository_impl.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/editor_widget_model.dart';
import 'interfaces/widget_repository.dart';

class WidgetRepositoryImpl implements IWidgetRepository {
  static const String _widgetsKey = 'page_widgets';
  static const String _templatesKey = 'template_presets';
  static const String _historyKey = 'widget_history';
  static const String _statsKey = 'widget_stats';

  @override
  Future<List<EditorWidget>> getWidgetsForPage(String pageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final widgetsJson = prefs.getString('${_widgetsKey}_$pageId');
      
      if (widgetsJson == null) return [];
      
      final List<dynamic> widgetsList = json.decode(widgetsJson);
      return widgetsList.map((json) => EditorWidget.fromJson(json)).toList();
    } catch (e) {
      print('Error loading widgets for page: $e');
      return [];
    }
  }

  @override
  Future<bool> saveWidget(EditorWidget widget, String pageId) async {
    try {
      final widgets = await getWidgetsForPage(pageId);
      
      // Check if widget already exists, update if it does
      final existingIndex = widgets.indexWhere((w) => w.id == widget.id);
      if (existingIndex >= 0) {
        widgets[existingIndex] = widget;
      } else {
        widgets.add(widget);
      }
      
      return await _savePageWidgets(pageId, widgets);
    } catch (e) {
      print('Error saving widget: $e');
      return false;
    }
  }

  @override
  Future<bool> updateWidget(EditorWidget widget) async {
    try {
      // Find which page contains this widget
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('${_widgetsKey}_'));
      
      for (final key in keys) {
        final pageId = key.replaceFirst('${_widgetsKey}_', '');
        final widgets = await getWidgetsForPage(pageId);
        
        final index = widgets.indexWhere((w) => w.id == widget.id);
        if (index >= 0) {
          widgets[index] = widget;
          await _savePageWidgets(pageId, widgets);
          await saveWidgetState(widget.id, widget); // Save to history
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error updating widget: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteWidget(String widgetId, String pageId) async {
    try {
      final widgets = await getWidgetsForPage(pageId);
      widgets.removeWhere((widget) => widget.id == widgetId);
      
      return await _savePageWidgets(pageId, widgets);
    } catch (e) {
      print('Error deleting widget: $e');
      return false;
    }
  }

  @override
  Future<EditorWidget?> getWidgetById(String widgetId) async {
    try {
      // Search across all pages
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('${_widgetsKey}_'));
      
      for (final key in keys) {
        final pageId = key.replaceFirst('${_widgetsKey}_', '');
        final widgets = await getWidgetsForPage(pageId);
        
        try {
          return widgets.firstWhere((widget) => widget.id == widgetId);
        } catch (e) {
          continue;
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting widget by ID: $e');
      return null;
    }
  }

  @override
  Future<bool> reorderWidgets(String pageId, List<String> widgetIds) async {
    try {
      final widgets = await getWidgetsForPage(pageId);
      
      // Create a map for quick lookup
      final widgetMap = {for (var widget in widgets) widget.id: widget};
      
      // Reorder widgets based on the provided order
      final reorderedWidgets = <EditorWidget>[];
      for (final id in widgetIds) {
        if (widgetMap.containsKey(id)) {
          reorderedWidgets.add(widgetMap[id]!);
        }
      }
      
      return await _savePageWidgets(pageId, reorderedWidgets);
    } catch (e) {
      print('Error reordering widgets: $e');
      return false;
    }
  }

  @override
  Future<List<EditorWidget>> getWidgetsByType(WidgetType type) async {
    try {
      List<EditorWidget> allWidgets = [];
      
      // Search across all pages
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('${_widgetsKey}_'));
      
      for (final key in keys) {
        final pageId = key.replaceFirst('${_widgetsKey}_', '');
        final widgets = await getWidgetsForPage(pageId);
        allWidgets.addAll(widgets);
      }
      
      return allWidgets.where((widget) => widget.type == type).toList();
    } catch (e) {
      print('Error getting widgets by type: $e');
      return [];
    }
  }

  @override
  Future<EditorWidget?> duplicateWidget(String widgetId) async {
    try {
      final widget = await getWidgetById(widgetId);
      if (widget == null) return null;
      
      // Create a new widget with a new ID but same data
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      final duplicatedWidget = EditorWidget.fromJson({
        'id': newId,
        'type': widget.type.toString().split('.').last,
        'data': widget.data,
      });
      
      return duplicatedWidget;
    } catch (e) {
      print('Error duplicating widget: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTemplatePresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getString(_templatesKey);
      
      if (templatesJson == null) return [];
      
      final List<dynamic> templatesList = json.decode(templatesJson);
      return templatesList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading template presets: $e');
      return [];
    }
  }

  @override
  Future<bool> saveTemplatePreset(String name, List<EditorWidget> widgets) async {
    try {
      final templates = await getTemplatePresets();
      
      final newTemplate = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'widgets': widgets.map((w) => w.toJson()).toList(),
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      templates.add(newTemplate);
      
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = json.encode(templates);
      return await prefs.setString(_templatesKey, templatesJson);
    } catch (e) {
      print('Error saving template preset: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteTemplatePreset(String presetId) async {
    try {
      final templates = await getTemplatePresets();
      templates.removeWhere((template) => template['id'] == presetId);
      
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = json.encode(templates);
      return await prefs.setString(_templatesKey, templatesJson);
    } catch (e) {
      print('Error deleting template preset: $e');
      return false;
    }
  }

  @override
  Future<bool> applyTemplatePreset(String presetId, String pageId) async {
    try {
      final templates = await getTemplatePresets();
      final template = templates.where((t) => t['id'] == presetId).firstOrNull;
      
      if (template == null) return false;
      
      final List<dynamic> widgetData = template['widgets'];
      final widgets = widgetData.map((json) => EditorWidget.fromJson(json)).toList();
      
      // Generate new IDs for widgets to avoid conflicts
      final updatedWidgets = widgets.map((widget) {
        final newId = DateTime.now().millisecondsSinceEpoch.toString() + '_' + widget.id;
        return EditorWidget.fromJson({
          'id': newId,
          'type': widget.type.toString().split('.').last,
          'data': widget.data,
        });
      }).toList();
      
      return await _savePageWidgets(pageId, updatedWidgets);
    } catch (e) {
      print('Error applying template preset: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> exportPageConfiguration(String pageId) async {
    try {
      final widgets = await getWidgetsForPage(pageId);
      
      return {
        'pageId': pageId,
        'widgets': widgets.map((w) => w.toJson()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error exporting page configuration: $e');
      return null;
    }
  }

  @override
  Future<bool> importPageConfiguration(String pageId, Map<String, dynamic> configuration) async {
    try {
      final List<dynamic> widgetData = configuration['widgets'];
      final widgets = widgetData.map((json) => EditorWidget.fromJson(json)).toList();
      
      return await _savePageWidgets(pageId, widgets);
    } catch (e) {
      print('Error importing page configuration: $e');
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWidgetHistory(String widgetId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('${_historyKey}_$widgetId');
      
      if (historyJson == null) return [];
      
      final List<dynamic> historyList = json.decode(historyJson);
      return historyList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading widget history: $e');
      return [];
    }
  }

  @override
  Future<bool> saveWidgetState(String widgetId, EditorWidget widget) async {
    try {
      final history = await getWidgetHistory(widgetId);
      
      final state = {
        'widget': widget.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      history.add(state);
      
      // Keep only last 10 states
      if (history.length > 10) {
        history.removeAt(0);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(history);
      return await prefs.setString('${_historyKey}_$widgetId', historyJson);
    } catch (e) {
      print('Error saving widget state: $e');
      return false;
    }
  }

  @override
  Future<List<WidgetType>> getAvailableWidgetTypes() async {
    return WidgetType.values;
  }

  @override
  Future<bool> validateWidgetData(EditorWidget widget) async {
    try {
      // Basic validation - can be expanded
      return widget.id.isNotEmpty && widget.data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<WidgetType, int>> getWidgetUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);
      
      Map<WidgetType, int> stats = {};
      
      if (statsJson != null) {
        final Map<String, dynamic> statsData = json.decode(statsJson);
        for (final entry in statsData.entries) {
          final type = WidgetType.values.where((t) => t.toString() == entry.key).firstOrNull;
          if (type != null) {
            stats[type] = entry.value as int;
          }
        }
      }
      
      // Count current widgets if stats don't exist
      if (stats.isEmpty) {
        final keys = prefs.getKeys().where((key) => key.startsWith('${_widgetsKey}_'));
        
        for (final key in keys) {
          final pageId = key.replaceFirst('${_widgetsKey}_', '');
          final widgets = await getWidgetsForPage(pageId);
          
          for (final widget in widgets) {
            stats[widget.type] = (stats[widget.type] ?? 0) + 1;
          }
        }
      }
      
      return stats;
    } catch (e) {
      print('Error getting widget usage stats: $e');
      return {};
    }
  }

  @override
  Future<bool> clearPageWidgets(String pageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('${_widgetsKey}_$pageId');
    } catch (e) {
      print('Error clearing page widgets: $e');
      return false;
    }
  }

  @override
  Future<EditorWidget> getDefaultWidget(WidgetType type) async {
    return EditorWidget.createDefault(type);
  }

  @override
  Future<bool> supportsFeature(String widgetId, String feature) async {
    final widget = await getWidgetById(widgetId);
    if (widget == null) return false;
    
    // Define feature support per widget type
    switch (widget.type) {
      case WidgetType.Text:
        return ['formatting', 'multilingual'].contains(feature);
      case WidgetType.Map:
      case WidgetType.GoogleMap:
      case WidgetType.NaverMap:
      case WidgetType.KakaoMap:
        return ['location', 'directions', 'zoom'].contains(feature);
      case WidgetType.Gallery:
        return ['slideshow', 'thumbnails', 'fullscreen'].contains(feature);
      case WidgetType.CountdownTimer:
      case WidgetType.DDay:
        return ['customFormat', 'timezone'].contains(feature);
      default:
        return false;
    }
  }

  // Private helper method
  Future<bool> _savePageWidgets(String pageId, List<EditorWidget> widgets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final widgetsJson = json.encode(widgets.map((w) => w.toJson()).toList());
      return await prefs.setString('${_widgetsKey}_$pageId', widgetsJson);
    } catch (e) {
      print('Error saving page widgets: $e');
      return false;
    }
  }
}