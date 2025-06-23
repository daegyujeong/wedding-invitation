import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/navigation_model.dart';
import '../../data/models/page_model.dart';
import '../../data/models/custom_widget_model.dart';
import '../../data/services/widget_template_service.dart';

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
          widgets: [
            CustomWidgetModel(
              id: 'main_greeting',
              type: WidgetType.text,
              positionX: 20,
              positionY: 100,
              width: 360,
              height: 80,
              properties: {
                'text': '저희 두 사람이 사랑과 믿음으로\n새로운 가정을 이루게 되었습니다.',
                'fontSize': 18.0,
                'fontWeight': 'normal',
                'color': '#333333',
                'textAlign': 'center',
                'backgroundColor': 'transparent',
              },
            ),
          ],
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
          widgets: [
            CustomWidgetModel(
              id: 'gallery_title',
              type: WidgetType.text,
              positionX: 20,
              positionY: 20,
              width: 360,
              height: 40,
              properties: {
                'text': '우리의 소중한 순간들',
                'fontSize': 24.0,
                'fontWeight': 'bold',
                'color': '#333333',
                'textAlign': 'center',
                'backgroundColor': 'transparent',
              },
            ),
            CustomWidgetModel(
              id: 'gallery_img1',
              type: WidgetType.image,
              positionX: 20,
              positionY: 80,
              width: 160,
              height: 120,
              properties: {
                'imageUrl': 'assets/images/placeholder.png',
                'fit': 'cover',
                'borderRadius': 8.0,
              },
            ),
            CustomWidgetModel(
              id: 'gallery_img2',
              type: WidgetType.image,
              positionX: 200,
              positionY: 80,
              width: 160,
              height: 120,
              properties: {
                'imageUrl': 'assets/images/placeholder.png',
                'fit': 'cover',
                'borderRadius': 8.0,
              },
            ),
          ],
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
          widgets: [
            CustomWidgetModel(
              id: 'location_map',
              type: WidgetType.map,
              positionX: 20,
              positionY: 20,
              width: 360,
              height: 200,
              properties: {
                'latitude': 37.5,
                'longitude': 127.0,
                'address': '서울시 강남구 테헤란로 123',
                'zoom': 15.0,
              },
            ),
            CustomWidgetModel(
              id: 'location_address',
              type: WidgetType.text,
              positionX: 20,
              positionY: 240,
              width: 360,
              height: 60,
              properties: {
                'text': '📍 서울시 강남구 테헤란로 123\n그랜드 컨벤션 센터 3층',
                'fontSize': 16.0,
                'fontWeight': 'normal',
                'color': '#666666',
                'textAlign': 'center',
                'backgroundColor': 'transparent',
              },
            ),
          ],
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
          widgets: [
            CustomWidgetModel(
              id: 'message_title',
              type: WidgetType.text,
              positionX: 20,
              positionY: 20,
              width: 360,
              height: 40,
              properties: {
                'text': '축하 메시지를 남겨주세요',
                'fontSize': 20.0,
                'fontWeight': 'bold',
                'color': '#333333',
                'textAlign': 'center',
                'backgroundColor': 'transparent',
              },
            ),
            CustomWidgetModel(
              id: 'message_description',
              type: WidgetType.text,
              positionX: 20,
              positionY: 80,
              width: 360,
              height: 40,
              properties: {
                'text': '소중한 축하 메시지는 저희에게 큰 힘이 됩니다.',
                'fontSize': 14.0,
                'fontWeight': 'normal',
                'color': '#666666',
                'textAlign': 'center',
                'backgroundColor': 'transparent',
              },
            ),
          ],
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

  // Add a new page (simplified - no template parameter)
  void addPage(String title, String? template) {
    const uuid = Uuid();
    final newPage = PageModel(
      id: uuid.v4(),
      title: title,
      settings: {
        'backgroundColor': '#FFFFFF',
        'showTitle': true,
        'titleColor': '#333333',
        'titleSize': 24.0,
        'padding': 16.0,
      },
      order: _pages.length, // Add to the end
      widgets: [],
    );

    _pages.add(newPage);
    notifyListeners();
  }

  // Duplicate a page
  void duplicatePage(String pageId) {
    final originalPage = _pages.firstWhere((page) => page.id == pageId);
    const uuid = Uuid();

    final duplicatedPage = PageModel(
      id: uuid.v4(),
      title: '${originalPage.title} (복사)',
      settings: Map<String, dynamic>.from(originalPage.settings),
      order: _pages.length,
      widgets: originalPage.widgets
          .map((widget) => CustomWidgetModel(
                id: uuid.v4(),
                type: widget.type,
                positionX: widget.positionX,
                positionY: widget.positionY,
                width: widget.width,
                height: widget.height,
                properties: Map<String, dynamic>.from(widget.properties),
              ))
          .toList(),
    );

    _pages.add(duplicatedPage);
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

  // Update entire page
  void updatePage(PageModel updatedPage) {
    final index = _pages.indexWhere((page) => page.id == updatedPage.id);
    if (index != -1) {
      _pages[index] = updatedPage;
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

  // Add widget to page
  void addWidget(String pageId, CustomWidgetModel widget) {
    final index = _pages.indexWhere((page) => page.id == pageId);
    if (index != -1) {
      final currentWidgets =
          List<CustomWidgetModel>.from(_pages[index].widgets);
      currentWidgets.add(widget);
      _pages[index] = _pages[index].copyWith(widgets: currentWidgets);
      notifyListeners();
    }
  }

  // Remove widget from page
  void removeWidget(String pageId, String widgetId) {
    final index = _pages.indexWhere((page) => page.id == pageId);
    if (index != -1) {
      final currentWidgets =
          List<CustomWidgetModel>.from(_pages[index].widgets);
      currentWidgets.removeWhere((widget) => widget.id == widgetId);
      _pages[index] = _pages[index].copyWith(widgets: currentWidgets);
      notifyListeners();
    }
  }

  // Update widget in page
  void updateWidget(String pageId, CustomWidgetModel updatedWidget) {
    final pageIndex = _pages.indexWhere((page) => page.id == pageId);
    if (pageIndex != -1) {
      final currentWidgets =
          List<CustomWidgetModel>.from(_pages[pageIndex].widgets);
      final widgetIndex =
          currentWidgets.indexWhere((widget) => widget.id == updatedWidget.id);

      if (widgetIndex != -1) {
        currentWidgets[widgetIndex] = updatedWidget;
        _pages[pageIndex] = _pages[pageIndex].copyWith(widgets: currentWidgets);
        notifyListeners();
      }
    }
  }

  // Apply quick template to page
  void applyQuickTemplate(String pageId, String templateType) {
    final widgets = WidgetTemplateService.getTemplate(templateType);
    updatePageWidgets(pageId, widgets);
  }

  // Save all changes (for backward compatibility)
  Future<void> saveChanges() async {
    await saveInvitation();
  }

  // Save invitation
  Future<void> saveInvitation() async {
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

  // Get main page (for home screen compatibility)
  PageModel? get mainPage {
    // Find the first page or a page with specific settings indicating it's the main page
    if (_pages.isNotEmpty) {
      return _pages.firstWhere(
        (page) => page.order == 0,
        orElse: () => _pages.first,
      );
    }
    return null;
  }

  // Get greeting text (for home screen compatibility)
  String getGreetingText(String language) {
    final main = mainPage;
    if (main != null) {
      // Look for a text widget that might contain greeting
      final greetingWidget = main.widgets.firstWhere(
        (widget) =>
            widget.type == WidgetType.text &&
            widget.properties['text']?.toString().contains('사랑') == true,
        orElse: () => main.widgets.isNotEmpty
            ? main.widgets.first
            : CustomWidgetModel(
                id: 'default',
                type: WidgetType.text,
                positionX: 0,
                positionY: 0,
                width: 0,
                height: 0,
                properties: {'text': ''},
              ),
      );

      return greetingWidget.properties['text']?.toString() ?? '';
    }
    return '';
  }
}