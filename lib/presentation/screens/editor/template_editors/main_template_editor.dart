import 'package:flutter/material.dart';
import '../../../../data/models/page_model.dart';
import '../../../viewmodels/editor_viewmodel.dart';

class MainTemplateEditor extends StatefulWidget {
  final PageModel page;
  final EditorViewModel viewModel;

  const MainTemplateEditor({
    super.key,
    required this.page,
    required this.viewModel,
  });

  @override
  _MainTemplateEditorState createState() => _MainTemplateEditorState();
}

class _MainTemplateEditorState extends State<MainTemplateEditor> {
  late TextEditingController _greetingController;
  String _backgroundImage = '';

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing content
    _greetingController = TextEditingController(
      text: widget.page.settings['greeting_text'] ??
          '저희 두 사람이 사랑과 믿음으로 새로운 가정을 이루게 되었습니다.',
    );
    _backgroundImage =
        widget.page.settings['background_image'] ?? 'assets/images/main.jpg';
  }

  @override
  void dispose() {
    _greetingController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedSettings = Map<String, dynamic>.from(widget.page.settings);
    updatedSettings['greeting_text'] = _greetingController.text;
    updatedSettings['background_image'] = _backgroundImage;

    final updatedPage = widget.page.copyWith(settings: updatedSettings);
    widget.viewModel.updatePage(updatedPage);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.page.title} 편집'),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Background image preview
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                image: _backgroundImage.isNotEmpty
                    ? DecorationImage(
                        image: AssetImage(_backgroundImage),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _backgroundImage.isEmpty
                  ? const Center(child: Text('배경 이미지 없음'))
                  : null,
            ),
            const SizedBox(height: 16),

            // Background image button
            ElevatedButton.icon(
              onPressed: () {
                // In a real app, this would open an image picker
                // For now, just set a default
                setState(() {
                  _backgroundImage = 'assets/images/main.jpg';
                });
              },
              icon: const Icon(Icons.image),
              label: const Text('배경 이미지 변경'),
            ),
            const SizedBox(height: 24),

            // Greeting text editor
            const Text('인사말',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _greetingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '인사말을 입력하세요',
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
