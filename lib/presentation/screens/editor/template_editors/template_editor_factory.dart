import 'package:flutter/material.dart';
import '../../../../data/models/page_model.dart';
import '../../../viewmodels/editor_viewmodel.dart';
import 'custom_template_editor.dart';

class TemplateEditorFactory {
  static Widget getEditor(
    BuildContext context, 
    PageModel page, 
    EditorViewModel viewModel
  ) {
    // All pages now use the custom template editor
    return CustomTemplateEditor(page: page, viewModel: viewModel);
  }
}
