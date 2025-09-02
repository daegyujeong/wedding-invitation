import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/utils/image_utils.dart';

class DynamicMasonryGallery extends StatefulWidget {
  final List<String> imageUrls;
  final Function(int index) onImageTap;
  final int numberOfRows;
  
  const DynamicMasonryGallery({
    super.key,
    required this.imageUrls,
    required this.onImageTap,
    this.numberOfRows = 2,
  });

  @override
  State<DynamicMasonryGallery> createState() => _DynamicMasonryGalleryState();
}

class _DynamicMasonryGalleryState extends State<DynamicMasonryGallery>
    with TickerProviderStateMixin {
  Map<String, double> _aspectRatios = {};
  bool _isLoading = true;
  late AnimationController _animationController;
  late List<AnimationController> _itemAnimationControllers;
  late List<Animation<double>> _itemAnimations;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadImageAspectRatios();
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Create individual animation controllers for each image
    _itemAnimationControllers = List.generate(
      widget.imageUrls.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 100)),
        vsync: this,
      ),
    );
    
    // Create staggered entrance animations
    _itemAnimations = _itemAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();
  }
  
  Future<void> _loadImageAspectRatios() async {
    try {
      final aspectRatios = await ImageUtils.getMultipleAssetImageAspectRatios(widget.imageUrls);
      if (mounted) {
        setState(() {
          _aspectRatios = aspectRatios;
          _isLoading = false;
        });
        
        // Start staggered animations
        for (int i = 0; i < _itemAnimationControllers.length; i++) {
          Future.delayed(Duration(milliseconds: i * 150), () {
            if (mounted) {
              _itemAnimationControllers[i].forward();
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading aspect ratios: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _itemAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.purple.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                '사진을 불러오는 중...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildDynamicMasonryLayout();
  }
  
  Widget _buildDynamicMasonryLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
    const padding = 16.0;
    final availableWidth = screenWidth - (padding * 2);
    
    // Distribute images across rows based on their aspect ratios
    final rows = _distributeImagesIntoRows();
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final rowIndex = entry.key;
          final rowImages = entry.value;
          
          return Padding(
            padding: EdgeInsets.only(bottom: rowIndex < rows.length - 1 ? 12.0 : 0),
            child: _buildRow(rowImages, availableWidth),
          );
        }).toList(),
      ),
    );
  }
  
  List<List<ImageData>> _distributeImagesIntoRows() {
    final List<List<ImageData>> rows = List.generate(widget.numberOfRows, (_) => []);
    final List<double> rowWidths = List.generate(widget.numberOfRows, (_) => 0.0);
    
    // Convert images to ImageData with aspect ratios
    final imageDataList = widget.imageUrls.asMap().entries.map((entry) {
      final index = entry.key;
      final url = entry.value;
      final aspectRatio = _aspectRatios[url] ?? 1.0;
      
      return ImageData(
        url: url,
        index: index,
        aspectRatio: aspectRatio,
      );
    }).toList();
    
    // Sort by aspect ratio for better distribution
    imageDataList.sort((a, b) => b.aspectRatio.compareTo(a.aspectRatio));
    
    // Distribute images to rows, trying to balance row widths
    for (final imageData in imageDataList) {
      // Find the row with minimum current width
      int targetRowIndex = 0;
      double minWidth = rowWidths[0];
      
      for (int i = 1; i < rowWidths.length; i++) {
        if (rowWidths[i] < minWidth) {
          minWidth = rowWidths[i];
          targetRowIndex = i;
        }
      }
      
      rows[targetRowIndex].add(imageData);
      // Add to row width (normalized width based on aspect ratio)
      rowWidths[targetRowIndex] += imageData.aspectRatio * 200; // Base width of 200
    }
    
    return rows;
  }
  
  Widget _buildRow(List<ImageData> rowImages, double availableWidth) {
    if (rowImages.isEmpty) return const SizedBox.shrink();
    
    // Calculate total aspect ratio for this row
    final totalAspectRatio = rowImages.fold<double>(
      0.0, 
      (sum, imageData) => sum + imageData.aspectRatio,
    );
    
    const spacing = 8.0;
    final totalSpacing = (rowImages.length - 1) * spacing;
    final availableWidthForImages = availableWidth - totalSpacing;
    
    return Row(
      children: rowImages.asMap().entries.map((entry) {
        final index = entry.key;
        final imageData = entry.value;
        
        // Calculate width based on proportional aspect ratio
        final proportionalWidth = (imageData.aspectRatio / totalAspectRatio) * availableWidthForImages;
        final height = proportionalWidth / imageData.aspectRatio;
        
        return Expanded(
          flex: (imageData.aspectRatio * 100).round(),
          child: Padding(
            padding: EdgeInsets.only(right: index < rowImages.length - 1 ? spacing : 0),
            child: _buildAnimatedImageItem(imageData, proportionalWidth, height),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildAnimatedImageItem(ImageData imageData, double width, double height) {
    final animationIndex = imageData.index.clamp(0, _itemAnimations.length - 1);
    
    return AnimatedBuilder(
      animation: _itemAnimations[animationIndex],
      builder: (context, child) {
        final animationValue = _itemAnimations[animationIndex].value;
        
        return Transform.scale(
          scale: animationValue,
          child: Transform.translate(
            offset: Offset(0, (1 - animationValue) * 50),
            child: Opacity(
              opacity: animationValue,
              child: _buildImageCard(imageData, width, height),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildImageCard(ImageData imageData, double width, double height) {
    return GestureDetector(
      onTap: () => widget.onImageTap(imageData.index),
      child: Hero(
        tag: 'photo_${imageData.index}',
        child: Container(
          width: width,
          height: math.max(height, 120), // Minimum height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imageData.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade100,
                            Colors.purple.shade200,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 32,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Image not found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                // Gradient overlay for better text visibility
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                ),
                
                // Photo number overlay
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${imageData.index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Hover/press effect
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => widget.onImageTap(imageData.index),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Data class to hold image information
class ImageData {
  final String url;
  final int index;
  final double aspectRatio;
  
  const ImageData({
    required this.url,
    required this.index,
    required this.aspectRatio,
  });
}