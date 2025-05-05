import 'package:flutter/material.dart';
import '../../../../data/models/page_model.dart';
import '../../../viewmodels/editor_viewmodel.dart';

class LocationTemplateEditor extends StatefulWidget {
  final PageModel page;
  final EditorViewModel viewModel;

  const LocationTemplateEditor({
    Key? key,
    required this.page,
    required this.viewModel,
  }) : super(key: key);

  @override
  _LocationTemplateEditorState createState() => _LocationTemplateEditorState();
}

class _LocationTemplateEditorState extends State<LocationTemplateEditor> {
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing content
    _addressController = TextEditingController(
      text: widget.page.content['address'] ?? '서울시 강남구 테헤란로 123',
    );
    _latController = TextEditingController(
      text: (widget.page.content['lat'] ?? 37.5).toString(),
    );
    _lngController = TextEditingController(
      text: (widget.page.content['lng'] ?? 127.0).toString(),
    );
  }
  
  @override
  void dispose() {
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedContent = Map<String, dynamic>.from(widget.page.content);
    updatedContent['address'] = _addressController.text;
    updatedContent['lat'] = double.tryParse(_latController.text) ?? 37.5;
    updatedContent['lng'] = double.tryParse(_lngController.text) ?? 127.0;
    
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
            // Map preview (placeholder)
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map, size: 50),
                    const SizedBox(height: 8),
                    Text('위도: ${_latController.text}, 경도: ${_lngController.text}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Address
            const Text('주소', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '주소를 입력하세요',
              ),
            ),
            const SizedBox(height: 16),
            
            // Coordinates
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('위도', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _latController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '위도',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('경도', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _lngController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '경도',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}