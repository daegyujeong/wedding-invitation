import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/navigation_model.dart';
import '../../data/models/page_model.dart';
import '../../data/models/custom_widget_model.dart';

class EditorViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  NavigationBarModel? _navigationBar;
  List<PageModel> _pages = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  NavigationBarModel? get navigationBar => _navigationBar;
  List<PageModel> get pages => _pages;
  
  // Get a sorted list of pages by order
  List<PageModel> get sortedPages => 
    List.from(_pages)..sort((a, b) => a.order.compareTo(b.order));

  // Initialize data
  Future<void> loadData(String invitationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Here, you would fetch the actual data from Supabase
      // For now, we'll create some sample data
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading

      // Sample navigation bar
      _navigationBar = NavigationBarModel(
        id: 'nav_1',
        items: [
          NavigationItemModel(
            id: 'nav_item_1',
            title: '갤러리',
            icon: 'photo_library',
            isBookmark: false,
            targetPage: 'page_2',
          ),
          NavigationItemModel(
            id: 'nav_item_2',
            title: '오시는 길',
            icon: 'location_on',
            isBookmark: false,
            targetPage: 'page_3',
          ),
          NavigationItemModel(
            id: 'nav_item_3',
            title: '축하 메시지',
            icon: 'message',
            isBookmark: true,
            targetPage: 'page_4',
          ),
        ],
        isEnabled: true,
      );

      // Sample pages
      _pages = [
        PageModel(
          id: 'page_1',
          title: '메인',
          template: 'main',
          content: {
            'background_image': 'assets/images/main.jpg',
            'greeting_text': '저희 두 사람이 사랑과 믿음으로\\n새로운 가정을 이루게 되었습니다.',
          },
          order: 0,
        ),
        PageModel(
          id: 'page_2',
          title: '갤러리',
          template: 'gallery',
          content: {
            'images': [
              'assets/images/gallery1.jpg',
              'assets/images/gallery2.jpg',
              'assets/images/gallery3.jpg',
            ],
          },
          order: 1,
        ),
        PageModel(
          id: 'page_3',
          title: '오시는 길',
          template: 'location',
          content: {
            'address': '서울시 강남구 테헤란로 123',
            'lat': 37.5,
            'lng': 127.0,
          },
          order: 2,
        ),
        PageModel(
          id: 'page_4',
          title: '축하 메시지',
          template: 'message',
          content: {
            'title': '축하 메시지를 남겨주세요',
            'description': '소중한 축하 메시지는 저희에게 큰 힘이 됩니다.',
            'allow_comments': true,
          },
          order: 3,
        ),
      ];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle navigation bar
  void toggleNavigationBar(bool isEnabled) {
    if (_navigationBar != null) {
      _navigationBar = _navigationBar!.copyWith(isEnabled: isEnabled);
      notifyListeners();
    }
  }

  // Toggle a navigation item
  void toggleNavigationItem(String itemId, bool isEnabled) {
    if (_navigationBar == null) return;

    final items = List<NavigationItemModel>.from(_navigationBar!.items);
    final index = items.indexWhere((item) => item.id == itemId);
    
    if (index != -1) {
      items[index] = items[index].copyWith(isEnabled: isEnabled);
      _navigationBar = _navigationBar!.copyWith(items: items);
      notifyListeners();
    }
  }

  // Change navigation item type (bookmark or redirect)
  void setNavigationItemType(String itemId, bool isBookmark) {
    if (_navigationBar == null) return;

    final items = List<NavigationItemModel>.from(_navigationBar!.items);
    final index = items.indexWhere((item) => item.id == itemId);
    
    if (index != -1) {
      items[index] = items[index].copyWith(isBookmark: isBookmark);
      _navigationBar = _navigationBar!.copyWith(items: items);
      notifyListeners();
    }
  }

  // Change navigation item target page
  void setNavigationItemTarget(String itemId, String targetPage) {
    if (_navigationBar == null) return;

    final items = List<NavigationItemModel>.from(_navigationBar!.items);
    final index = items.indexWhere((item) => item.id == itemId);
    
    if (index != -1) {
      items[index] = items[index].copyWith(targetPage: targetPage);
      _navigationBar = _navigationBar!.copyWith(items: items);
      notifyListeners();
    }
  }

  // Add a new page
  void addPage(String title, String template) {
    final uuid = const Uuid();
    final newPage = PageModel(
      id: uuid.v4(),
      title: title,
      template: template,
      content: {},
      order: _pages.length, // Add to the end
    );
    
    _pages.add(newPage);
    notifyListeners();
  }

  // Remove a page
  void removePage(String pageId) {
    _pages.removeWhere((page) => page.id == pageId);
    // Update orders
    for (int i = 0; i < _pages.length; i++) {
      _pages[i] = _pages[i].copyWith(order: i);
    }
    notifyListeners();
  }

  // Update page order (reordering)
  void reorderPages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final sortedPages = List<PageModel>.from(this.sortedPages);
    final item = sortedPages.removeAt(oldIndex);
    sortedPages.insert(newIndex, item);

    // Update order field for all pages
    _pages = sortedPages.asMap().entries.map((entry) {
      final index = entry.key;
      final page = entry.value;
      return page.copyWith(order: index);
    }).toList();

    notifyListeners();
  }

  // Update page content
  void updatePageContent(String pageId, Map<String, dynamic> content) {
    final index = _pages.indexWhere((page) => page.id == pageId);
    if (index != -1) {
      _pages[index] = _pages[index].copyWith(content: content);
      notifyListeners();
    }
  }

  // Update page widgets
  void updatePageWidgets(String pageId, List<CustomWidgetModel> widgets) {
    final index = _pages.indexWhere((page) => page.id == pageId);
    if (index != -1) {
      _pages[index] = _pages[index].copyWith(widgets: widgets);
      notifyListeners();
    }
  }

  // Save all changes
  Future<void> saveChanges() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Here you would save to Supabase
      await Future.delayed(const Duration(seconds: 1)); // Simulate saving
      
      // If successful, you might want to reload the data
      // await loadData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}