import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wedding_invitation/presentation/viewmodels/editor_viewmodel.dart';
import 'package:wedding_invitation/presentation/widgets/editor/widget_renderer.dart';
import 'dart:io';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('미리보기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement sharing (e.g., as link, image, etc.)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('공유 기능 준비 중입니다.')),
              );
            },
          ),
        ],
      ),
      body: Consumer<EditorViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              // Background
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: viewModel.backgroundColor,
                  image: viewModel.backgroundImage != null
                      ? DecorationImage(
                          image: FileImage(viewModel.backgroundImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              
              // Widget layout (non-editable)
              Stack(
                children: viewModel.widgets.map((widget) {
                  final position = widget.data['position'] != null
                      ? Offset(
                          widget.data['position']['dx'],
                          widget.data['position']['dy'],
                        )
                      : const Offset(0, 0);
                      
                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: WidgetRenderer(widget: widget),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}