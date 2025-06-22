import 'package:flutter/material.dart';
import '../../../../data/models/page_model.dart';
import '../../../viewmodels/editor_viewmodel.dart';

class MessageTemplateEditor extends StatefulWidget {
  final PageModel page;
  final EditorViewModel viewModel;

  const MessageTemplateEditor({
    super.key,
    required this.page,
    required this.viewModel,
  });

  @override
  _MessageTemplateEditorState createState() => _MessageTemplateEditorState();
}

class _MessageTemplateEditorState extends State<MessageTemplateEditor> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _allowComments = true;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing content
    _titleController = TextEditingController(
      text: widget.page.settings['title'] ?? '축하 메시지를 남겨주세요',
    );
    _descriptionController = TextEditingController(
      text: widget.page.settings['description'] ?? '소중한 축하 메시지는 저희에게 큰 힘이 됩니다.',
    );
    _allowComments = widget.page.settings['allow_comments'] ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedContent = Map<String, dynamic>.from(widget.page.settings);
    updatedContent['title'] = _titleController.text;
    updatedContent['description'] = _descriptionController.text;
    updatedContent['allow_comments'] = _allowComments;

    // widget.viewModel.updatePageWidgets(widget.page.id, updatedContent);
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
            // Title
            const Text('타이틀',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '타이틀을 입력하세요',
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text('설명',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '설명을 입력하세요',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Allow comments toggle
            SwitchListTile(
              title: const Text('메시지 작성 허용'),
              subtitle: const Text('방문자들이 축하 메시지를 남길 수 있도록 허용합니다.'),
              value: _allowComments,
              onChanged: (value) {
                setState(() {
                  _allowComments = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
