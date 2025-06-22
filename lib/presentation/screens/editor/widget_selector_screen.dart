import 'package:flutter/material.dart';
import '../../viewmodels/editor_viewmodel.dart';
import '../../../data/services/widget_template_service.dart';
import '../../../data/models/editor_widget_model.dart';

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
  final categories = WidgetTemplateService.getWidgetCategories();

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
            ...categories.keys.map((category) => Tab(
                  icon: Icon(_getCategoryIcon(category)),
                  text: category,
                )),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTemplateTab(),
          ...categories.entries
              .map((entry) => _buildWidgetCategoryTab(entry.key, entry.value)),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getWidgetIcon(widgetInfo['icon']),
                size: 32,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 8),
              Text(
                widgetInfo['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widgetInfo['description'],
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '텍스트':
        return Icons.text_fields;
      case '이미지':
        return Icons.image;
      case '인터랙티브':
        return Icons.touch_app;
      case '장식':
        return Icons.palette;
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
      default:
        return Icons.widgets;
    }
  }

  void _addTemplate(String templateType) {
    _showConfirmationDialog(
      title: '템플릿 추가',
      content: '선택한 템플릿의 모든 위젯이 페이지에 추가됩니다. 계속하시겠습니까?',
      onConfirm: () {
        final widgets = WidgetTemplateService.getTemplate(templateType);
        for (final widgetModel in widgets) {
          // FIXED: Use WidgetSelectorScreen's pageId and viewModel
          widget.viewModel.addWidget(widget.pageId, widgetModel);
        }
        Navigator.pop(context);
        _showSuccessSnackBar('템플릿이 추가되었습니다.');
      },
    );
  }

  void _addWidget(String widgetType) {
    // Create EditorWidget instead of CustomWidgetModel for compatibility
    EditorWidget editorWidget;

    switch (widgetType) {
      case 'text':
        editorWidget = TextWidget(
          id: 'text_${DateTime.now().millisecondsSinceEpoch}',
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
          id: 'title_${DateTime.now().millisecondsSinceEpoch}',
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
      case 'countdown':
        editorWidget = DDayWidget(
          id: 'countdown_${DateTime.now().millisecondsSinceEpoch}',
          data: {
            'eventId': '',
            'format': 'D-{days}',
            'style': 'default',
            'position': {
              'dx': 100.0,
              'dy': 150.0,
            },
          },
        );
        break;
      default:
        // Default to text widget
        editorWidget = TextWidget(
          id: 'widget_${DateTime.now().millisecondsSinceEpoch}',
          data: {
            'text': {
              'translations': {'ko': '새로운 위젯'},
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

    // Pass the widget back through Navigator result
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
