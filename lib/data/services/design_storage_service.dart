import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedding_invitation/data/models/editor_widget_model.dart';
import 'package:wedding_invitation/presentation/viewmodels/editor_viewmodel.dart';

class DesignStorageService {
  static const String _designKey = 'wedding_design';

  // Save the current design
  Future<void> saveDesign(WeddingDesign design) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert widgets to JSON
    final widgetsJson = design.widgets.map((w) => w.toJson()).toList();
    
    // Create a map with all design data
    final designMap = {
      'widgets': widgetsJson,
      'backgroundColor': {
        'r': design.backgroundColor.red,
        'g': design.backgroundColor.green,
        'b': design.backgroundColor.blue,
        'a': design.backgroundColor.alpha,
      },
      'backgroundImagePath': design.backgroundImagePath,
    };
    
    // Save as JSON string
    await prefs.setString(_designKey, jsonEncode(designMap));
    
    // If background image exists, ensure it's saved properly
    if (design.backgroundImagePath != null) {
      // We're assuming the image is already saved somewhere accessible
      // In a real app, you might want to copy it to your app's directory
    }
  }

  // Load a saved design
  Future<WeddingDesign?> loadDesign() async {
    final prefs = await SharedPreferences.getInstance();
    final designJson = prefs.getString(_designKey);
    
    if (designJson == null) {
      return null;
    }
    
    try {
      final designMap = jsonDecode(designJson) as Map<String, dynamic>;
      
      // Parse widgets
      final widgetsJson = designMap['widgets'] as List;
      final widgets = widgetsJson
          .map((json) => EditorWidget.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Parse background color
      final colorMap = designMap['backgroundColor'] as Map<String, dynamic>;
      final backgroundColor = Color.fromARGB(
        colorMap['a'],
        colorMap['r'],
        colorMap['g'],
        colorMap['b'],
      );
      
      // Get background image path
      final backgroundImagePath = designMap['backgroundImagePath'] as String?;
      
      return WeddingDesign(
        widgets: widgets,
        backgroundColor: backgroundColor,
        backgroundImagePath: backgroundImagePath,
      );
    } catch (e) {
      debugPrint('Error parsing design: $e');
      return null;
    }
  }

  // Delete a saved design
  Future<void> deleteDesign() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_designKey);
  }
}