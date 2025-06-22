import '../../data/models/custom_widget_model.dart';

class WidgetTemplateService {
  // Quick template definitions
  static List<CustomWidgetModel> getHeroTemplate() {
    return [
      CustomWidgetModel(
        id: 'hero_bg_${DateTime.now().millisecondsSinceEpoch}',
        type: WidgetType.image,
        positionX: 0,
        positionY: 0,
        width: 400,
        height: 300,
        properties: {
          'imageUrl':
              'https://via.placeholder.com/400x300/f8f9fa/6c757d?text=배경+이미지',
          'fit': 'cover',
          'borderRadius': 0.0,
        },
      ),
      CustomWidgetModel(
        id: 'hero_title_${DateTime.now().millisecondsSinceEpoch + 1}',
        type: WidgetType.text,
        positionX: 50,
        positionY: 100,
        width: 300,
        height: 60,
        properties: {
          'text': '결혼합니다',
          'fontSize': 32.0,
          'fontWeight': 'bold',
          'color': '#FFFFFF',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
      CustomWidgetModel(
        id: 'hero_subtitle_${DateTime.now().millisecondsSinceEpoch + 2}',
        type: WidgetType.text,
        positionX: 50,
        positionY: 170,
        width: 300,
        height: 40,
        properties: {
          'text': '신랑 ♥ 신부',
          'fontSize': 20.0,
          'fontWeight': 'normal',
          'color': '#FFFFFF',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
      CustomWidgetModel(
        id: 'hero_date_${DateTime.now().millisecondsSinceEpoch + 3}',
        type: WidgetType.text,
        positionX: 50,
        positionY: 220,
        width: 300,
        height: 30,
        properties: {
          'text': '2024년 12월 25일',
          'fontSize': 16.0,
          'fontWeight': 'normal',
          'color': '#FFFFFF',
          'textAlign': 'center',
          'backgroundColor': 'transparent',
        },
      ),
    ];
  }

  static List<CustomWidgetModel> getGalleryTemplate() {
    return [
      CustomWidgetModel(
        id: 'gallery_title_${DateTime.now().millisecondsSinceEpoch}',
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
      CustomWidgetModel(
        id: 'gallery_img1_${DateTime.now().millisecondsSinceEpoch + 1}',
        type: WidgetType.image,
        positionX: 20,
        positionY: 80,
        width: 160,
        height: 120,
        properties: {
          'imageUrl':
              'https://via.placeholder.com/160x120/e9ecef/6c757d?text=사진1',
          'fit': 'cover',
          'borderRadius': 8.0,
        },
      ),
      CustomWidgetModel(
        id: 'gallery_img2_${DateTime.now().millisecondsSinceEpoch + 2}',
        type: WidgetType.image,
        positionX: 200,
        positionY: 80,
        width: 160,
        height: 120,
        properties: {
          'imageUrl':
              'https://via.placeholder.com/160x120/e9ecef/6c757d?text=사진2',
          'fit': 'cover',
          'borderRadius': 8.0,
        },
      ),
      CustomWidgetModel(
        id: 'gallery_img3_${DateTime.now().millisecondsSinceEpoch + 3}',
        type: WidgetType.image,
        positionX: 20,
        positionY: 220,
        width: 160,
        height: 120,
        properties: {
          'imageUrl':
              'https://via.placeholder.com/160x120/e9ecef/6c757d?text=사진3',
          'fit': 'cover',
          'borderRadius': 8.0,
        },
      ),
      CustomWidgetModel(
        id: 'gallery_img4_${DateTime.now().millisecondsSinceEpoch + 4}',
        type: WidgetType.image,
        positionX: 200,
        positionY: 220,
        width: 160,
        height: 120,
        properties: {
          'imageUrl':
              'https://via.placeholder.com/160x120/e9ecef/6c757d?text=사진4',
          'fit': 'cover',
          'borderRadius': 8.0,
        },
      ),
    ];
  }

  // Widget categories for organized selection
  static Map<String, List<Map<String, dynamic>>> getWidgetCategories() {
    return {
      '텍스트': [
        {
          'type': 'text',
          'name': '텍스트',
          'icon': 'text_fields',
          'description': '제목, 본문, 설명 등',
        },
        {
          'type': 'title',
          'name': '제목',
          'icon': 'title',
          'description': '큰 제목 텍스트',
        },
      ],
      '이미지': [
        {
          'type': 'image',
          'name': '이미지',
          'icon': 'image',
          'description': '사진 및 이미지',
        },
        {
          'type': 'gallery',
          'name': '갤러리',
          'icon': 'photo_library',
          'description': '여러 이미지 슬라이더',
        },
      ],
      '인터랙티브': [
        {
          'type': 'button',
          'name': '버튼',
          'icon': 'smart_button',
          'description': '클릭 가능한 버튼',
        },
        {
          'type': 'map',
          'name': '지도',
          'icon': 'map',
          'description': '위치 지도',
        },
        {
          'type': 'countdown',
          'name': '카운트다운',
          'icon': 'timer',
          'description': '결혼식까지 남은 시간',
        },
      ],
      '장식': [
        {
          'type': 'divider',
          'name': '구분선',
          'icon': 'horizontal_rule',
          'description': '섹션 구분선',
        },
        {
          'type': 'spacer',
          'name': '여백',
          'icon': 'space_bar',
          'description': '빈 공간',
        },
      ],
    };
  }

  // Get template by type
  static List<CustomWidgetModel> getTemplate(String templateType) {
    switch (templateType) {
      case 'hero':
        return getHeroTemplate();
      case 'gallery':
        return getGalleryTemplate();
      default:
        return [];
    }
  }

  // Create a default widget of specified type
  static CustomWidgetModel createDefaultWidget(String type,
      {double? positionX, double? positionY}) {
    final x = positionX ?? 50.0;
    final y = positionY ?? 50.0;
    final id = '${type}_${DateTime.now().millisecondsSinceEpoch}';

    switch (type) {
      case 'text':
        return CustomWidgetModel(
          id: id,
          type: WidgetType.text,
          positionX: x,
          positionY: y,
          width: 200,
          height: 40,
          properties: {
            'text': '텍스트를 입력하세요',
            'fontSize': 16.0,
            'fontWeight': 'normal',
            'color': '#333333',
            'textAlign': 'left',
            'backgroundColor': 'transparent',
          },
        );

      case 'title':
        return CustomWidgetModel(
          id: id,
          type: WidgetType.text,
          positionX: x,
          positionY: y,
          width: 300,
          height: 50,
          properties: {
            'text': '제목을 입력하세요',
            'fontSize': 24.0,
            'fontWeight': 'bold',
            'color': '#333333',
            'textAlign': 'center',
            'backgroundColor': 'transparent',
          },
        );

      case 'image':
        return CustomWidgetModel(
          id: id,
          type: WidgetType.image,
          positionX: x,
          positionY: y,
          width: 200,
          height: 150,
          properties: {
            'imageUrl':
                'https://via.placeholder.com/200x150/e9ecef/6c757d?text=이미지',
            'fit': 'cover',
            'borderRadius': 8.0,
          },
        );

      default:
        return createDefaultWidget('text',
            positionX: positionX, positionY: positionY);
    }
  }
}
