import 'package:flutter/material.dart';
import '../../../../data/models/page_model.dart';
import '../../../viewmodels/editor_viewmodel.dart';
import 'main_template_editor.dart';
import 'gallery_template_editor.dart';
import 'location_template_editor.dart';
import 'message_template_editor.dart';
import 'custom_template_editor.dart';

class TemplateEditorFactory {
  static Widget getEditor(
    BuildContext context, 
    PageModel page, 
    EditorViewModel viewModel
  ) {
    switch (page.template) {
      case 'main':
        return MainTemplateEditor(page: page, viewModel: viewModel);
      case 'gallery':
        return GalleryTemplateEditor(page: page, viewModel: viewModel);
      case 'location':
        return LocationTemplateEditor(page: page, viewModel: viewModel);
      case 'message':
        return MessageTemplateEditor(page: page, viewModel: viewModel);
      case 'custom':
        return CustomTemplateEditor(page: page, viewModel: viewModel);
      default:
        return Center(child: Text('템플릿 에디터를 찾을 수 없습니다: ${page.template}'));
    }
  }
}