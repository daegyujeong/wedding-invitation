import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/editor_viewmodel.dart';

class NavigationEditorScreen extends StatelessWidget {
  const NavigationEditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorViewModel>(
      builder: (context, viewModel, child) {
        final navigationBar = viewModel.navigationBar;
        if (navigationBar == null) {
          return const Center(child: Text('네비게이션 바 데이터가 없습니다.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation bar toggle
              SwitchListTile(
                title: const Text('네비게이션 바 활성화'),
                value: navigationBar.isEnabled,
                onChanged: (value) {
                  viewModel.toggleNavigationBar(value);
                },
              ),

              const Divider(),
              const Text('네비게이션 아이템', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Navigation items
              ...navigationBar.items.map((item) => _buildNavigationItemEditor(context, viewModel, item)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationItemEditor(BuildContext context, EditorViewModel viewModel, dynamic item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(IconData(int.parse('0xe${item.icon.hashCode.toRadixString(16).substring(0, 3)}'), fontFamily: 'MaterialIcons')),
                const SizedBox(width: 8),
                Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Switch(
                  value: item.isEnabled,
                  onChanged: (value) {
                    viewModel.toggleNavigationItem(item.id, value);
                  },
                ),
              ],
            ),
            const Divider(),
            // Navigation type selection (bookmark or redirect)
            Row(
              children: [
                const Text('네비게이션 유형:'),
                const Spacer(),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('리다이렉트'),
                      icon: Icon(Icons.open_in_new),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('북마크'),
                      icon: Icon(Icons.bookmark),
                    ),
                  ],
                  selected: {item.isBookmark},
                  onSelectionChanged: (value) {
                    viewModel.setNavigationItemType(item.id, value.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Target page selection
            Row(
              children: [
                const Text('타겟 페이지:'),
                const Spacer(),
                DropdownButton<String>(
                  value: item.targetPage,
                  items: viewModel.pages.map<DropdownMenuItem<String>>((page) {
                    return DropdownMenuItem<String>(
                      value: page.id,
                      child: Text(page.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.setNavigationItemTarget(item.id, value);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}