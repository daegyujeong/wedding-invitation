import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum WidgetType {
  text,
  image,
  video,
  divider,
  button,
  countdown,
  map,
  gallery,
  messageBox
}

class CustomWidgetModel {
  final String id;
  final WidgetType type;
  final Map<String, dynamic> properties;
  final double positionX;
  final double positionY;
  final double width;
  final double height;

  CustomWidgetModel({
    required this.id,
    required this.type,
    required this.properties,
    required this.positionX,
    required this.positionY,
    required this.width,
    required this.height,
  });

  // Convenience getters for backward compatibility
  Offset get position => Offset(positionX, positionY);
  Size get size => Size(width, height);

  factory CustomWidgetModel.create(WidgetType type) {
    const uuid = Uuid();
    // Default properties based on widget type
    Map<String, dynamic> defaultProps = {};

    double defaultWidth = 300;
    double defaultHeight = 100;

    switch (type) {
      case WidgetType.text:
        defaultProps = {
          'text': '텍스트를 입력하세요',
          'fontSize': 16.0,
          'fontWeight': FontWeight.normal.index,
          'color': Colors.black.value,
          'textAlign': TextAlign.center.index,
        };
        defaultHeight = 50;
        break;
      case WidgetType.image:
        defaultProps = {
          'imagePath': 'assets/images/placeholder.png',
          'fit': BoxFit.cover.index,
        };
        defaultHeight = 200;
        break;
      case WidgetType.video:
        defaultProps = {
          'videoUrl': '',
          'autoPlay': false,
          'showControls': true,
          'loop': false,
          'muted': false,
        };
        defaultHeight = 200;
        break;
      case WidgetType.divider:
        defaultProps = {
          'thickness': 1.0,
          'color': Colors.grey.value,
        };
        defaultHeight = 20;
        break;
      case WidgetType.button:
        defaultProps = {
          'text': '버튼',
          'color': Colors.blue.value,
          'textColor': Colors.white.value,
          'action': 'none',
          'actionTarget': '',
        };
        defaultHeight = 50;
        defaultWidth = 150;
        break;
      case WidgetType.countdown:
        defaultProps = {
          'title': '결혼식까지',
          'endDate':
              DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'showSeconds': true,
        };
        defaultHeight = 120;
        break;
      case WidgetType.map:
        defaultProps = {
          'latitude': 37.5665,
          'longitude': 126.978,
          'zoom': 15.0,
          'title': '그랜드 호텔',
          'description': '서울시 강남구',
        };
        defaultHeight = 250;
        break;
      case WidgetType.gallery:
        defaultProps = {
          'images': [
            'assets/images/placeholder.png',
          ],
          'showDots': true,
          'autoScroll': false,
        };
        defaultHeight = 250;
        break;
      case WidgetType.messageBox:
        defaultProps = {
          'title': '축하 메시지',
          'placeholder': '메시지를 남겨주세요',
          'showSubmitButton': true,
        };
        defaultHeight = 200;
        break;
    }

    return CustomWidgetModel(
      id: uuid.v4(),
      type: type,
      properties: defaultProps,
      positionX: 50,
      positionY: 50,
      width: defaultWidth,
      height: defaultHeight,
    );
  }

  CustomWidgetModel copyWith({
    String? id,
    WidgetType? type,
    Map<String, dynamic>? properties,
    double? positionX,
    double? positionY,
    double? width,
    double? height,
  }) {
    return CustomWidgetModel(
      id: id ?? this.id,
      type: type ?? this.type,
      properties: properties ?? Map.from(this.properties),
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'properties': properties,
      'positionX': positionX,
      'positionY': positionY,
      'width': width,
      'height': height,
    };
  }

  factory CustomWidgetModel.fromJson(Map<String, dynamic> json) {
    return CustomWidgetModel(
      id: json['id'],
      type: WidgetType.values[json['type']],
      properties: Map<String, dynamic>.from(json['properties']),
      positionX: (json['positionX'] as num?)?.toDouble() ?? 0.0,
      positionY: (json['positionY'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 100.0,
      height: (json['height'] as num?)?.toDouble() ?? 100.0,
    );
  }

  @override
  String toString() {
    return 'CustomWidgetModel{id: $id, type: $type, properties: $properties, position: ($positionX, $positionY), size: ($width, $height)}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomWidgetModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}