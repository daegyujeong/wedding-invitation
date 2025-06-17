  void _addTemplate(String templateType) {
    _showConfirmationDialog(
      title: '템플릿 추가',
      content: '선택한 템플릿의 모든 위젯이 페이지에 추가됩니다. 계속하시겠습니까?',
      onConfirm: () {
        final widgets = WidgetTemplateService.getTemplate(templateType);
        for (final widget in widgets) {
          // 올바른 방법: WidgetSelectorScreen의 pageId와 viewModel 사용
          widget.viewModel.addWidget(widget.pageId, widget);
        }
        Navigator.pop(context);
        _showSuccessSnackBar('템플릿이 추가되었습니다.');
      },
    );
  }

  void _addWidget(String widgetType) {
    final widget = WidgetTemplateService.createDefaultWidget(widgetType);
    // 올바른 방법: WidgetSelectorScreen의 pageId와 viewModel 사용
    widget.viewModel.addWidget(widget.pageId, widget);
    Navigator.pop(context);
    _showSuccessSnackBar('위젯이 추가되었습니다.');
  }