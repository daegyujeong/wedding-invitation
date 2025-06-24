import 'package:flutter/material.dart';
import '../../../../data/models/page_model.dart';
import '../../../viewmodels/editor_viewmodel.dart';
import '../widget_selector_screen.dart';
import 'custom_draggable_editor.dart';

class CustomTemplateEditor extends StatefulWidget {
  final PageModel page;
  final EditorViewModel viewModel;

  const CustomTemplateEditor({
    super.key,
    required this.page,
    required this.viewModel,
  });

  @override
  State<CustomTemplateEditor> createState() => _CustomTemplateEditorState();
}

class _CustomTemplateEditorState extends State<CustomTemplateEditor>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _titleController.text = widget.page.title;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('편집: ${widget.page.title}'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.widgets),
              text: '콘텐츠',
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: '페이지 설정',
            ),
          ],
        ),
        actions: [
          // Quick template buttons
          PopupMenuButton<String>(
            icon: const Icon(Icons.auto_awesome),
            tooltip: '빠른 템플릿',
            onSelected: _applyQuickTemplate,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'hero',
                child: ListTile(
                  leading: Icon(Icons.photo_size_select_actual),
                  title: Text('히어로 섹션'),
                  subtitle: Text('제목 + 배경 이미지 + 날짜'),
                ),
              ),
              const PopupMenuItem(
                value: 'gallery',
                child: ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('갤러리'),
                  subtitle: Text('이미지 그리드 레이아웃'),
                ),
              ),
            ],
          ),
          // Preview button
          IconButton(
            icon: const Icon(Icons.preview),
            tooltip: '미리보기',
            onPressed: _showPreview,
          ),
          // Save button
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: '저장',
            onPressed: _savePage,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContentTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              heroTag: "customTemplateEditorFAB",
              onPressed: _showWidgetSelector,
              icon: const Icon(Icons.add),
              label: const Text('위젯 추가'),
            )
          : null,
    );
  }

  Widget _buildContentTab() {
    return CustomDraggableEditor(
      page: widget.page,
      viewModel: widget.viewModel,
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page title
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '페이지 제목',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: '페이지 제목을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final updatedPage = widget.page.copyWith(title: value);
                      widget.viewModel.updatePage(updatedPage);
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.visibility,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.page.showTitle ? '페이지에 제목 표시' : '페이지에 제목 숨김',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Switch(
                        value: widget.page.showTitle,
                        onChanged: (value) {
                          final updatedPage =
                              widget.page.updateSetting('showTitle', value);
                          widget.viewModel.updatePage(updatedPage);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Background settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '배경 설정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Background color
                  Row(
                    children: [
                      const Text('배경 색상'),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showColorPicker('backgroundColor'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(int.parse(widget.page.backgroundColor
                                .replaceFirst('#', '0xFF'))),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Background image
                  Row(
                    children: [
                      const Text('배경 이미지'),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _selectBackgroundImage,
                        icon: const Icon(Icons.image),
                        label: const Text('선택'),
                      ),
                    ],
                  ),
                  if (widget.page.backgroundImage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.page.backgroundImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            final updatedPage = widget.page
                                .updateSetting('backgroundImage', '');
                            widget.viewModel.updatePage(updatedPage);
                            setState(() {});
                          },
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title appearance (if title is shown)
          if (widget.page.showTitle) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '제목 스타일',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title color
                    Row(
                      children: [
                        const Text('제목 색상'),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showColorPicker('titleColor'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(int.parse(widget.page.titleColor
                                  .replaceFirst('#', '0xFF'))),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title size
                    Row(
                      children: [
                        const Text('제목 크기'),
                        const Spacer(),
                        SizedBox(
                          width: 100,
                          child: Slider(
                            value: widget.page.titleSize,
                            min: 12,
                            max: 48,
                            divisions: 36,
                            label: '${widget.page.titleSize.toInt()}px',
                            onChanged: (value) {
                              final updatedPage =
                                  widget.page.updateSetting('titleSize', value);
                              widget.viewModel.updatePage(updatedPage);
                              setState(() {});
                            },
                          ),
                        ),
                        Text('${widget.page.titleSize.toInt()}px'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Page padding
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '레이아웃',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('페이지 여백'),
                      const Spacer(),
                      SizedBox(
                        width: 100,
                        child: Slider(
                          value: widget.page.padding,
                          min: 0,
                          max: 32,
                          divisions: 32,
                          label: '${widget.page.padding.toInt()}px',
                          onChanged: (value) {
                            final updatedPage =
                                widget.page.updateSetting('padding', value);
                            widget.viewModel.updatePage(updatedPage);
                            setState(() {});
                          },
                        ),
                      ),
                      Text('${widget.page.padding.toInt()}px'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWidgetSelector() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WidgetSelectorScreen(
          pageId: widget.page.id,
          viewModel: widget.viewModel,
        ),
      ),
    );
  }

  void _applyQuickTemplate(String templateType) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('빠른 템플릿 적용'),
        content: const Text('현재 위젯들이 모두 삭제되고 새로운 템플릿이 적용됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.viewModel.applyQuickTemplate(widget.page.id, templateType);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('템플릿이 적용되었습니다.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }

  void _showPreview() {
    // TODO: Implement preview functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('미리보기 기능은 곧 제공될 예정입니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _savePage() {
    widget.viewModel.saveInvitation();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('페이지가 저장되었습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showColorPicker(String settingKey) {
    // TODO: Implement color picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('색상 선택기는 곧 제공될 예정입니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectBackgroundImage() {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('이미지 선택기는 곧 제공될 예정입니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
