import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Common UI components for widget property editing
class CommonEditorFields {
  /// Responsive text field that adapts to screen size
  static Widget buildResponsiveTextField({
    required String labelText,
    String? initialValue,
    required Function(String) onChanged,
    int maxLines = 1,
    String? hintText,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }

  /// Slider field with label and value display
  static Widget buildSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value.toStringAsFixed(1),
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Dropdown field with label
  static Widget buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Color picker field with preview
  static Widget buildColorPickerField({
    required String label,
    required Color color,
    required Function(Color) onChanged,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => context.showColorPicker(
            currentColor: color,
            onColorChanged: onChanged,
          ),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                style: TextStyle(
                  color: color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Switch field with label
  static Widget buildSwitchField({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    String? subtitle,
  }) {
    return SwitchListTile(
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// URL input field with validation
  static Widget buildUrlField({
    required String labelText,
    String? initialValue,
    required Function(String) onChanged,
    String? hintText,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText ?? 'https://example.com',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        prefixIcon: const Icon(Icons.link),
      ),
      keyboardType: TextInputType.url,
      onChanged: onChanged,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final uri = Uri.tryParse(value);
          if (uri == null || (!uri.hasScheme)) {
            return '올바른 URL을 입력해주세요';
          }
        }
        return null;
      },
    );
  }

  /// Font weight selector
  static Widget buildFontWeightField({
    required FontWeight value,
    required Function(FontWeight) onChanged,
  }) {
    return buildDropdownField<FontWeight>(
      label: '글꼴 굵기',
      value: value,
      items: [
        const DropdownMenuItem(value: FontWeight.w300, child: Text('얇게')),
        const DropdownMenuItem(value: FontWeight.normal, child: Text('보통')),
        const DropdownMenuItem(value: FontWeight.w500, child: Text('중간')),
        const DropdownMenuItem(value: FontWeight.bold, child: Text('굵게')),
        const DropdownMenuItem(value: FontWeight.w900, child: Text('더 굵게')),
      ],
      onChanged: (newValue) => newValue != null ? onChanged(newValue) : null,
    );
  }

  /// Text alignment selector
  static Widget buildTextAlignField({
    required TextAlign value,
    required Function(TextAlign) onChanged,
  }) {
    return buildDropdownField<TextAlign>(
      label: '텍스트 정렬',
      value: value,
      items: const [
        DropdownMenuItem(value: TextAlign.left, child: Text('왼쪽')),
        DropdownMenuItem(value: TextAlign.center, child: Text('가운데')),
        DropdownMenuItem(value: TextAlign.right, child: Text('오른쪽')),
      ],
      onChanged: (newValue) => newValue != null ? onChanged(newValue) : null,
    );
  }

  /// Box fit selector for images
  static Widget buildBoxFitField({
    required BoxFit value,
    required Function(BoxFit) onChanged,
  }) {
    return buildDropdownField<BoxFit>(
      label: '이미지 피팅',
      value: value,
      items: const [
        DropdownMenuItem(value: BoxFit.cover, child: Text('커버')),
        DropdownMenuItem(value: BoxFit.contain, child: Text('포함')),
        DropdownMenuItem(value: BoxFit.fill, child: Text('채우기')),
        DropdownMenuItem(value: BoxFit.fitWidth, child: Text('가로 맞춤')),
        DropdownMenuItem(value: BoxFit.fitHeight, child: Text('세로 맞춤')),
      ],
      onChanged: (newValue) => newValue != null ? onChanged(newValue) : null,
    );
  }

  /// Image asset selector
  static Widget buildAssetImageSelector({
    String? currentValue,
    required Function(String) onChanged,
  }) {
    const availableAssets = [
      'assets/images/gallery1.jpg',
      'assets/images/gallery2.jpg',
      'assets/images/gallery3.jpg',
      'assets/images/background.png',
      'assets/images/placeholder.png',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('기본 이미지 선택', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: availableAssets.contains(currentValue) ? currentValue : null,
          hint: const Text('기본 이미지 선택'),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: availableAssets.map((asset) {
            final name = asset.split('/').last.split('.').first;
            return DropdownMenuItem(
              value: asset,
              child: Text('$name 이미지'),
            );
          }).toList(),
          onChanged: (value) => value != null ? onChanged(value) : null,
        ),
      ],
    );
  }
}

/// Extension to show color picker dialog from any widget
extension ColorPickerDialog on BuildContext {
  void showColorPicker({
    required Color currentColor,
    required Function(Color) onColorChanged,
  }) {
    showDialog(
      context: this,
      builder: (context) {
        Color pickedColor = currentColor;
        return AlertDialog(
          title: const Text('색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => pickedColor = color,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                onColorChanged(pickedColor);
                Navigator.pop(context);
              },
              child: const Text('선택'),
            ),
          ],
        );
      },
    );
  }
}
