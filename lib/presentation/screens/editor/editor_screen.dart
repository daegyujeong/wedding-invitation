import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/editor_viewmodel.dart';
import 'navigation_editor_screen.dart';
import 'page_editor_screen.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  int _selectedIndex = 0;
  final _tabs = const [
    Tab(text: '페이지', icon: Icon(Icons.pages)),
    Tab(text: '네비게이션', icon: Icon(Icons.menu)),
  ];

  @override
  void initState() {
    super.initState();
    // Load editor data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EditorViewModel>(context, listen: false).loadData('1');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('청첩장 에디터'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Provider.of<EditorViewModel>(context, listen: false).saveChanges();
            },
          ),
        ],
        bottom: TabBar(
          tabs: _tabs,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      body: Consumer<EditorViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text('오류: ${viewModel.errorMessage}'));
          }

          return IndexedStack(
            index: _selectedIndex,
            children: const [
              PageEditorScreen(),
              NavigationEditorScreen(),
            ],
          );
        },
      ),
    );
  }
}