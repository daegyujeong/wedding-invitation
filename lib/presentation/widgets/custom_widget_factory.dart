import 'package:flutter/material.dart';
import '../../data/models/custom_widget_model.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
                          icon: const Icon(Icons.edit, color: Colors.white, size: 14),
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
                          icon: const Icon(Icons.delete, color: Colors.white, size: 14),
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
                        width: model.width + details.delta.dx > 50 ? model.width + details.delta.dx : 50,
                        height: model.height + details.delta.dy > 50 ? model.height + details.delta.dy : 50,
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
                      child: const Icon(Icons.open_with, color: Colors.white, size: 12),
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
    final text = model.properties['text'] ?? '';
    final fontSize = (model.properties['fontSize'] as num?)?.toDouble() ?? 16.0;
    final fontWeightIndex = model.properties['fontWeight'] ?? 0;
    final colorValue = model.properties['color'] ?? Colors.black.value;
    final textAlignIndex = model.properties['textAlign'] ?? TextAlign.center.index;

    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.values[fontWeightIndex],
          color: Color(colorValue),
        ),
        textAlign: TextAlign.values[textAlignIndex],
      ),
    );
  }

  static Widget _buildImageWidget(CustomWidgetModel model) {
    final imagePath = model.properties['imagePath'] ?? 'assets/images/gallery1.jpg';
    final fitIndex = model.properties['fit'] ?? BoxFit.cover.index;

    return Image.asset(
      imagePath,
      fit: BoxFit.values[fitIndex],
      width: model.width,
      height: model.height,
    );
  }

  static Widget _buildDividerWidget(CustomWidgetModel model) {
    final thickness = (model.properties['thickness'] as num?)?.toDouble() ?? 1.0;
    final colorValue = model.properties['color'] ?? Colors.grey.value;

    return Center(
      child: Container(
        width: model.width,
        height: thickness,
        color: Color(colorValue),
      ),
    );
  }

  static Widget _buildButtonWidget(CustomWidgetModel model) {
    final text = model.properties['text'] ?? '버튼';
    final colorValue = model.properties['color'] ?? Colors.blue.value;
    final textColorValue = model.properties['textColor'] ?? Colors.white.value;

    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Handle button action based on model.properties['action']
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(colorValue),
          foregroundColor: Color(textColorValue),
          minimumSize: Size(model.width, model.height),
        ),
        child: Text(text),
      ),
    );
  }

  static Widget _buildCountdownWidget(CustomWidgetModel model) {
    final title = model.properties['title'] ?? '결혼식까지';
    final endDateStr = model.properties['endDate'] ?? 
      DateTime.now().add(const Duration(days: 30)).toIso8601String();
    final endDate = DateTime.parse(endDateStr);
    final showSeconds = model.properties['showSeconds'] ?? true;

    return CountdownWidget(
      title: title,
      endDate: endDate,
      showSeconds: showSeconds,
    );
  }

  static Widget _buildMapWidget(CustomWidgetModel model) {
    final latitude = (model.properties['latitude'] as num?)?.toDouble() ?? 37.5665;
    final longitude = (model.properties['longitude'] as num?)?.toDouble() ?? 126.978;
    final title = model.properties['title'] ?? '위치';
    final description = model.properties['description'] ?? '';

    // Placeholder for actual map
    return Container(
      width: model.width,
      height: model.height,
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 50),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (description.isNotEmpty) 
              Text(description, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text('위도: $latitude, 경도: $longitude', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  static Widget _buildGalleryWidget(CustomWidgetModel model) {
    final images = model.properties['images'] ?? 
      ['assets/images/gallery1.jpg', 'assets/images/gallery2.jpg', 'assets/images/gallery3.jpg'];
    final showDots = model.properties['showDots'] ?? true;
    final autoScroll = model.properties['autoScroll'] ?? false;

    return CarouselSlider(
      options: CarouselOptions(
        height: model.height,
        autoPlay: autoScroll,
        viewportFraction: 1.0,
        enableInfiniteScroll: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
        aspectRatio: 16/9,
      ),
      items: (images as List).map<Widget>((item) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: model.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: const BoxDecoration(
                color: Colors.grey,
              ),
              child: Image.asset(
                item,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }).toList(),
    );
  }

  static Widget _buildMessageBoxWidget(CustomWidgetModel model) {
    final title = model.properties['title'] ?? '축하 메시지';
    final placeholder = model.properties['placeholder'] ?? '메시지를 남겨주세요';
    final showSubmitButton = model.properties['showSubmitButton'] ?? true;

    return Container(
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
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
          ),
          if (showSubmitButton) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle message submission
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

// Custom countdown widget
class CountdownWidget extends StatelessWidget {
  final String title;
  final DateTime endDate;
  final bool showSeconds;

  const CountdownWidget({
    Key? key,
    required this.title,
    required this.endDate,
    this.showSeconds = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    // Calculate remaining time
    final days = difference.inDays;
    final hours = difference.inHours.remainder(24);
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    return Container(
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
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnit(days, '일'),
              _buildSeparator(),
              _buildTimeUnit(hours, '시간'),
              _buildSeparator(),
              _buildTimeUnit(minutes, '분'),
              if (showSeconds) ...[
                _buildSeparator(),
                _buildTimeUnit(seconds, '초'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label) {
    return Column(
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}