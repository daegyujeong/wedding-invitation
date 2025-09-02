import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import '../../data/utils/image_utils.dart';

class AutoScrollGalleryPreview extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final double minItemHeight;
  final double maxItemHeight;
  
  const AutoScrollGalleryPreview({
    super.key,
    required this.imageUrls,
    this.height = 400,
    this.minItemHeight = 120,
    this.maxItemHeight = 200,
  });

  @override
  State<AutoScrollGalleryPreview> createState() => _AutoScrollGalleryPreviewState();
}

class _AutoScrollGalleryPreviewState extends State<AutoScrollGalleryPreview>
    with TickerProviderStateMixin {
  late ScrollController _topRowController;
  late ScrollController _bottomRowController;
  late Timer _scrollTimer;
  Map<String, double> _aspectRatios = {};
  bool _isLoading = true;
  
  // Animation controllers for entrance effects
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadImageAspectRatios();
    _initializeAnimations();
  }
  
  void _initializeControllers() {
    _topRowController = ScrollController();
    _bottomRowController = ScrollController();
  }
  
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }
  
  Future<void> _loadImageAspectRatios() async {
    try {
      final aspectRatios = await ImageUtils.getMultipleAssetImageAspectRatios(widget.imageUrls);
      if (mounted) {
        setState(() {
          _aspectRatios = aspectRatios;
          _isLoading = false;
        });
        _fadeController.forward();
        _startAutoScroll();
      }
    } catch (e) {
      debugPrint('Error loading aspect ratios: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward();
        _startAutoScroll();
      }
    }
  }
  
  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Scroll top row to the right
      if (_topRowController.hasClients) {
        final currentOffset = _topRowController.offset;
        final maxOffset = _topRowController.position.maxScrollExtent;
        
        if (currentOffset >= maxOffset) {
          // Reset to beginning for infinite scroll
          _topRowController.jumpTo(0);
        } else {
          _topRowController.animateTo(
            currentOffset + 1.0,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
      
      // Scroll bottom row to the left (opposite direction)
      if (_bottomRowController.hasClients) {
        final currentOffset = _bottomRowController.offset;
        
        if (currentOffset <= 0) {
          // Jump to end for infinite scroll
          _bottomRowController.jumpTo(_bottomRowController.position.maxScrollExtent);
        } else {
          _bottomRowController.animateTo(
            currentOffset - 1.0,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
  }
  
  @override
  void dispose() {
    _scrollTimer.cancel();
    _topRowController.dispose();
    _bottomRowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFFD4A574),
              ),
              const SizedBox(height: 16),
              const Text(
                '사진을 불러오는 중...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () => context.push('/gallery'),
        child: SizedBox(
          height: widget.height,
          child: Column(
            children: [
              // Top row - scrolling right
              Expanded(
                child: _buildScrollingRow(
                  controller: _topRowController,
                  images: _getTopRowImages(),
                  reverse: false,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Bottom row - scrolling left
              Expanded(
                child: _buildScrollingRow(
                  controller: _bottomRowController,
                  images: _getBottomRowImages(),
                  reverse: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  List<String> _getTopRowImages() {
    // Take first half + duplicate for infinite scroll
    final halfLength = (widget.imageUrls.length / 2).ceil();
    final topImages = widget.imageUrls.take(halfLength).toList();
    return [...topImages, ...topImages, ...topImages]; // Triple for smooth infinite scroll
  }
  
  List<String> _getBottomRowImages() {
    // Take second half + duplicate for infinite scroll
    final halfLength = (widget.imageUrls.length / 2).ceil();
    final bottomImages = widget.imageUrls.skip(halfLength).toList();
    return [...bottomImages, ...bottomImages, ...bottomImages]; // Triple for smooth infinite scroll
  }
  
  Widget _buildScrollingRow({
    required ScrollController controller,
    required List<String> images,
    required bool reverse,
  }) {
    return SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(), // Disable user interaction
      child: Row(
        children: images.asMap().entries.map((entry) {
          final index = entry.key;
          final imageUrl = entry.value;
          
          return Padding(
            padding: EdgeInsets.only(
              right: index < images.length - 1 ? 12.0 : 0,
            ),
            child: _buildImageItem(imageUrl, index),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildImageItem(String imageUrl, int index) {
    final aspectRatio = _aspectRatios[imageUrl] ?? 1.0;
    
    // Calculate dynamic height based on aspect ratio
    final baseHeight = widget.minItemHeight + 
        (widget.maxItemHeight - widget.minItemHeight) * 
        math.Random(index).nextDouble();
    
    final width = baseHeight * aspectRatio;
    
    return Container(
      width: width,
      height: baseHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
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
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD4A574).withOpacity(0.3),
                        const Color(0xFFD4A574).withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.photo,
                    color: Colors.white.withOpacity(0.7),
                    size: width * 0.3,
                  ),
                );
              },
            ),
            
            // Subtle gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                  stops: const [0.8, 1.0],
                ),
              ),
            ),
            
            // Hover effect overlay
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/gallery'),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative implementation with more CSS-like continuous scrolling
class CSSStyleAutoScrollGallery extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  
  const CSSStyleAutoScrollGallery({
    super.key,
    required this.imageUrls,
    this.height = 400,
  });

  @override
  State<CSSStyleAutoScrollGallery> createState() => _CSSStyleAutoScrollGalleryState();
}

class _CSSStyleAutoScrollGalleryState extends State<CSSStyleAutoScrollGallery>
    with TickerProviderStateMixin {
  late AnimationController _topRowController;
  late AnimationController _bottomRowController;
  Map<String, double> _aspectRatios = {};
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadImageAspectRatios();
  }
  
  void _initializeAnimations() {
    // Top row - right to left, 30 seconds per cycle
    _topRowController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    // Bottom row - left to right, 25 seconds per cycle (different speed)
    _bottomRowController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
  }
  
  Future<void> _loadImageAspectRatios() async {
    try {
      final aspectRatios = await ImageUtils.getMultipleAssetImageAspectRatios(widget.imageUrls);
      if (mounted) {
        setState(() {
          _aspectRatios = aspectRatios;
          _isLoading = false;
        });
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
    _topRowController.dispose();
    _bottomRowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFFD4A574),
              ),
              const SizedBox(height: 16),
              const Text(
                '사진을 불러오는 중...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => context.push('/gallery'),
      child: SizedBox(
        height: widget.height,
        child: Column(
          children: [
            // Top row
            Expanded(
              child: _buildCSSRow(
                controller: _topRowController,
                images: _getTopRowImages(),
                reverse: false,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Bottom row
            Expanded(
              child: _buildCSSRow(
                controller: _bottomRowController,
                images: _getBottomRowImages(),
                reverse: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<String> _getTopRowImages() {
    final halfLength = (widget.imageUrls.length / 2).ceil();
    final topImages = widget.imageUrls.take(halfLength).toList();
    return topImages;
  }
  
  List<String> _getBottomRowImages() {
    final halfLength = (widget.imageUrls.length / 2).ceil();
    final bottomImages = widget.imageUrls.skip(halfLength).toList();
    return bottomImages;
  }
  
  Widget _buildCSSRow({
    required AnimationController controller,
    required List<String> images,
    required bool reverse,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final totalWidth = _calculateTotalWidth(images);
        
        // Calculate animation offset
        final animationValue = reverse ? (1 - controller.value) : controller.value;
        final offset = -animationValue * totalWidth;
        
        return ClipRect(
          child: Transform.translate(
            offset: Offset(offset, 0),
            child: Row(
              children: [
                ..._buildImageRow(images),
                // Duplicate row for seamless loop
                ..._buildImageRow(images),
              ],
            ),
          ),
        );
      },
    );
  }
  
  List<Widget> _buildImageRow(List<String> images) {
    return images.map((imageUrl) {
      final aspectRatio = _aspectRatios[imageUrl] ?? 1.0;
      
      // Vary heights based on aspect ratio and some randomness
      final baseHeight = 120 + (80 * aspectRatio).clamp(0, 80).toDouble();
      final width = baseHeight * aspectRatio;
      
      return Container(
        width: width,
        height: baseHeight,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
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
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD4A574).withOpacity(0.3),
                          const Color(0xFFD4A574).withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      Icons.photo,
                      color: Colors.white.withOpacity(0.7),
                      size: width * 0.3,
                    ),
                  );
                },
              ),
              
              // Subtle overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                    ],
                    stops: const [0.8, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
  
  double _calculateTotalWidth(List<String> images) {
    double totalWidth = 0;
    for (final imageUrl in images) {
      final aspectRatio = _aspectRatios[imageUrl] ?? 1.0;
      final baseHeight = 120 + (80 * aspectRatio).clamp(0, 80).toDouble();
      final width = baseHeight * aspectRatio;
      totalWidth += width + 12; // Include margin
    }
    return totalWidth;
  }
}