import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/navigation_model.dart';
import '../../data/models/page_model.dart';

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

      // Sample navigation bar with D-day settings
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
        showDDay: true,
        eventDate: DateTime.now().add(const Duration(days: 30)),
        ddayFormat: 'D-{days}',
      );

      // Sample pages using new structure
      _pages = [
        PageModel(
          id: 'page_1',
          title: '메인',
          settings: {
            'backgroundColor': '#F8F9FA',
            'backgroundImage': 'assets/images/placeholder.png',
            'showTitle': true,
            'titleColor': '#333333',
            'titleSize': 28.0,
            'padding': 16.0,
          },
          order: 0,
        ),
        PageModel(
          id: 'page_2',
          title: '갤러리',
          settings: {
            'backgroundColor': '#FFFFFF',
            'showTitle': true,
            'titleColor': '#333333',
            'titleSize': 24.0,
            'padding': 16.0,
          },
          order: 1,
        ),
        PageModel(
          id: 'page_3',
          title: '오시는 길',
          settings: {
            'backgroundColor': '#FFFFFF',
            'showTitle': true,
            'titleColor': '#333333',
            'titleSize': 24.0,
            'padding': 16.0,
          },
          order: 2,
        ),
        PageModel(
          id: 'page_4',
          title: '축하 메시지',
          settings: {
            'backgroundColor': '#FFFFFF',
            'showTitle': true,
            'titleColor': '#333333',
            'titleSize': 24.0,
            'padding': 16.0,
          },
          order: 3,
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new page
  void addPage(String title) {
    final newPage = PageModel(
      id: const Uuid().v4(),
      title: title,
      settings: {
        'backgroundColor': '#FFFFFF',
        'showTitle': true,
        'titleColor': '#333333',
        'titleSize': 24.0,
        'padding': 16.0,
      },
      order: _pages.length,
    );

    _pages.add(newPage);
    notifyListeners();
  }

  // Update page
  void updatePage(PageModel updatedPage) {
    final index = _pages.indexWhere((page) => page.id == updatedPage.id);
    if (index != -1) {
      _pages[index] = updatedPage;
      notifyListeners();
    }
  }

  // Delete page
  void deletePage(String pageId) {
    _pages.removeWhere((page) => page.id == pageId);
    _reorderPages();
    notifyListeners();
  }

  // Reorder pages (after deletion)
  void _reorderPages() {
    for (int i = 0; i < _pages.length; i++) {
      _pages[i] = _pages[i].copyWith(order: i);
    }
  }

  // Update navigation bar
  void updateNavigationBar(NavigationBarModel navigationBar) {
    _navigationBar = navigationBar;
    notifyListeners();
  }

  // Get page by ID
  PageModel? getPageById(String pageId) {
    try {
      return _pages.firstWhere((page) => page.id == pageId);
    } catch (e) {
      return null;
    }
  }

  // Navigation bar methods
  void toggleNavigationBar(bool isEnabled) {
    if (_navigationBar != null) {
      _navigationBar = _navigationBar!.copyWith(isEnabled: isEnabled);
      notifyListeners();
    }
  }

  void updateNavigationBarDDay({
    required bool showDDay,
    DateTime? eventDate,
    required String ddayFormat,
  }) {
    if (_navigationBar != null) {
      _navigationBar = _navigationBar!.copyWith(
        showDDay: showDDay,
        eventDate: eventDate,
        ddayFormat: ddayFormat,
      );
      notifyListeners();
    }
  }

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

  // Page management methods
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

  void duplicatePage(String pageId) {
    final originalPage = _pages.firstWhere((page) => page.id == pageId);
    const uuid = Uuid();

    final duplicatedPage = PageModel(
      id: uuid.v4(),
      title: '${originalPage.title} (복사)',
      settings: Map<String, dynamic>.from(originalPage.settings),
      order: _pages.length,
    );

    _pages.add(duplicatedPage);
    notifyListeners();
  }

  void removePage(String pageId) {
    _pages.removeWhere((page) => page.id == pageId);
    _reorderPages();
    notifyListeners();
  }

  // Save methods
  Future<void> saveChanges() async {
    await saveInvitation();
  }

  Future<void> saveInvitation() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Here you would save to your backend
      await Future.delayed(const Duration(seconds: 1)); // Simulate saving

      // If successful, you might want to show a success message
    } catch (e) {
      _errorMessage = 'Failed to save: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Template methods
  void applyQuickTemplate(String pageId, String templateType) {
    // Apply a quick template to a specific page
    final page = getPageById(pageId);
    if (page != null) {
      final updatedSettings = Map<String, dynamic>.from(page.settings);

      switch (templateType) {
        case 'romantic':
          updatedSettings['backgroundColor'] = '#FFE5E5';
          updatedSettings['titleColor'] = '#8B4B5C';
          break;
        case 'minimal':
          updatedSettings['backgroundColor'] = '#FFFFFF';
          updatedSettings['titleColor'] = '#333333';
          break;
        case 'classic':
          updatedSettings['backgroundColor'] = '#F8F6F0';
          updatedSettings['titleColor'] = '#8B4513';
          break;
      }

      updatePage(page.copyWith(settings: updatedSettings));
    }
  }

  void loadTemplatePages(String templateId) {
    // This would load template pages from a service
    // For now, just clear and add a basic template
    _pages.clear();

    switch (templateId) {
      case 'romantic':
        _pages.add(PageModel(
          id: 'romantic_1',
          title: '로맨틱 메인',
          settings: {
            'backgroundColor': '#FFE5E5',
            'showTitle': true,
            'titleColor': '#8B4B5C',
            'titleSize': 28.0,
            'padding': 20.0,
          },
          order: 0,
        ));
        break;
      case 'minimal':
        _pages.add(PageModel(
          id: 'minimal_1',
          title: '미니멀 메인',
          settings: {
            'backgroundColor': '#FFFFFF',
            'showTitle': true,
            'titleColor': '#333333',
            'titleSize': 24.0,
            'padding': 16.0,
          },
          order: 0,
        ));
        break;
      case 'classic':
        _pages.add(PageModel(
          id: 'classic_1',
          title: '클래식 메인',
          settings: {
            'backgroundColor': '#F8F6F0',
            'showTitle': true,
            'titleColor': '#8B4513',
            'titleSize': 32.0,
            'padding': 24.0,
          },
          order: 0,
        ));
        break;
      default:
        addPage('새 페이지');
    }

    notifyListeners();
  }
}
