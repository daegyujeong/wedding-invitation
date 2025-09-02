import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ImageUtils {
  static final Map<String, double> _aspectRatioCache = {};
  
  /// Get the aspect ratio of an asset image
  static Future<double> getAssetImageAspectRatio(String assetPath) async {
    // Return cached value if available
    if (_aspectRatioCache.containsKey(assetPath)) {
      return _aspectRatioCache[assetPath]!;
    }
    
    try {
      // Load the image data
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      
      // Decode the image to get dimensions
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;
      
      // Calculate aspect ratio
      final double aspectRatio = image.width / image.height;
      
      // Cache the result
      _aspectRatioCache[assetPath] = aspectRatio;
      
      // Clean up
      image.dispose();
      codec.dispose();
      
      return aspectRatio;
    } catch (e) {
      // Return default aspect ratio if image can't be loaded
      debugPrint('Error getting aspect ratio for $assetPath: $e');
      return 1.0; // Default to square
    }
  }
  
  /// Get multiple aspect ratios at once
  static Future<Map<String, double>> getMultipleAssetImageAspectRatios(
    List<String> assetPaths,
  ) async {
    final Map<String, double> results = {};
    
    for (final path in assetPaths) {
      results[path] = await getAssetImageAspectRatio(path);
    }
    
    return results;
  }
  
  /// Clear the aspect ratio cache
  static void clearCache() {
    _aspectRatioCache.clear();
  }
  
  /// Preload aspect ratios for better performance
  static Future<void> preloadAspectRatios(List<String> assetPaths) async {
    await getMultipleAssetImageAspectRatios(assetPaths);
  }
}