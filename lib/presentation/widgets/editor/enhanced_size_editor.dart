import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedSizeEditor extends StatefulWidget {
  final double width;
  final double height;
  final Function(double width, double height) onSizeChanged;
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;
  final bool showRatioControls;
  final bool showPresets;

  const EnhancedSizeEditor({
    super.key,
    required this.width,
    required this.height,
    required this.onSizeChanged,
    this.minWidth = 50,
    this.maxWidth = 400,
    this.minHeight = 50,
    this.maxHeight = 400,
    this.showRatioControls = true,
    this.showPresets = true,
  });

  @override
  State<EnhancedSizeEditor> createState() => _EnhancedSizeEditorState();
}

class _EnhancedSizeEditorState extends State<EnhancedSizeEditor> {
  late double _width;
  late double _height;
  bool _maintainAspectRatio = false;
  double? _originalRatio;
  String _sizeMode = 'manual'; // manual, ratio, preset, responsive

  final Map<String, double> _ratioPresets = {
    '1:1 (정사각형)': 1.0,
    '4:3 (표준)': 4.0 / 3.0,
    '16:9 (와이드)': 16.0 / 9.0,
    '3:2 (사진)': 3.0 / 2.0,
    '2:1 (배너)': 2.0 / 1.0,
    '3:4 (세로)': 3.0 / 4.0,
    '9:16 (세로 와이드)': 9.0 / 16.0,
  };

  final Map<String, Map<String, double>> _sizePresets = {
    '작게 (소형)': {'width': 150, 'height': 100},
    '보통 (중형)': {'width': 250, 'height': 150},
    '크게 (대형)': {'width': 350, 'height': 200},
    '전체폭 (좁음)': {'width': 380, 'height': 80},
    '전체폭 (보통)': {'width': 380, 'height': 150},
    '전체폭 (높음)': {'width': 380, 'height': 250},
  };

  @override
  void initState() {
    super.initState();
    _width = widget.width;
    _height = widget.height;
    _originalRatio = _width / _height;
  }

  void _updateSize(double newWidth, double newHeight) {
    setState(() {
      _width = newWidth.clamp(widget.minWidth, widget.maxWidth);
      _height = newHeight.clamp(widget.minHeight, widget.maxHeight);
    });
    widget.onSizeChanged(_width, _height);
  }

  void _applyRatio(double ratio) {
    if (_width > 0) {
      double newHeight = _width / ratio;
      if (newHeight > widget.maxHeight) {
        newHeight = widget.maxHeight;
        _width = newHeight * ratio;
      }
      _updateSize(_width, newHeight);
    }
  }

  void _applyPreset(Map<String, double> preset) {
    _updateSize(preset['width']!, preset['height']!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Size Mode Selector
        const Text(
          '크기 설정 방식',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            const ButtonSegment(
              value: 'manual',
              label: Text('수동'),
              icon: Icon(Icons.tune),
            ),
            if (widget.showRatioControls)
              const ButtonSegment(
                value: 'ratio',
                label: Text('비율'),
                icon: Icon(Icons.aspect_ratio),
              ),
            if (widget.showPresets)
              const ButtonSegment(
                value: 'preset',
                label: Text('프리셋'),
                icon: Icon(Icons.photo_size_select_large),
              ),
            const ButtonSegment(
              value: 'responsive',
              label: Text('반응형'),
              icon: Icon(Icons.devices),
            ),
          ],
          selected: {_sizeMode},
          onSelectionChanged: (Set<String> selection) {
            setState(() {
              _sizeMode = selection.first;
            });
          },
        ),
        const SizedBox(height: 16),

        // Current Size Display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 8),
              Text(
                '현재 크기: ${_width.toInt()} × ${_height.toInt()}px',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                '비율: ${(_width / _height).toStringAsFixed(2)}:1',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Size Controls based on mode
        if (_sizeMode == 'manual') _buildManualControls(),
        if (_sizeMode == 'ratio') _buildRatioControls(),
        if (_sizeMode == 'preset') _buildPresetControls(),
        if (_sizeMode == 'responsive') _buildResponsiveControls(),
      ],
    );
  }

  Widget _buildManualControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aspect Ratio Lock
        SwitchListTile(
          title: const Text('비율 고정'),
          subtitle: Text(_maintainAspectRatio
              ? '가로/세로 비율이 고정됩니다'
              : '가로와 세로를 독립적으로 조정할 수 있습니다'),
          value: _maintainAspectRatio,
          onChanged: (value) {
            setState(() {
              _maintainAspectRatio = value;
              if (value) {
                _originalRatio = _width / _height;
              }
            });
          },
        ),
        const SizedBox(height: 16),

        // Width Control
        const Text('너비'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Slider(
                value: _width,
                min: widget.minWidth,
                max: widget.maxWidth,
                divisions: ((widget.maxWidth - widget.minWidth) / 10).round(),
                label: _width.round().toString(),
                onChanged: (value) {
                  if (_maintainAspectRatio && _originalRatio != null) {
                    double newHeight = value / _originalRatio!;
                    _updateSize(value, newHeight);
                  } else {
                    _updateSize(value, _height);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextFormField(
                initialValue: _width.round().toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (value) {
                  double? newWidth = double.tryParse(value);
                  if (newWidth != null) {
                    if (_maintainAspectRatio && _originalRatio != null) {
                      double newHeight = newWidth / _originalRatio!;
                      _updateSize(newWidth, newHeight);
                    } else {
                      _updateSize(newWidth, _height);
                    }
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Height Control
        const Text('높이'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Slider(
                value: _height,
                min: widget.minHeight,
                max: widget.maxHeight,
                divisions: ((widget.maxHeight - widget.minHeight) / 10).round(),
                label: _height.round().toString(),
                onChanged: (value) {
                  if (_maintainAspectRatio && _originalRatio != null) {
                    double newWidth = value * _originalRatio!;
                    _updateSize(newWidth, value);
                  } else {
                    _updateSize(_width, value);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextFormField(
                initialValue: _height.round().toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (value) {
                  double? newHeight = double.tryParse(value);
                  if (newHeight != null) {
                    if (_maintainAspectRatio && _originalRatio != null) {
                      double newWidth = newHeight * _originalRatio!;
                      _updateSize(newWidth, newHeight);
                    } else {
                      _updateSize(_width, newHeight);
                    }
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatioControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '비율 선택',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _ratioPresets.entries.map((entry) {
            bool isSelected = (_width / _height - entry.value).abs() < 0.01;
            return FilterChip(
              label: Text(entry.key),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _applyRatio(entry.value);
                }
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Custom ratio input
        const Text('사용자 정의 비율'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: '가로',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onFieldSubmitted: (value) {
                  // Handle custom ratio input
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(':',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: '세로',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: TextInputType.number,
                onFieldSubmitted: (value) {
                  // Handle custom ratio input
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Width slider for ratio mode
        const Text('크기 조정'),
        const SizedBox(height: 8),
        Slider(
          value: _width,
          min: widget.minWidth,
          max: widget.maxWidth,
          divisions: ((widget.maxWidth - widget.minWidth) / 10).round(),
          label: '${_width.round()} × ${_height.round()}',
          onChanged: (value) {
            double currentRatio = _width / _height;
            double newHeight = value / currentRatio;
            _updateSize(value, newHeight);
          },
        ),
      ],
    );
  }

  Widget _buildPresetControls() {
    // Get screen dimensions for responsive presets
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.9; // 90% of screen width
    final maxHeight = screenSize.height * 0.7; // 70% of screen height

    // Responsive presets based on screen size
    final Map<String, Map<String, double>> responsivePresets = {
      '화면 너비 25%': {'width': maxWidth * 0.25, 'height': maxWidth * 0.25 * 0.6},
      '화면 너비 50%': {'width': maxWidth * 0.5, 'height': maxWidth * 0.5 * 0.6},
      '화면 너비 75%': {'width': maxWidth * 0.75, 'height': maxWidth * 0.75 * 0.6},
      '화면 너비 100%': {'width': maxWidth, 'height': maxHeight * 0.4},
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '크기 프리셋',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // Fixed size presets
        const Text(
          '고정 크기',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 120, // Fixed height to prevent viewport issues
          child: GridView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3,
            ),
            itemCount: _sizePresets.length,
            itemBuilder: (context, index) {
              String key = _sizePresets.keys.elementAt(index);
              Map<String, double> preset = _sizePresets[key]!;
              bool isSelected = (_width - preset['width']!).abs() < 1 &&
                  (_height - preset['height']!).abs() < 1;

              return OutlinedButton(
                onPressed: () => _applyPreset(preset),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      key,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${preset['width']!.toInt()} × ${preset['height']!.toInt()}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Responsive presets
        const Text(
          '반응형 크기 (화면 기준)',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 120, // Fixed height to prevent viewport issues
          child: GridView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3,
            ),
            itemCount: responsivePresets.length,
            itemBuilder: (context, index) {
              String key = responsivePresets.keys.elementAt(index);
              Map<String, double> preset = responsivePresets[key]!;
              bool isSelected = (_width - preset['width']!).abs() < 5 &&
                  (_height - preset['height']!).abs() <
                      5; // Looser match for responsive

              return OutlinedButton(
                onPressed: () => _applyPreset(preset),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      key,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${preset['width']!.toInt()} × ${preset['height']!.toInt()}',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Screen info display
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '화면 크기: ${screenSize.width.toInt()} × ${screenSize.height.toInt()}px',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveControls() {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Calculate percentage of current size relative to screen
    final widthPercentage = (_width / screenWidth * 100).clamp(0.0, 100.0);
    final heightPercentage = (_height / screenHeight * 100).clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current responsive info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.monitor, size: 16, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '화면 대비 비율',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '너비: ${widthPercentage.toStringAsFixed(1)}% (${_width.toInt()}px / ${screenWidth.toInt()}px)',
                style: TextStyle(fontSize: 12, color: Colors.green.shade600),
              ),
              Text(
                '높이: ${heightPercentage.toStringAsFixed(1)}% (${_height.toInt()}px / ${screenHeight.toInt()}px)',
                style: TextStyle(fontSize: 12, color: Colors.green.shade600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Screen width percentage control
        const Text('화면 너비 대비 크기'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: widthPercentage,
                min: 5,
                max: 100,
                divisions: 19,
                label: '${widthPercentage.toStringAsFixed(1)}%',
                onChanged: (value) {
                  final newWidth = (screenWidth * value / 100)
                      .clamp(widget.minWidth, widget.maxWidth);
                  _updateSize(newWidth, _height);
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Text(
                '${widthPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Screen height percentage control
        const Text('화면 높이 대비 크기'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: heightPercentage,
                min: 5,
                max: 100,
                divisions: 19,
                label: '${heightPercentage.toStringAsFixed(1)}%',
                onChanged: (value) {
                  final newHeight = (screenHeight * value / 100)
                      .clamp(widget.minHeight, widget.maxHeight);
                  _updateSize(_width, newHeight);
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: Text(
                '${heightPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Quick responsive presets
        const Text('빠른 반응형 설정'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildResponsiveChip('모바일 (90%)', 90, 40),
            _buildResponsiveChip('태블릿 (70%)', 70, 50),
            _buildResponsiveChip('데스크톱 (50%)', 50, 60),
            _buildResponsiveChip('전체화면 (95%)', 95, 80),
          ],
        ),
        const SizedBox(height: 16),

        // Device breakpoint info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, size: 16),
                  SizedBox(width: 8),
                  Text(
                    '디바이스 가이드',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getDeviceTypeInfo(screenWidth),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveChip(
      String label, double widthPercent, double heightPercent) {
    final screenSize = MediaQuery.of(context).size;
    final targetWidth = screenSize.width * widthPercent / 100;
    final targetHeight = screenSize.height * heightPercent / 100;

    final isSelected = (_width - targetWidth).abs() < 20 &&
        (_height - targetHeight).abs() < 20;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _updateSize(
            targetWidth.clamp(widget.minWidth, widget.maxWidth),
            targetHeight.clamp(widget.minHeight, widget.maxHeight),
          );
        }
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }

  String _getDeviceTypeInfo(double width) {
    if (width < 600) {
      return '모바일 (${width.toInt()}px) - 작은 화면에 적합한 크기를 선택하세요.';
    } else if (width < 1200) {
      return '태블릿 (${width.toInt()}px) - 중간 크기 화면에 적합합니다.';
    } else {
      return '데스크톱 (${width.toInt()}px) - 큰 화면에서 여유로운 크기를 활용하세요.';
    }
  }
}
