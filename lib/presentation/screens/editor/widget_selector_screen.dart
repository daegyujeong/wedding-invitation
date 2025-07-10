import 'package:flutter/material.dart';
import '../../viewmodels/editor_viewmodel.dart';
import '../../../data/models/editor_widget_model.dart';
import 'package:uuid/uuid.dart';

class WidgetSelectorScreen extends StatefulWidget {
  final String pageId;
  final EditorViewModel viewModel;

  const WidgetSelectorScreen({
    super.key,
    required this.pageId,
    required this.viewModel,
  });

  @override
  State<WidgetSelectorScreen> createState() => _WidgetSelectorScreenState();
}

class _WidgetSelectorScreenState extends State<WidgetSelectorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _uuid = const Uuid();

  // Define widget categories directly
  final categories = [
    {
      'name': '텍스트',
      'widgets': [
        {'type': 'text', 'name': '텍스트', 'icon': Icons.text_fields},
      ],
    },
    {
      'name': '미디어',
      'widgets': [
        {'type': 'image', 'name': '이미지', 'icon': Icons.image},
        {'type': 'video', 'name': '비디오', 'icon': Icons.video_library},
        {'type': 'gallery', 'name': '갤러리', 'icon': Icons.photo_library},
      ],
    },
    {
      'name': '인터랙션',
      'widgets': [
        {'type': 'button', 'name': '버튼', 'icon': Icons.smart_button},
      ],
    },
    {
      'name': '지도',
      'widgets': [
        {'type': 'map', 'name': '멀티 지도', 'icon': Icons.map, 'description': '구글/네이버/카카오 탭'},
        {'type': 'google_map', 'name': '구글 지도', 'icon': Icons.map, 'description': '구글 지도만'},
        {'type': 'naver_map', 'name': '네이버 지도', 'icon': Icons.map, 'description': '네이버 지도만'},
        {'type': 'kakao_map', 'name': '카카오 지도', 'icon': Icons.map, 'description': '카카오 지도만'},
      ],
    },
    {
      'name': '시간',
      'widgets': [
        {'type': 'dday', 'name': 'D-Day', 'icon': Icons.event},
        {'type': 'countdown', 'name': '카운트다운', 'icon': Icons.timer},
        {'type': 'schedule', 'name': '일정', 'icon': Icons.schedule},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위젯 추가'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(
              icon: Icon(Icons.auto_awesome),
              text: '템플릿',
            ),
            ...categories.map((category) => Tab(
                  icon: Icon(_getCategoryIcon(category['name'] as String)),
                  text: category['name'] as String,
                )),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTemplateTab(),
          ...categories.map((category) => _buildWidgetCategoryTab(
              category['name'] as String,
              category['widgets'] as List<Map<String, dynamic>>)),
        ],
      ),
    );
  }

  Widget _buildTemplateTab() {
    final templates = [
      {
        'type': 'hero',
        'name': '히어로 섹션',
        'description': '제목 + 배경 이미지 + 날짜',
        'icon': Icons.photo_size_select_actual,
        'color': Colors.purple,
      },
      {
        'type': 'gallery',
        'name': '갤러리',
        'description': '이미지 그리드 레이아웃',
        'icon': Icons.photo_library,
        'color': Colors.green,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '빠른 템플릿',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '미리 만들어진 위젯 조합을 한 번에 추가할 수 있습니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return _buildTemplateCard(template);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _addTemplate(template['type']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (template['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  template['icon'],
                  size: 24,
                  color: template['color'],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                template['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                template['description'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetCategoryTab(
      String category, List<Map<String, dynamic>> widgets) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: widgets.length,
              itemBuilder: (context, index) {
                final widget = widgets[index];
                return _buildWidgetCard(widget);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetCard(Map<String, dynamic> widgetInfo) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _addWidget(widgetInfo['type']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widgetInfo['icon'] as IconData,
                size: 28,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  widgetInfo['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  widgetInfo['description'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '텍스트':
        return Icons.text_fields;
      case '이미지':
        return Icons.image;
      case '인터랙티브':
      case '인터랙션':
        return Icons.touch_app;
      case '장식':
        return Icons.palette;
      case '미디어':
        return Icons.perm_media;
      case '지도':
        return Icons.map;
      case '시간':
        return Icons.schedule;
      case '기본':
        return Icons.widgets;
      case '정보':
        return Icons.info;
      default:
        return Icons.widgets;
    }
  }

  IconData _getWidgetIcon(String iconName) {
    switch (iconName) {
      case 'text_fields':
        return Icons.text_fields;
      case 'title':
        return Icons.title;
      case 'image':
        return Icons.image;
      case 'photo_library':
        return Icons.photo_library;
      case 'smart_button':
        return Icons.smart_button;
      case 'map':
        return Icons.map;
      case 'timer':
        return Icons.timer;
      case 'horizontal_rule':
        return Icons.horizontal_rule;
      case 'space_bar':
        return Icons.space_bar;
      case 'video_library':
        return Icons.video_library;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.widgets;
    }
  }

  void _addTemplate(String templateType) {
    if (templateType == 'hero') {
      _showConfirmationDialog(
        title: '히어로 섹션 추가',
        content: '배경 이미지와 텍스트가 포함된 히어로 섹션을 추가합니다. 계속하시겠습니까?',
        onConfirm: () {
          // Create hero section with a simple background image
          final widget = ImageWidget(
            id: 'hero_bg_${_uuid.v4()}',
            data: {
              'imageUrl': 'assets/images/background.png',
              'width': 400.0,
              'height': 300.0,
              'position': {
                'dx': 0.0,
                'dy': 0.0,
              },
            },
          );
          Navigator.pop(context, widget);
          _showSuccessSnackBar('히어로 섹션 배경이 추가되었습니다. 텍스트는 별도로 추가해주세요.');
        },
      );
    } else {
      _showConfirmationDialog(
        title: '템플릿 추가',
        content: '선택한 템플릿의 모든 위젯이 페이지에 추가됩니다. 계속하시겠습니까?',
        onConfirm: () {
          // Create template widgets based on type
          EditorWidget primaryWidget;

          switch (templateType) {
            case 'gallery':
              primaryWidget = _createWidget('gallery');
              break;
            default:
              primaryWidget = _createWidget('text');
          }

          Navigator.pop(context, primaryWidget);
          _showSuccessSnackBar('템플릿이 추가되었습니다.');
        },
      );
    }
  }

  EditorWidget _createWidget(String widgetType) {
    // Create EditorWidget based on widget type
    EditorWidget editorWidget;

    switch (widgetType) {
      case 'text':
        editorWidget = TextWidget(
          id: 'text_${_uuid.v4()}',
          data: {
            'text': {
              'translations': {'ko': '텍스트를 입력하세요'},
              'default_language': 'ko',
            },
            'fontFamily': 'Roboto',
            'fontSize': 16.0,
            'color': '#333333',
            'position': {
              'dx': 100.0,
              'dy': 100.0,
            },
          },
        );
        break;

      case 'title':
        editorWidget = TextWidget(
          id: 'title_${_uuid.v4()}',
          data: {
            'text': {
              'translations': {'ko': '제목을 입력하세요'},
              'default_language': 'ko',
            },
            'fontFamily': 'Roboto',
            'fontSize': 24.0,
            'color': '#333333',
            'position': {
              'dx': 100.0,
              'dy': 50.0,
            },
          },
        );
        break;

      case 'button':
        editorWidget = ButtonWidget(
          id: 'button_${_uuid.v4()}',
          data: {
            'text': {
              'translations': {'ko': '버튼 텍스트'},
              'default_language': 'ko',
            },
            'fontFamily': 'Roboto',
            'fontSize': 16.0,
            'color': '#FFFFFF',
            'backgroundColor': '#4285F4',
            'borderRadius': 8.0,
            'padding': 16.0,
            'action': 'url',
            'actionTarget': 'https://example.com',
            'position': {
              'dx': 100.0,
              'dy': 100.0,
            },
          },
        );
        break;

      case 'countdown':
      case 'timer':
        editorWidget = CountdownWidget(
          id: 'countdown_${_uuid.v4()}',
          data: {
            'targetDate':
                DateTime.now().add(const Duration(days: 30)).toIso8601String(),
            'format': '결혼식까지 {days}일 {hours}시간',
            'position': {
              'dx': 100.0,
              'dy': 150.0,
            },
          },
        );
        break;

      case 'd-day':
        editorWidget = DDayWidget(
          id: 'dday_${_uuid.v4()}',
          data: {
            'eventId': 'wedding',
            'format': 'D-{days}',
            'style': 'default',
            'title': 'D-Day',
            'targetDate':
                DateTime.now().add(const Duration(days: 30)).toIso8601String(),
            'position': {
              'dx': 100.0,
              'dy': 150.0,
            },
          },
        );
        break;

      case 'map':
        editorWidget = MapWidget(
          id: 'map_${_uuid.v4()}',
          data: {
            'venueId': 'main_venue',
            'mapProvider': 'google',
            'showDirections': true,
            'showControls': true,
            'latitude':
                37.5642, // The Plaza Hotel Seoul (popular wedding venue)
            'longitude': 126.9758,
            'venue': '그랜드 호텔',
            'height': 300.0,
            'position': {
              'dx': 50.0,
              'dy': 200.0,
            },
          },
        );
        break;

      case 'google_map':
        editorWidget = GoogleMapWidget(
          id: 'google_map_${_uuid.v4()}',
          data: {
            'venueId': 'main_venue',
            'showDirections': true,
            'showControls': true,
            'latitude': 37.5642,
            'longitude': 126.9758,
            'venue': '그랜드 호텔',
            'height': 300.0,
            'position': {
              'dx': 50.0,
              'dy': 200.0,
            },
          },
        );
        break;

      case 'naver_map':
        editorWidget = NaverMapWidget(
          id: 'naver_map_${_uuid.v4()}',
          data: {
            'venueId': 'main_venue',
            'showDirections': true,
            'showControls': true,
            'latitude': 37.5642,
            'longitude': 126.9758,
            'venue': '그랜드 호텔',
            'height': 300.0,
            'position': {
              'dx': 50.0,
              'dy': 200.0,
            },
          },
        );
        break;

      case 'kakao_map':
        editorWidget = KakaoMapWidget(
          id: 'kakao_map_${_uuid.v4()}',
          data: {
            'venueId': 'main_venue',
            'showDirections': true,
            'showControls': true,
            'latitude': 37.5642,
            'longitude': 126.9758,
            'venue': '그랜드 호텔',
            'height': 300.0,
            'position': {
              'dx': 50.0,
              'dy': 200.0,
            },
          },
        );
        break;

      case 'image':
        editorWidget = ImageWidget(
          id: 'image_${_uuid.v4()}',
          data: {
            'imageUrl': 'assets/images/gallery1.jpg',
            'width': 200.0,
            'height': 200.0,
            'position': {
              'dx': 100.0,
              'dy': 100.0,
            },
          },
        );
        break;

      case 'gallery':
        editorWidget = GalleryWidget(
          id: 'gallery_${_uuid.v4()}',
          data: {
            'imageUrls': [
              'assets/images/gallery1.jpg',
              'assets/images/gallery2.jpg',
              'assets/images/gallery3.jpg',
            ],
            'layoutType': 'carousel',
            'style': 'modern', // Add style property
            'showIndicators': true,
            'autoPlay': false,
            'position': {
              'dx': 50.0,
              'dy': 100.0,
            },
          },
        );
        break;

      case 'video':
        editorWidget = VideoWidget(
          id: 'video_${_uuid.v4()}',
          data: {
            'videoUrl': '',
            'autoPlay': false,
            'showControls': true,
            'aspectRatio': 16 / 9,
            'position': {
              'dx': 100.0,
              'dy': 100.0,
            },
          },
        );
        break;

      case 'schedule':
        editorWidget = ScheduleWidget(
          id: 'schedule_${_uuid.v4()}',
          data: {
            'events': [
              {'time': '11:00', 'description': '신부 대기실'},
              {'time': '12:00', 'description': '결혼식'},
              {'time': '13:00', 'description': '식사'},
            ],
            'position': {
              'dx': 100.0,
              'dy': 100.0,
            },
          },
        );
        break;

      default:
        // Default to text widget for unknown types
        editorWidget = TextWidget(
          id: 'widget_${_uuid.v4()}',
          data: {
            'text': {
              'translations': {'ko': '위젯'},
              'default_language': 'ko',
            },
            'fontFamily': 'Roboto',
            'fontSize': 16.0,
            'color': '#333333',
            'position': {
              'dx': 100.0,
              'dy': 100.0,
            },
          },
        );
    }

    return editorWidget;
  }

  void _addWidget(String widgetType) {
    // Create widget and return it
    final editorWidget = _createWidget(widgetType);
    Navigator.pop(context, editorWidget);
    _showSuccessSnackBar('위젯이 추가되었습니다.');
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }
}
