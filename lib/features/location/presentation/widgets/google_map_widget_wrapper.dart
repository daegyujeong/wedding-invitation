import 'package:flutter/material.dart';
import 'google_map_widget.dart';

/// Wrapper widget that safely initializes Google Maps to avoid JSON parsing errors
class GoogleMapWidgetWrapper extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String venue;
  final bool showControls;
  final double zoom;
  final double height;

  const GoogleMapWidgetWrapper({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.venue,
    this.showControls = true,
    this.zoom = 16.0,
    this.height = 300.0,
  });

  @override
  State<GoogleMapWidgetWrapper> createState() => _GoogleMapWidgetWrapperState();
}

class _GoogleMapWidgetWrapperState extends State<GoogleMapWidgetWrapper> {
  bool _showMap = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Use post frame callback to ensure proper initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Add a small delay to let the widget tree settle
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _showMap = true;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              '지도를 불러올 수 없습니다',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (!_showMap) {
      return Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '지도 로딩 중...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Wrap in error boundary
    return ErrorBoundary(
      onError: (error, stackTrace) {
        debugPrint('Google Map Error: $error');
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      },
      child: GoogleMapWidget(
        latitude: widget.latitude,
        longitude: widget.longitude,
        venue: widget.venue,
        showControls: widget.showControls,
        zoom: widget.zoom,
        height: widget.height,
      ),
    );
  }
}

/// Error boundary widget to catch and handle errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final void Function(Object error, StackTrace stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  @override
  void initState() {
    super.initState();
    // Override Flutter error handler for this widget
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('JSON') ||
          details.exception.toString().contains('_mapStyles')) {
        // Suppress JSON parsing errors from Google Maps
        debugPrint('Suppressed Google Maps JSON error');
        widget.onError?.call(details.exception, details.stack ?? StackTrace.current);
      } else {
        // Re-throw other errors
        FlutterError.presentError(details);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}