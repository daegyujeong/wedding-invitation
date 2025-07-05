import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/editor_viewmodel.dart';
import 'template_editors/template_editor_factory.dart';

class PageEditorScreen extends StatelessWidget {
  const PageEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorViewModel>(
      builder: (context, viewModel, child) {
        final pages = viewModel.sortedPages;

        return Column(
          children: [
            // Header with add page button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '페이지 관리',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('새 페이지'),
                    onPressed: () => _showAddPageDialog(context, viewModel),
                  ),
                ],
              ),
            ),

            // Info card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '모든 페이지는 사용자 정의 페이지입니다. 위젯을 추가하여 원하는 레이아웃을 만들어보세요.',
                      style:
                          TextStyle(color: Colors.blue.shade700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Pages list
            Expanded(
              child: pages.isEmpty
                  ? _buildEmptyState(context, viewModel)
                  : ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        viewModel.reorderPages(oldIndex, newIndex);
                      },
                      children: pages
                          .map((page) =>
                              _buildPageItem(context, viewModel, page))
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, EditorViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pages_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 페이지가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 페이지를 만들어 청첩장을 시작해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('첫 페이지 만들기'),
            onPressed: () => _showAddPageDialog(context, viewModel),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageItem(
      BuildContext context, EditorViewModel viewModel, dynamic page) {
    return Card(
      key: Key(page.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.pages,
            color: Colors.blue.shade700,
          ),
        ),
        title: Text(
          page.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '위젯 ${page.widgets?.length ?? 0}개',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: '편집',
              onPressed: () => _navigateToPageDetailEditor(context, page),
            ),
            // Duplicate button
            IconButton(
              icon: const Icon(Icons.copy_outlined),
              tooltip: '복사',
              onPressed: () => _duplicatePage(context, viewModel, page),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '삭제',
              onPressed: () =>
                  _showDeleteConfirmation(context, viewModel, page),
            ),
            // Drag handle
            const Icon(Icons.drag_handle, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showAddPageDialog(BuildContext context, EditorViewModel viewModel) {
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('새 페이지 만들기'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '페이지 제목',
                    hintText: '예: 메인, 사진, 위치 안내',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '페이지 제목을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '페이지를 만든 후 위젯을 추가하여 콘텐츠를 구성할 수 있습니다.',
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  viewModel.addPage(titleController.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '페이지 "${titleController.text.trim()}"가 생성되었습니다.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('만들기'),
            ),
          ],
        );
      },
    );
  }

  void _duplicatePage(
      BuildContext context, EditorViewModel viewModel, dynamic page) {
    viewModel.duplicatePage(page.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('페이지 "${page.title}"가 복사되었습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, EditorViewModel viewModel, dynamic page) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('페이지 삭제'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('정말로 "${page.title}" 페이지를 삭제하시겠습니까?'),
              const SizedBox(height: 8),
              Text(
                '이 작업은 되돌릴 수 없습니다.',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                viewModel.removePage(page.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('페이지 "${page.title}"가 삭제되었습니다.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
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
