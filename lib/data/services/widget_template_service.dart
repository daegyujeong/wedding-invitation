import 'package:uuid/uuid.dart';
import '../models/custom_widget_model.dart';

class WidgetTemplateService {
  static const _uuid = Uuid();

  static List<CustomWidgetModel> getTemplate(String templateType) {
    switch (templateType) {
      case 'main':
        return _getMainTemplate();
      case 'gallery':
        return _getGalleryTemplate();
      case 'location':
        return _getLocationTemplate();
      case 'message':
        return _getMessageTemplate();
      case 'simple':
        return _getSimpleTemplate();
      default:
        return [];
    }
  }

  static List<CustomWidgetModel> _getMainTemplate() {
    return [
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.text,
        positionX: 20,
        positionY: 100,
        width: 360,
        height: 80,
        properties: {
          'text': '저희 두 사람이 사랑과 믿음으로\n새로운 가정을 이루게 되었습니다.',
          'fontSize': 18.0,
          'fontWeight': 'normal',
          'color': '#333333',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.text,
        positionX: 20,
        positionY: 200,
        width: 360,
        height: 60,
        properties: {
          'text': '신랑 김철수 & 신부 이영희',
          'fontSize': 24.0,
          'fontWeight': 'bold',
          'color': '#333333',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.text,
        positionX: 20,
        positionY: 280,
        width: 360,
        height: 80,
        properties: {
          'text': '2025년 5월 31일 토요일 오후 1시\n그랜드 호텔 3층 그랜드볼룸',
          'fontSize': 16.0,
          'fontWeight': 'normal',
          'color': '#666666',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
    ];
  }

  static List<CustomWidgetModel> _getGalleryTemplate() {
    return [
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.text,
        positionX: 20,
        positionY: 20,
        width: 360,
        height: 40,
        properties: {
          'text': '우리의 소중한 순간들',
          'fontSize': 24.0,
          'fontWeight': 'bold',
          'color': '#333333',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
      // Grid of 4 images
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.image,
        positionX: 20,
        positionY: 80,
        width: 170,
        height: 170,
        properties: {
          'imageUrl': 'assets/images/placeholder.png',
          'fit': 'cover',
          'borderRadius': 8.0,
        },
      ),
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.image,
        positionX: 210,
        positionY: 80,
        width: 170,
        height: 170,
        properties: {
          'imageUrl': 'assets/images/placeholder.png',
          'fit': 'cover',
          'borderRadius': 8.0,
        },
      ),
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.image,
        positionX: 20,
        positionY: 270,
        width: 170,
        height: 170,
        properties: {
          'imageUrl': 'assets/images/placeholder.png',
          'fit': 'cover',
          'borderRadius': 8.0,
        },
      ),
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.image,
        positionX: 210,
        positionY: 270,
        width: 170,
        height: 170,
        properties: {
          'imageUrl': 'assets/images/placeholder.png',
          'fit': 'cover',
          'borderRadius': 8.0,
        },
      ),
    ];
  }

  static List<CustomWidgetModel> _getLocationTemplate() {
    return [
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.text,
        positionX: 20,
        positionY: 20,
        width: 360,
        height: 40,
        properties: {
          'text': '오시는 길',
          'fontSize': 24.0,
          'fontWeight': 'bold',
          'color': '#333333',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.map,
        positionX: 20,
        positionY: 80,
        width: 360,
        height: 250,
        properties: {
          'latitude': 37.5665,
          'longitude': 126.9780,
          'address': '서울시 중구 을지로 30',
          'zoom': 15.0,
        },
      ),
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.text,
        positionX: 20,
        positionY: 350,
        width: 360,
        height: 80,
        properties: {
          'text': '📍 그랜드 호텔 3층 그랜드볼룸\n서울시 중구 을지로 30',
          'fontSize': 16.0,
          'fontWeight': 'normal',
          'color': '#666666',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.button,
        positionX: 20,
        positionY: 450,
        width: 360,
        height: 50,
        properties: {
          'text': '네비게이션 앱으로 열기',
          'fontSize': 16.0,
          'color': '#FFFFFF',
          'backgroundColor': '#FF6B6B',
          'borderRadius': 25.0,
          'action': 'openNavigation',
        },
      ),
    ];
  }

  static List<CustomWidgetModel> _getMessageTemplate() {
    return [
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.text,
        positionX: 20,
        positionY: 20,
        width: 360,
        height: 40,
        properties: {
          'text': '축하 메시지를 남겨주세요',
          'fontSize': 24.0,
          'fontWeight': 'bold',
          'color': '#333333',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.text,
        positionX: 20,
        positionY: 80,
        width: 360,
        height: 60,
        properties: {
          'text': '여러분의 따뜻한 축하 메시지는\n저희에게 큰 힘이 됩니다.',
          'fontSize': 14.0,
          'fontWeight': 'normal',
          'color': '#666666',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.button,
        positionX: 20,
        positionY: 160,
        width: 360,
        height: 50,
        properties: {
          'text': '메시지 작성하기',
          'fontSize': 16.0,
          'color': '#FFFFFF',
          'backgroundColor': '#4ECDC4',
          'borderRadius': 25.0,
          'action': 'writeMessage',
        },
      ),
    ];
  }

  static List<CustomWidgetModel> _getSimpleTemplate() {
    return [
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.text,
        positionX: 20,
        positionY: 50,
        width: 360,
        height: 60,
        properties: {
          'text': '제목을 입력하세요',
          'fontSize': 24.0,
          'fontWeight': 'bold',
          'color': '#333333',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
      CustomWidgetModel(
        id: _uuid.v4(),
        type: WidgetType.text,
        positionX: 20,
        positionY: 130,
        width: 360,
        height: 200,
        properties: {
          'text': '내용을 입력하세요',
          'fontSize': 16.0,
          'fontWeight': 'normal',
          'color': '#666666',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
    ];
  }
}
