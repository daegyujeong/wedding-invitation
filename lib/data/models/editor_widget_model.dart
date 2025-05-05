import 'package:wedding_invitation/data/models/invitation_model.dart';

enum WidgetType {
  Text,
  Image,
  Map,
  CountdownTimer,
  DDay,
  Gallery,
  Schedule,
}

abstract class EditorWidget {
  final String id;
  final WidgetType type;
  final Map<String, dynamic> data;

  EditorWidget({
    required this.id,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toJson();

  factory EditorWidget.fromJson(Map<String, dynamic> json) {
    final type = WidgetType.values.firstWhere(
      (e) => e.toString() == 'WidgetType.${json['type']}',
      orElse: () => WidgetType.Text,
    );

    switch (type) {
      case WidgetType.Text:
        return TextWidget.fromJson(json);
      case WidgetType.Image:
        return ImageWidget.fromJson(json);
      case WidgetType.Map:
        return MapWidget.fromJson(json);
      case WidgetType.CountdownTimer:
        return CountdownWidget.fromJson(json);
      case WidgetType.DDay:
        return DDayWidget.fromJson(json);
      case WidgetType.Gallery:
        return GalleryWidget.fromJson(json);
      case WidgetType.Schedule:
        return ScheduleWidget.fromJson(json);
    }
  }
}

class TextWidget extends EditorWidget {
  TextWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Text);

  MultiLanguageText get text => MultiLanguageText.fromJson(data['text']);
  String get fontFamily => data['fontFamily'];
  double get fontSize => data['fontSize'];
  String get color => data['color'];

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory TextWidget.fromJson(Map<String, dynamic> json) {
    return TextWidget(
      id: json['id'],
      data: json['data'],
    );
  }
}

class DDayWidget extends EditorWidget {
  DDayWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.DDay);

  String get eventId => data['eventId'];
  String get format => data['format'];
  String get style => data['style'];

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory DDayWidget.fromJson(Map<String, dynamic> json) {
    return DDayWidget(
      id: json['id'],
      data: json['data'],
    );
  }
}

class MapWidget extends EditorWidget {
  MapWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Map);

  String get venueId => data['venueId'];
  String get mapType => data['mapType'];
  bool get showDirections => data['showDirections'];

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory MapWidget.fromJson(Map<String, dynamic> json) {
    return MapWidget(
      id: json['id'],
      data: json['data'],
    );
  }
}

class ImageWidget extends EditorWidget {
  ImageWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Image);

  String get imageUrl => data['imageUrl'];
  double get width => data['width'];
  double get height => data['height'];

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory ImageWidget.fromJson(Map<String, dynamic> json) {
    return ImageWidget(
      id: json['id'],
      data: json['data'],
    );
  }
}

class CountdownWidget extends EditorWidget {
  CountdownWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.CountdownTimer);

  DateTime get targetDate => DateTime.parse(data['targetDate']);
  String get format => data['format'];

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory CountdownWidget.fromJson(Map<String, dynamic> json) {
    return CountdownWidget(
      id: json['id'],
      data: json['data'],
    );
  }
}

class GalleryWidget extends EditorWidget {
  GalleryWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Gallery);

  List<String> get imageUrls => List<String>.from(data['imageUrls']);
  String get layoutType => data['layoutType'];

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory GalleryWidget.fromJson(Map<String, dynamic> json) {
    return GalleryWidget(
      id: json['id'],
      data: json['data'],
    );
  }
}

class ScheduleWidget extends EditorWidget {
  ScheduleWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Schedule);

  List<Map<String, dynamic>> get events =>
      List<Map<String, dynamic>>.from(data['events']);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory ScheduleWidget.fromJson(Map<String, dynamic> json) {
    return ScheduleWidget(
      id: json['id'],
      data: json['data'],
    );
  }
}
