import 'package:flutter/material.dart';
import '../../../../data/models/page_model.dart';
import '../../../viewmodels/editor_viewmodel.dart';

class GalleryTemplateEditor extends StatefulWidget {
  final PageModel page;
  final EditorViewModel viewModel;

  const GalleryTemplateEditor({
    Key? key,
    required this.page,
    required this.viewModel,
  }) : super(key: key);

  @override
  _GalleryTemplateEditorState createState() => _GalleryTemplateEditorState();
}

class _GalleryTemplateEditorState extends State<GalleryTemplateEditor> {
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing content
    _images = List<String>.from(widget.page.content['images'] ?? []);
    if (_images.isEmpty) {
      _images.add('assets/images/gallery1.jpg');
      _images.add('assets/images/gallery2.jpg');
    }
  }

  void _saveChanges() {
    final updatedContent = Map<String, dynamic>.from(widget.page.content);
    updatedContent['images'] = _images;
    
    widget.viewModel.updatePageContent(widget.page.id, updatedContent);
    Navigator.pop(context);
  }

  void _addImage() {
    // In a real app, this would open an image picker
    // For now, just add a default image
    setState(() {
      _images.add('assets/images/gallery${_images.length + 1}.jpg');
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('갤러리 이미지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _addImage,
                  icon: const Icon(Icons.add),
                  label: const Text('이미지 추가'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      // Image preview
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(_images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      // Actions
                      ButtonBar(
                        alignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              // In a real app, this would open an image picker
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('변경'),
                          ),
                          TextButton.icon(
                            onPressed: () => _removeImage(index),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('삭제', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}