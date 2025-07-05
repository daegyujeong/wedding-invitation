// Fixed version of the _buildMapWidget method from widget_renderer.dart
// This file demonstrates the fix for BoxConstraints infinite width error

import 'package:flutter/material.dart';
import '../../../data/models/editor_widget_model.dart';
import '../../../features/location/presentation/widgets/multi_map_widget.dart';
import '../../../features/location/presentation/widgets/multi_map_widget.dart' show MapProvider;

class WidgetRendererFix {
  final bool isEditMode;
  
  WidgetRendererFix({required this.isEditMode});

  // FIXED VERSION: This method prevents the BoxConstraints infinite width error
  Widget buildMapWidget(MapWidget mapWidget) {
    // Parse map provider
    MapProvider provider = MapProvider.google;
    switch (mapWidget.mapProvider.toLowerCase()) {
      case 'naver':
        provider = MapProvider.naver;
        break;
      case 'kakao':
        provider = MapProvider.kakao;
        break;
      default:
        provider = MapProvider.google;
    }

    // CRITICAL FIX: Always wrap map widgets in SizedBox with finite dimensions
    // This prevents the "BoxConstraints forces an infinite width" error
    return SizedBox(
      width: double.infinity, // Take full width of parent
      height: mapWidget.height, // Use specified height from widget
      child: MultiMapWidget(
        latitude: mapWidget.latitude,
        longitude: mapWidget.longitude,
        venue: mapWidget.venue,
        provider: provider,
        showControls: !isEditMode && mapWidget.showControls,
        showDirections: !isEditMode && mapWidget.showDirections,
        height: mapWidget.height,
        isEditMode: isEditMode,
        onMapTap: isEditMode ? () {
          // In edit mode, you might want to open a dialog to select map provider
          debugPrint('Map provider selection in edit mode');
        } : null,
      ),
    );
  }

  // Alternative implementation using LayoutBuilder for more control
  Widget buildMapWidgetWithLayoutBuilder(MapWidget mapWidget) {
    // Parse map provider
    MapProvider provider = MapProvider.google;
    switch (mapWidget.mapProvider.toLowerCase()) {
      case 'naver':
        provider = MapProvider.naver;
        break;
      case 'kakao':
        provider = MapProvider.kakao;
        break;
      default:
        provider = MapProvider.google;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Ensure we have finite constraints
        final double width = constraints.maxWidth.isFinite 
            ? constraints.maxWidth 
            : MediaQuery.of(context).size.width;
        
        return Container(
          width: width,
          height: mapWidget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MultiMapWidget(
              latitude: mapWidget.latitude,
              longitude: mapWidget.longitude,
              venue: mapWidget.venue,
              provider: provider,
              showControls: !isEditMode && mapWidget.showControls,
              showDirections: !isEditMode && mapWidget.showDirections,
              height: mapWidget.height,
              isEditMode: isEditMode,
              onMapTap: isEditMode ? () {
                debugPrint('Map provider selection in edit mode');
              } : null,
            ),
          ),
        );
      },
    );
  }
}

// Quick fix utility functions
class MapWidgetConstraintFixes {
  
  // Fix 1: Wrap any map widget with SizedBox
  static Widget wrapWithSizedBox(Widget mapWidget, {double height = 300}) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: mapWidget,
    );
  }
  
  // Fix 2: Wrap with Container having specific dimensions
  static Widget wrapWithContainer(Widget mapWidget, {double? width, double height = 300}) {
    return Container(
      width: width,
      height: height,
      child: mapWidget,
    );
  }
  
  // Fix 3: Wrap with Flexible for use in Column/Row
  static Widget wrapWithFlexible(Widget mapWidget, {int flex = 1}) {
    return Flexible(
      flex: flex,
      child: mapWidget,
    );
  }
  
  // Fix 4: Wrap with Expanded for use in Column/Row
  static Widget wrapWithExpanded(Widget mapWidget, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: mapWidget,
    );
  }
}

/* 
INSTRUCTIONS TO APPLY THE FIX:

1. Update your existing widget_renderer.dart file:
   Replace the _buildMapWidget method with the buildMapWidget method from this file.

2. The key change is wrapping the MultiMapWidget in a SizedBox:
   
   OLD CODE:
   return MultiMapWidget(...)
   
   NEW CODE:
   return SizedBox(
     width: double.infinity,
     height: mapWidget.height,
     child: MultiMapWidget(...),
   );

3. This ensures the map widget always receives finite constraints,
   preventing the "BoxConstraints forces an infinite width" error.
*/