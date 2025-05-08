import 'package:flutter/material.dart';
import 'package:wedding_invitation/data/models/editor_widget_model.dart';

/// Widget 유형에 따라 적절한 위젯을 생성하는 팩토리 클래스
class CustomWidgetFactory {
  /// 위젯 타입에 따라 해당 위젯을 생성
  static Widget _buildWidgetByType(CustomWidgetModel model) {
    switch (model.type) {
      case WidgetType.CountdownTimer:
        return _buildCountdownWidget(model);
      case WidgetType.Map:
        return _buildMapWidget(model);
      case WidgetType.Gallery:
        return _buildGalleryWidget(model);
      case WidgetType.Text:
        return _buildTextWidget(model);
      case WidgetType.Image:
        return _buildImageWidget(model);
      case WidgetType.DDay:
        return _buildDDayWidget(model);
      case WidgetType.Schedule:
        return _buildScheduleWidget(model);
      default:
        return Container(
          child: const Center(child: Text('지원되지 않는 위젯 유형')),
        );
    }
  }

  // 카운트다운 위젯 생성
  static Widget _buildCountdownWidget(CustomWidgetModel model) {
    // 날짜 계산 및 카운트다운 위젯 구현
    final targetDate = DateTime.parse(model.properties['date'] ?? '2025-05-31');
    final now = DateTime.now();
    final remaining = targetDate.difference(now);
    
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            model.properties['title'] ?? '결혼식까지',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _countdownBox(days.toString(), '일'),
              const SizedBox(width: 8),
              _countdownBox(hours.toString().padLeft(2, '0'), '시간'),
              const SizedBox(width: 8), 
              _countdownBox(minutes.toString().padLeft(2, '0'), '분'),
              const SizedBox(width: 8),
              _countdownBox(seconds.toString().padLeft(2, '0'), '초'),
            ],
          ),
        ],
      ),
    );
  }

  // 카운트다운 박스 위젯
  static Widget _countdownBox(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // 지도 위젯 생성
  static Widget _buildMapWidget(CustomWidgetModel model) {
    // 지도 위젯 구현
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage('assets/images/map_placeholder.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Icon(Icons.location_on, color: Colors.red, size: 32),
      ),
    );
  }

  // 갤러리 위젯 생성
  static Widget _buildGalleryWidget(CustomWidgetModel model) {
    // 갤러리 위젯 구현
    final List<String> images = List<String>.from(model.properties['images'] ?? []);
    
    return Container(
      width: 250,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.isEmpty ? 1 : images.length,
        itemBuilder: (context, index) {
          if (images.isEmpty) {
            return Container(
              width: 120,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.photo_library, color: Colors.grey),
              ),
            );
          }
          
          return Container(
            width: 120,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  // 텍스트 위젯 생성
  static Widget _buildTextWidget(CustomWidgetModel model) {
    final text = model.properties['text'] ?? '';
    final fontSize = (model.properties['fontSize'] as num?)?.toDouble() ?? 16.0;
    final fontWeight = _getFontWeight(model.properties['fontWeight'] ?? 0);
    final color = _getColor(model.properties['color'] ?? '#000000');
    
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }

  // 이미지 위젯 생성
  static Widget _buildImageWidget(CustomWidgetModel model) {
    final imageUrl = model.properties['imageUrl'] ?? '';
    final width = (model.properties['width'] as num?)?.toDouble() ?? 200.0;
    final height = (model.properties['height'] as num?)?.toDouble() ?? 200.0;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : const AssetImage('assets/images/placeholder.png') as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // D-day 위젯 생성
  static Widget _buildDDayWidget(CustomWidgetModel model) {
    final eventDate = DateTime.parse(model.properties['date'] ?? '2025-05-31');
    final now = DateTime.now();
    final daysRemaining = eventDate.difference(now).inDays;
    final format = model.properties['format'] ?? 'D-{days}';
    final displayText = format.replaceAll('{days}', daysRemaining.toString());
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        displayText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 일정 위젯 생성
  static Widget _buildScheduleWidget(CustomWidgetModel model) {
    final List<Map<String, dynamic>> events = 
        List<Map<String, dynamic>>.from(model.properties['events'] ?? []);
    
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            model.properties['title'] ?? '결혼식 일정',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...events.map((event) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  event['time'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(event['description'] ?? '')),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  // 헬퍼 메서드: FontWeight 변환
  static FontWeight _getFontWeight(int weight) {
    switch (weight) {
      case 1:
        return FontWeight.w100;
      case 2:
        return FontWeight.w200;
      case 3:
        return FontWeight.w300;
      case 4:
        return FontWeight.w400;
      case 5:
        return FontWeight.w500;
      case 6:
        return FontWeight.w600;
      case 7:
        return FontWeight.w700;
      case 8:
        return FontWeight.w800;
      case 9:
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }
  
  // 헬퍼 메서드: 색상 변환
  static Color _getColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.black;
    }
  }
}

// 위젯 에디터에서 사용할 모델 클래스
class CustomWidgetModel {
  final String id;
  final WidgetType type;
  final Map<String, dynamic> properties;
  
  CustomWidgetModel({
    required this.id,
    required this.type,
    required this.properties,
  });
  
  factory CustomWidgetModel.fromEditorWidget(EditorWidget widget) {
    return CustomWidgetModel(
      id: widget.id,
      type: widget.type,
      properties: widget.data,
    );
  }
  
  EditorWidget toEditorWidget() {
    switch (type) {
      case WidgetType.Text:
        return TextWidget(id: id, data: properties);
      case WidgetType.DDay:
        return DDayWidget(id: id, data: properties);
      case WidgetType.Map:
        return MapWidget(id: id, data: properties);
      case WidgetType.Image:
        return ImageWidget(id: id, data: properties);
      case WidgetType.Gallery:
        return GalleryWidget(id: id, data: properties);
      case WidgetType.Schedule:
        return ScheduleWidget(id: id, data: properties);
      case WidgetType.CountdownTimer:
        return CountdownWidget(id: id, data: properties);
      default:
        return TextWidget(id: id, data: properties);
    }
  }
}