import 'package:wedding_invitation/data/models/invitation_model.dart';

enum WidgetType {
  Text,
  Image,
  Video,
  Button,
  Map,
  GoogleMap,
  NaverMap,
  KakaoMap,
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
      case WidgetType.Video:
        return VideoWidget.fromJson(json);
      case WidgetType.Button:
        return ButtonWidget.fromJson(json);
      case WidgetType.Map:
        return MapWidget.fromJson(json);
      case WidgetType.GoogleMap:
        return GoogleMapWidget.fromJson(json);
      case WidgetType.NaverMap:
        return NaverMapWidget.fromJson(json);
      case WidgetType.KakaoMap:
        return KakaoMapWidget.fromJson(json);
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

  // Factory methods for creating default widgets
  static EditorWidget createDefault(WidgetType type) {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();

    switch (type) {
      case WidgetType.Text:
        return TextWidget(
          id: id,
          data: {
            'text': {'ko': '텍스트를 입력하세요', 'en': 'Enter text'},
            'fontFamily': 'Roboto',
            'fontSize': 16.0,
            'color': '#000000',
          },
        );
      case WidgetType.DDay:
        return DDayWidget(
          id: id,
          data: {
            'eventId': 'wedding',
            'format': '결혼식까지 {days}일',
            'style': '기본',
            'title': 'D-Day',
            'targetDate':
                DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          },
        );
      case WidgetType.CountdownTimer:
        return CountdownWidget(
          id: id,
          data: {
            'targetDate':
                DateTime.now().add(const Duration(days: 30)).toIso8601String(),
            'format': 'countdown',
          },
        );
      case WidgetType.Image:
        return ImageWidget(
          id: id,
          data: {
            'imageUrl': 'assets/images/placeholder.png',
            'width': 200.0,
            'height': 200.0,
          },
        );
      case WidgetType.Video:
        return VideoWidget(
          id: id,
          data: {
            'videoUrl': '',
            'autoPlay': false,
            'showControls': true,
            'aspectRatio': 16 / 9,
          },
        );
      case WidgetType.Button:
        return ButtonWidget(
          id: id,
          data: {
            'text': {'ko': '버튼', 'en': 'Button'},
            'fontFamily': 'Roboto',
            'fontSize': 16.0,
            'color': '#FFFFFF',
            'backgroundColor': '#4285F4',
            'borderRadius': 8.0,
            'padding': 16.0,
            'action': 'url',
            'actionTarget': 'https://example.com',
          },
        );
      case WidgetType.Gallery:
        return GalleryWidget(
          id: id,
          data: {
            'imageUrls': ['assets/images/placeholder.png'],
            'layoutType': 'horizontal',
          },
        );
      case WidgetType.Map:
        return MapWidget(
          id: id,
          data: {
            'venueId': 'main_venue',
            'mapType': 'standard',
            'showDirections': true,
            'latitude': 37.5665,  // Default: Seoul City Hall
            'longitude': 126.9780,
            'venue': '결혼식장',
            'mapProvider': 'google',  // 'google', 'naver', 'kakao'
            'showControls': true,
            'height': 400.0,
          },
        );
      case WidgetType.GoogleMap:
        return GoogleMapWidget(
          id: id,
          data: {
            'venueId': 'main_venue',
            'showDirections': true,
            'latitude': 37.5665,
            'longitude': 126.9780,
            'venue': '결혼식장',
            'showControls': true,
            'height': 400.0,
          },
        );
      case WidgetType.NaverMap:
        return NaverMapWidget(
          id: id,
          data: {
            'venueId': 'main_venue',
            'showDirections': true,
            'latitude': 37.5665,
            'longitude': 126.9780,
            'venue': '결혼식장',
            'showControls': true,
            'height': 400.0,
          },
        );
      case WidgetType.KakaoMap:
        return KakaoMapWidget(
          id: id,
          data: {
            'venueId': 'main_venue',
            'showDirections': true,
            'latitude': 37.5665,
            'longitude': 126.9780,
            'venue': '결혼식장',
            'showControls': true,
            'height': 400.0,
          },
        );
      case WidgetType.Schedule:
        return ScheduleWidget(
          id: id,
          data: {
            'events': [
              {'time': '14:00', 'description': '결혼식'},
              {'time': '15:30', 'description': '피로연'},
            ],
          },
        );
    }
  }
}

class TextWidget extends EditorWidget {
  TextWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Text);

  MultiLanguageText get text {
    try {
      return MultiLanguageText.fromJson(data['text']);
    } catch (e) {
      // Fallback if MultiLanguageText is not available
      return MultiLanguageText(
        translations: {
          'ko': data['text']?.toString() ?? '텍스트를 입력하세요',
          'en': data['text']?.toString() ?? 'Enter text',
        },
        defaultLanguage: 'ko',
      );
    }
  }

  String get fontFamily => data['fontFamily']?.toString() ?? 'Roboto';
  double get fontSize => (data['fontSize'] as num?)?.toDouble() ?? 16.0;
  String get color => data['color']?.toString() ?? '#000000';

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
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class DDayWidget extends EditorWidget {
  DDayWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.DDay);

  String get eventId => data['eventId']?.toString() ?? 'wedding';
  String get format => data['format']?.toString() ?? '결혼식까지 {days}일';
  String get style => data['style']?.toString() ?? '기본';
  String get title => data['title']?.toString() ?? 'D-Day';

  DateTime get targetDate {
    try {
      return DateTime.parse(data['targetDate']?.toString() ?? '');
    } catch (e) {
      return DateTime.now().add(const Duration(days: 30));
    }
  }

  void setTargetDate(DateTime date) {
    data['targetDate'] = date.toIso8601String();
  }

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
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class MapWidget extends EditorWidget {
  MapWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Map);

  String get venueId => data['venueId']?.toString() ?? 'main_venue';
  String get mapType => data['mapType']?.toString() ?? 'standard';
  bool get showDirections => data['showDirections'] == true;
  double get latitude => (data['latitude'] as num?)?.toDouble() ?? 37.5665;
  double get longitude => (data['longitude'] as num?)?.toDouble() ?? 126.9780;
  String get venue => data['venue']?.toString() ?? '결혼식장';
  String get mapProvider => data['mapProvider']?.toString() ?? 'google';
  bool get showControls => data['showControls'] ?? true;
  double get height => (data['height'] as num?)?.toDouble() ?? 400.0;

  void setMapProvider(String provider) {
    data['mapProvider'] = provider;
  }

  void setLocation(double lat, double lng, String venueName) {
    data['latitude'] = lat;
    data['longitude'] = lng;
    data['venue'] = venueName;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory MapWidget.fromJson(Map<String, dynamic> json) {
    try {
      final dynamic rawData = json['data'];
      Map<String, dynamic> safeData = {};
      
      if (rawData != null) {
        if (rawData is Map<String, dynamic>) {
          safeData = Map<String, dynamic>.from(rawData);
        } else if (rawData is Map) {
          // Handle Map<dynamic, dynamic> case
          safeData = Map<String, dynamic>.from(rawData.map(
            (key, value) => MapEntry(key.toString(), value),
          ));
        } else {
          print('MapWidget.fromJson: Unexpected data type: ${rawData.runtimeType}');
          print('Raw data: $rawData');
        }
      }
      
      return MapWidget(
        id: json['id']?.toString() ?? '',
        data: safeData,
      );
    } catch (e) {
      print('Error parsing MapWidget: $e');
      print('JSON: $json');
      // Return a default map widget
      return MapWidget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        data: {
          'latitude': 37.5665,
          'longitude': 126.9780,
          'venue': 'Default Location',
          'provider': 'google',
        },
      );
    }
  }
}

// Individual Map Widgets for specific providers
class GoogleMapWidget extends EditorWidget {
  GoogleMapWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.GoogleMap);

  String get venueId => data['venueId']?.toString() ?? 'main_venue';
  bool get showDirections => data['showDirections'] == true;
  double get latitude => (data['latitude'] as num?)?.toDouble() ?? 37.5665;
  double get longitude => (data['longitude'] as num?)?.toDouble() ?? 126.9780;
  String get venue => data['venue']?.toString() ?? '결혼식장';
  bool get showControls => data['showControls'] ?? true;
  double get height => (data['height'] as num?)?.toDouble() ?? 400.0;

  void setLocation(double lat, double lng, String venueName) {
    data['latitude'] = lat;
    data['longitude'] = lng;
    data['venue'] = venueName;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory GoogleMapWidget.fromJson(Map<String, dynamic> json) {
    return GoogleMapWidget(
      id: json['id']?.toString() ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class NaverMapWidget extends EditorWidget {
  NaverMapWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.NaverMap);

  String get venueId => data['venueId']?.toString() ?? 'main_venue';
  bool get showDirections => data['showDirections'] == true;
  double get latitude => (data['latitude'] as num?)?.toDouble() ?? 37.5665;
  double get longitude => (data['longitude'] as num?)?.toDouble() ?? 126.9780;
  String get venue => data['venue']?.toString() ?? '결혼식장';
  bool get showControls => data['showControls'] ?? true;
  double get height => (data['height'] as num?)?.toDouble() ?? 400.0;

  void setLocation(double lat, double lng, String venueName) {
    data['latitude'] = lat;
    data['longitude'] = lng;
    data['venue'] = venueName;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory NaverMapWidget.fromJson(Map<String, dynamic> json) {
    return NaverMapWidget(
      id: json['id']?.toString() ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class KakaoMapWidget extends EditorWidget {
  KakaoMapWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.KakaoMap);

  String get venueId => data['venueId']?.toString() ?? 'main_venue';
  bool get showDirections => data['showDirections'] == true;
  double get latitude => (data['latitude'] as num?)?.toDouble() ?? 37.5665;
  double get longitude => (data['longitude'] as num?)?.toDouble() ?? 126.9780;
  String get venue => data['venue']?.toString() ?? '결혼식장';
  bool get showControls => data['showControls'] ?? true;
  double get height => (data['height'] as num?)?.toDouble() ?? 400.0;

  void setLocation(double lat, double lng, String venueName) {
    data['latitude'] = lat;
    data['longitude'] = lng;
    data['venue'] = venueName;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory KakaoMapWidget.fromJson(Map<String, dynamic> json) {
    return KakaoMapWidget(
      id: json['id']?.toString() ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class ImageWidget extends EditorWidget {
  ImageWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Image);

  String get imageUrl =>
      data['imageUrl']?.toString() ?? 'assets/images/placeholder.png';
  double get width => (data['width'] as num?)?.toDouble() ?? 200.0;
  double get height => (data['height'] as num?)?.toDouble() ?? 200.0;

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
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class CountdownWidget extends EditorWidget {
  CountdownWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.CountdownTimer);

  DateTime get targetDate {
    try {
      return DateTime.parse(data['targetDate']?.toString() ?? '');
    } catch (e) {
      return DateTime.now().add(const Duration(days: 30));
    }
  }

  String get format => data['format']?.toString() ?? 'countdown';

  void setTargetDate(DateTime date) {
    data['targetDate'] = date.toIso8601String();
  }

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
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class GalleryWidget extends EditorWidget {
  GalleryWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Gallery);

  List<String> get imageUrls {
    try {
      return List<String>.from(data['imageUrls'] ?? []);
    } catch (e) {
      return ['assets/images/placeholder.png'];
    }
  }

  String get layoutType => data['layoutType']?.toString() ?? 'horizontal';

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
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class ScheduleWidget extends EditorWidget {
  ScheduleWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Schedule);

  List<Map<String, dynamic>> get events {
    try {
      return List<Map<String, dynamic>>.from(data['events'] ?? []);
    } catch (e) {
      return [
        {'time': '14:00', 'description': '결혼식'},
        {'time': '15:30', 'description': '피로연'},
      ];
    }
  }

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
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class VideoWidget extends EditorWidget {
  VideoWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Video);

  String get videoUrl => data['videoUrl']?.toString() ?? '';
  bool get autoPlay => data['autoPlay'] as bool? ?? false;
  bool get showControls => data['showControls'] as bool? ?? true;
  double get aspectRatio => (data['aspectRatio'] as num?)?.toDouble() ?? 16 / 9;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory VideoWidget.fromJson(Map<String, dynamic> json) {
    return VideoWidget(
      id: json['id'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class ButtonWidget extends EditorWidget {
  ButtonWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Button);

  MultiLanguageText get text {
    try {
      return MultiLanguageText.fromJson(data['text']);
    } catch (e) {
      return MultiLanguageText(
        translations: {
          'ko': data['text']?.toString() ?? '버튼',
          'en': data['text']?.toString() ?? 'Button',
        },
        defaultLanguage: 'ko',
      );
    }
  }

  String get fontFamily => data['fontFamily']?.toString() ?? 'Roboto';
  double get fontSize => (data['fontSize'] as num?)?.toDouble() ?? 16.0;
  String get color => data['color']?.toString() ?? '#FFFFFF';
  String get backgroundColor =>
      data['backgroundColor']?.toString() ?? '#4285F4';
  double get borderRadius => (data['borderRadius'] as num?)?.toDouble() ?? 8.0;
  double get padding => (data['padding'] as num?)?.toDouble() ?? 16.0;
  String get action => data['action']?.toString() ?? 'url';
  String get actionTarget => data['actionTarget']?.toString() ?? '';

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory ButtonWidget.fromJson(Map<String, dynamic> json) {
    return ButtonWidget(
      id: json['id'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}
