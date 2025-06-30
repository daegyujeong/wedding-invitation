import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/custom_widget_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:async';

class CustomWidgetFactory {
  static Widget buildWidget(
    CustomWidgetModel model, {
    Function(CustomWidgetModel)? onEdit,
    Function(String)? onDelete,
    Function(CustomWidgetModel)? onEditProperties,
  }) {
    // Wrap in a positioned widget if we're in the editor
    Widget widget = _buildWidgetByType(model);

    if (onEdit != null) {
      // We're in edit mode, add a draggable container with edit controls
      return Positioned(
        left: model.positionX,
        top: model.positionY,
        child: GestureDetector(
          onPanUpdate: (details) {
            final updatedModel = model.copyWith(
              positionX: model.positionX + details.delta.dx,
              positionY: model.positionY + details.delta.dy,
            );
            onEdit(updatedModel);
          },
          child: Container(
            width: model.width,
            height: model.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Stack(
              children: [
                Positioned.fill(child: widget),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.blue,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.white, size: 14),
                          onPressed: () {
                            // Show edit dialog
                            if (onEditProperties != null) {
                              onEditProperties(model);
                            }
                          },
                          iconSize: 14,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.white, size: 14),
                          onPressed: () {
                            // Delete widget
                            if (onDelete != null) {
                              onDelete(model.id);
                            }
                          },
                          iconSize: 14,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Resize handles
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      final updatedModel = model.copyWith(
                        width: model.width + details.delta.dx > 50
                            ? model.width + details.delta.dx
                            : 50,
                        height: model.height + details.delta.dy > 50
                            ? model.height + details.delta.dy
                            : 50,
                      );
                      onEdit(updatedModel);
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.open_with,
                          color: Colors.white, size: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Just return the positioned widget for normal viewing
      return Positioned(
        left: model.positionX,
        top: model.positionY,
        width: model.width,
        height: model.height,
        child: widget,
      );
    }
  }

  static Widget _buildWidgetByType(CustomWidgetModel model) {
    switch (model.type) {
      case WidgetType.text:
        return _buildTextWidget(model);
      case WidgetType.image:
        return _buildImageWidget(model);
      case WidgetType.divider:
        return _buildDividerWidget(model);
      case WidgetType.button:
        return _buildButtonWidget(model);
      case WidgetType.countdown:
        return _buildCountdownWidget(model);
      case WidgetType.map:
        return _buildMapWidget(model);
      case WidgetType.gallery:
        return _buildGalleryWidget(model);
      case WidgetType.messageBox:
        return _buildMessageBoxWidget(model);
      default:
        return Container(
          child: const Center(child: Text('지원되지 않는 위젯 유형')),
        );
    }
  }

  static Widget _buildTextWidget(CustomWidgetModel model) {
    final text = model.properties['text']?.toString() ?? '텍스트를 입력하세요';
    final fontSize = (model.properties['fontSize'] as num?)?.toDouble() ?? 16.0;

    // Fix fontWeight handling
    final fontWeightValue = model.properties['fontWeight'];
    FontWeight fontWeight = FontWeight.normal;
    if (fontWeightValue is int && fontWeightValue < FontWeight.values.length) {
      fontWeight = FontWeight.values[fontWeightValue];
    } else if (fontWeightValue is String) {
      switch (fontWeightValue.toLowerCase()) {
        case 'bold':
          fontWeight = FontWeight.bold;
          break;
        case 'w100':
          fontWeight = FontWeight.w100;
          break;
        case 'w200':
          fontWeight = FontWeight.w200;
          break;
        case 'w300':
          fontWeight = FontWeight.w300;
          break;
        case 'w400':
          fontWeight = FontWeight.w400;
          break;
        case 'w500':
          fontWeight = FontWeight.w500;
          break;
        case 'w600':
          fontWeight = FontWeight.w600;
          break;
        case 'w700':
          fontWeight = FontWeight.w700;
          break;
        case 'w800':
          fontWeight = FontWeight.w800;
          break;
        case 'w900':
          fontWeight = FontWeight.w900;
          break;
        default:
          fontWeight = FontWeight.normal;
      }
    }

    final colorValue = model.properties['color'] ?? Colors.black.value;

    // Fix text alignment handling
    final textAlignValue = model.properties['textAlign'];
    TextAlign textAlign = TextAlign.center;
    if (textAlignValue is int && textAlignValue < TextAlign.values.length) {
      textAlign = TextAlign.values[textAlignValue];
    }

    return Container(
      width: model.width,
      height: model.height,
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Color(colorValue is int ? colorValue : Colors.black.value),
        ),
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        maxLines: 10,
      ),
    );
  }

  static Widget _buildImageWidget(CustomWidgetModel model) {
    final imagePath = model.properties['imagePath'] ??
        model.properties['imageUrl'] ??
        'assets/images/placeholder.png';
    final fitIndex = model.properties['fit'] ?? BoxFit.cover.index;
    final boxFit = fitIndex is int && fitIndex < BoxFit.values.length
        ? BoxFit.values[fitIndex]
        : BoxFit.cover;

    return SizedBox(
      width: model.width,
      height: model.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          fit: boxFit,
          width: model.width,
          height: model.height,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: model.width,
              height: model.height,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported,
                      size: 32, color: Colors.grey.shade600),
                  const SizedBox(height: 8),
                  Text('이미지 없음',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _buildDividerWidget(CustomWidgetModel model) {
    final thickness =
        (model.properties['thickness'] as num?)?.toDouble() ?? 1.0;
    final colorValue = model.properties['color'] ?? Colors.grey.value;

    return SizedBox(
      width: model.width,
      height: model.height,
      child: Center(
        child: Container(
          width: model.width,
          height: thickness,
          color: Color(colorValue is int ? colorValue : Colors.grey.value),
        ),
      ),
    );
  }

  static Widget _buildButtonWidget(CustomWidgetModel model) {
    final text = model.properties['text']?.toString() ?? '버튼';
    final colorValue = model.properties['color'] ?? Colors.blue.value;
    final textColorValue = model.properties['textColor'] ?? Colors.white.value;

    return SizedBox(
      width: model.width,
      height: model.height,
      child: ElevatedButton(
        onPressed: () {
          // Handle button action based on model.properties['action']
          final action = model.properties['action'];
          final target = model.properties['actionTarget'];

          // In a real app, you would handle different actions here
          print('Button pressed: $action, target: $target');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Color(colorValue is int ? colorValue : Colors.blue.value),
          foregroundColor: Color(
              textColorValue is int ? textColorValue : Colors.white.value),
          minimumSize: Size(model.width, model.height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  static Widget _buildCountdownWidget(CustomWidgetModel model) {
    final title = model.properties['title']?.toString() ?? '결혼식까지';
    final endDateStr = model.properties['endDate'] ??
        DateTime.now().add(const Duration(days: 30)).toIso8601String();
    final endDate = DateTime.tryParse(endDateStr) ??
        DateTime.now().add(const Duration(days: 30));
    final showSeconds = model.properties['showSeconds'] ?? true;

    return CountdownWidget(
      title: title,
      endDate: endDate,
      showSeconds: showSeconds,
      width: model.width,
      height: model.height,
    );
  }

  static Widget _buildMapWidget(CustomWidgetModel model) {
    final latitude =
        (model.properties['latitude'] as num?)?.toDouble() ?? 37.5665;
    final longitude =
        (model.properties['longitude'] as num?)?.toDouble() ?? 126.978;
    final title = model.properties['title']?.toString() ?? '위치';
    final description = model.properties['description']?.toString() ?? '';

    return Container(
      width: model.width,
      height: model.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(latitude, longitude),
            zoom: 15.0,
            maxZoom: 18.0,
            minZoom: 10.0,
            interactiveFlags:
                InteractiveFlag.none, // Disable interaction in preview
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.wedding_invitation',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(latitude, longitude),
                  width: 80,
                  height: 80,
                  builder: (ctx) => Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildGalleryWidget(CustomWidgetModel model) {
    final images = model.properties['images'] ??
        [
          'assets/images/gallery1.jpg',
          'assets/images/gallery2.jpg',
          'assets/images/gallery3.jpg'
        ];
    final showDots = model.properties['showDots'] ?? true;
    final autoScroll = model.properties['autoScroll'] ?? false;

    if (images is! List || images.isEmpty) {
      return Container(
        width: model.width,
        height: model.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library, size: 50, color: Colors.grey),
              SizedBox(height: 8),
              Text('갤러리가 비어있습니다', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: model.width,
      height: model.height,
      child: CarouselSlider(
        options: CarouselOptions(
          height: model.height,
          autoPlay: autoScroll,
          viewportFraction: 1.0,
          enableInfiniteScroll: images.length > 1,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: false,
          scrollDirection: Axis.horizontal,
        ),
        items: images.map<Widget>((item) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: model.width,
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    item.toString(),
                    fit: BoxFit.cover,
                    width: model.width,
                    height: model.height,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: model.width,
                        height: model.height,
                        color: Colors.grey[300],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('이미지 로드 실패',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  static Widget _buildMessageBoxWidget(CustomWidgetModel model) {
    final title = model.properties['title']?.toString() ?? '축하 메시지';
    final placeholder =
        model.properties['placeholder']?.toString() ?? '메시지를 남겨주세요';
    final showSubmitButton = model.properties['showSubmitButton'] ?? true;

    return Container(
      width: model.width,
      height: model.height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: placeholder,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: null,
              expands: true,
            ),
          ),
          if (showSubmitButton) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle message submission
                  print('Message submitted');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  '메시지 전송',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Updated countdown widget to be stateful for real-time updates
class CountdownWidget extends StatefulWidget {
  final String title;
  final DateTime endDate;
  final bool showSeconds;
  final double width;
  final double height;

  const CountdownWidget({
    super.key,
    required this.title,
    required this.endDate,
    this.showSeconds = true,
    required this.width,
    required this.height,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final remaining = widget.endDate.difference(now);

    if (mounted) {
      setState(() {
        _remaining = remaining.isNegative ? Duration.zero : remaining;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate remaining time
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeUnit(days, '일'),
                  _buildSeparator(),
                  _buildTimeUnit(hours, '시간'),
                  _buildSeparator(),
                  _buildTimeUnit(minutes, '분'),
                  if (widget.showSeconds) ...[
                    _buildSeparator(),
                    _buildTimeUnit(seconds, '초'),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
