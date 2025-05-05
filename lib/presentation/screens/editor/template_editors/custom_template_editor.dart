import 'package:flutter/material.dart';
import '../../../../data/models/page_model.dart';
import '../../../viewmodels/editor_viewmodel.dart';

class CustomTemplateEditor extends StatefulWidget {
  final PageModel page;
  final EditorViewModel viewModel;

  const CustomTemplateEditor({
    Key? key,
    required this.page,
    required this.viewModel,
  }) : super(key: key);

  @override
  _CustomTemplateEditorState createState() => _CustomTemplateEditorState();
}

class _CustomTemplateEditorState extends State<CustomTemplateEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing content
    _titleController = TextEditingController(
      text: widget.page.content['custom_title'] ?? '커스텀 페이지',
    );
    _contentController = TextEditingController(
      text: widget.page.content['custom_content'] ?? '여기에 내용을 입력하세요.',
    );
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedContent = Map<String, dynamic>.from(widget.page.content);
    updatedContent['custom_title'] = _titleController.text;
    updatedContent['custom_content'] = _contentController.text;
    
    widget.viewModel.updatePageContent(widget.page.id, updatedContent);
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
            const Text('타이틀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '타이틀을 입력하세요',
              ),
            ),
            const SizedBox(height: 16),
            
            // Content
            const Text('내용', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '내용을 입력하세요',
              ),
              maxLines: 10,
            ),
          ],
        ),
      ),
    );
  }
}