import 'package:flutter/material.dart';
import '../../../../data/models/page_model.dart';
import '../../../viewmodels/editor_viewmodel.dart';
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
  _CustomTemplateEditorState createState() => _CustomTemplateEditorState();
}

class _CustomTemplateEditorState extends State<CustomTemplateEditor> {
  late int _selectedEditMode;
  final List<String> _editModes = ['기본 모드', '자유 배치 모드'];

  @override
  void initState() {
    super.initState();
    _selectedEditMode = 0; // Default to simple mode
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.page.title} 편집'),
        actions: [
          // Mode selector
          DropdownButton<int>(
            value: _selectedEditMode,
            dropdownColor: Theme.of(context).primaryColor,
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: _editModes.asMap().entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedEditMode = value;
                });
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildEditor(),
    );
  }

  Widget _buildEditor() {
    // If free placement mode is selected, show the draggable editor
    if (_selectedEditMode == 0) {
      return CustomDraggableEditor(
        page: widget.page,
        viewModel: widget.viewModel,
      );
    }

    // Otherwise, show the basic editor
    return _buildBasicEditor();
  }

  Widget _buildBasicEditor() {
    // This is the existing simple editor implementation
    final titleController = TextEditingController(
      text: widget.page.content['custom_title'] ?? '커스텀 페이지',
    );
    final contentController = TextEditingController(
      text: widget.page.content['custom_content'] ?? '여기에 내용을 입력하세요.',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('타이틀',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '타이틀을 입력하세요',
            ),
          ),
          const SizedBox(height: 16),

          const Text('내용',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: contentController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '내용을 입력하세요',
            ),
            maxLines: 10,
          ),
          const SizedBox(height: 24),

          Center(
            child: ElevatedButton(
              onPressed: () {
                final updatedContent =
                    Map<String, dynamic>.from(widget.page.content);
                updatedContent['custom_title'] = titleController.text;
                updatedContent['custom_content'] = contentController.text;

                widget.viewModel
                    .updatePageContent(widget.page.id, updatedContent);
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Information about advanced editor
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '자유 배치 모드로 전환하세요!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '자유 배치 모드에서는 다양한 위젯을 화면에 자유롭게 배치하고 꾸밀 수 있습니다. 위젯을 추가하고, 드래그하여 위치를 조정하세요.',
                  ),
                  SizedBox(height: 16),
                  Text(
                    '사용 가능한 위젯: 텍스트, D-day 카운터, 지도, 이미지, 갤러리, 일정표 등',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
