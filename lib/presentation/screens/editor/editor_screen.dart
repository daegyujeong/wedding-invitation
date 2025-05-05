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

class _EditorScreenState extends State<EditorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = const [
    Tab(text: '페이지', icon: Icon(Icons.pages)),
    Tab(text: '네비게이션', icon: Icon(Icons.menu)),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the number of tabs
    _tabController = TabController(length: _tabs.length, vsync: this);
    
    // Load editor data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EditorViewModel>(context, listen: false).loadData('1');
    });
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is disposed
    _tabController.dispose();
    super.dispose();
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
          controller: _tabController, // Connect the TabBar to the controller
          tabs: _tabs,
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

          return TabBarView(
            controller: _tabController, // Also connect the TabBarView to the same controller
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