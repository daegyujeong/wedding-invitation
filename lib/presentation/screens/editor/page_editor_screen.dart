import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/editor_viewmodel.dart';
import 'template_editors/template_editor_factory.dart';

class PageEditorScreen extends StatelessWidget {
  const PageEditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorViewModel>(
      builder: (context, viewModel, child) {
        final pages = viewModel.sortedPages;

        return Column(
          children: [
            // Add page button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('페이지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('페이지 추가'),
                    onPressed: () {
                      _showAddPageDialog(context, viewModel);
                    },
                  ),
                ],
              ),
            ),

            // Pages list
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  viewModel.reorderPages(oldIndex, newIndex);
                },
                children: pages.map((page) => _buildPageItem(context, viewModel, page)).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageItem(BuildContext context, EditorViewModel viewModel, dynamic page) {
    return Card(
      key: Key(page.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(_getIconForTemplate(page.template)),
        title: Text(page.title),
        subtitle: Text('템플릿: ${page.template}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to detail page editor
                _navigateToPageDetailEditor(context, page);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmation(context, viewModel, page);
              },
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTemplate(String template) {
    switch (template) {
      case 'main':
        return Icons.home;
      case 'gallery':
        return Icons.photo_library;
      case 'location':
        return Icons.location_on;
      case 'message':
        return Icons.message;
      default:
        return Icons.page;
    }
  }

  void _showAddPageDialog(BuildContext context, EditorViewModel viewModel) {
    final titleController = TextEditingController();
    String selectedTemplate = 'main';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('페이지 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '페이지 제목',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTemplate,
                decoration: const InputDecoration(
                  labelText: '템플릿',
                ),
                items: const [
                  DropdownMenuItem(value: 'main', child: Text('메인')),
                  DropdownMenuItem(value: 'gallery', child: Text('갤러리')),
                  DropdownMenuItem(value: 'location', child: Text('오시는 길')),
                  DropdownMenuItem(value: 'message', child: Text('축하 메시지')),
                  DropdownMenuItem(value: 'custom', child: Text('커스텀')),
                ],
                onChanged: (value) {
                  selectedTemplate = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  viewModel.addPage(titleController.text, selectedTemplate);
                  Navigator.pop(context);
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, EditorViewModel viewModel, dynamic page) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('페이지 삭제'),
          content: Text('정말로 "${page.title}" 페이지를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                viewModel.removePage(page.id);
                Navigator.pop(context);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPageDetailEditor(BuildContext context, dynamic page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateEditorFactory.getEditor(
          context, 
          page, 
          Provider.of<EditorViewModel>(context, listen: false),
        ),
      ),
    );
  }
}