import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';

class AppleWatchGallery extends StatefulWidget {
  final List<String> imageUrls;
  final double size;
  
  const AppleWatchGallery({
    super.key,
    required this.imageUrls,
    this.size = 300,
  });

  @override
  State<AppleWatchGallery> createState() => _AppleWatchGalleryState();
}

class _AppleWatchGalleryState extends State<AppleWatchGallery>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.02, // Subtle rotation
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/gallery'),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  children: _buildCircularPhotos(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCircularPhotos() {
    final List<Widget> photos = [];
    final center = widget.size / 2;
    
    // Center photo (larger)
    if (widget.imageUrls.isNotEmpty) {
      photos.add(
        Positioned(
          left: center - 40,
          top: center - 40,
          child: _buildPhotoCircle(
            widget.imageUrls[0],
            80,
            isCenter: true,
          ),
        ),
      );
    }

    // Surrounding photos in circular pattern
    final radius = widget.size * 0.35;
    final surroundingPhotos = widget.imageUrls.skip(1).take(6).toList();
    
    for (int i = 0; i < surroundingPhotos.length; i++) {
      final angle = (i * 2 * math.pi / surroundingPhotos.length) - (math.pi / 2);
      final x = center + radius * math.cos(angle);
      final y = center + radius * math.sin(angle);
      
      photos.add(
        Positioned(
          left: x - 25,
          top: y - 25,
          child: _buildPhotoCircle(
            surroundingPhotos[i],
            50,
            delay: Duration(milliseconds: i * 200),
          ),
        ),
      );
    }

    // Outer ring of smaller photos
    if (widget.imageUrls.length > 7) {
      final outerRadius = widget.size * 0.45;
      final outerPhotos = widget.imageUrls.skip(7).take(8).toList();
      
      for (int i = 0; i < outerPhotos.length; i++) {
        final angle = (i * 2 * math.pi / outerPhotos.length) - (math.pi / 4);
        final x = center + outerRadius * math.cos(angle);
        final y = center + outerRadius * math.sin(angle);
        
        photos.add(
          Positioned(
            left: x - 15,
            top: y - 15,
            child: _buildPhotoCircle(
              outerPhotos[i],
              30,
              delay: Duration(milliseconds: (i + 6) * 200),
            ),
          ),
        );
      }
    }

    return photos;
  }

  Widget _buildPhotoCircle(
    String imageUrl,
    double size, {
    bool isCenter = false,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isCenter ? 0.3 : 0.2),
                  blurRadius: isCenter ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isCenter 
                    ? const Color(0xFFD4A574)
                    : Colors.white,
                width: isCenter ? 3 : 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
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
                      color: Colors.white,
                      size: size * 0.4,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// Alternative Honeycomb/Hexagon layout
class HoneycombGallery extends StatefulWidget {
  final List<String> imageUrls;
  final double size;
  
  const HoneycombGallery({
    super.key,
    required this.imageUrls,
    this.size = 300,
  });

  @override
  State<HoneycombGallery> createState() => _HoneycombGalleryState();
}

class _HoneycombGalleryState extends State<HoneycombGallery>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/gallery'),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          children: _buildHexagonPhotos(),
        ),
      ),
    );
  }

  List<Widget> _buildHexagonPhotos() {
    final List<Widget> photos = [];
    final center = widget.size / 2;
    final hexSize = 60.0;
    
    // Center hexagon
    if (widget.imageUrls.isNotEmpty) {
      photos.add(
        Positioned(
          left: center - hexSize / 2,
          top: center - hexSize / 2,
          child: _buildHexagonPhoto(
            widget.imageUrls[0],
            hexSize,
            isCenter: true,
          ),
        ),
      );
    }

    // First ring of hexagons
    final firstRingRadius = hexSize * 0.75;
    final firstRingPhotos = widget.imageUrls.skip(1).take(6).toList();
    
    for (int i = 0; i < firstRingPhotos.length; i++) {
      final angle = i * math.pi / 3;
      final x = center + firstRingRadius * math.cos(angle);
      final y = center + firstRingRadius * math.sin(angle);
      
      photos.add(
        Positioned(
          left: x - hexSize * 0.4 / 2,
          top: y - hexSize * 0.4 / 2,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final rotationOffset = _animationController.value * 2 * math.pi;
              return Transform.rotate(
                angle: rotationOffset + (i * math.pi / 3),
                child: _buildHexagonPhoto(
                  firstRingPhotos[i],
                  hexSize * 0.4,
                  delay: Duration(milliseconds: i * 150),
                ),
              );
            },
          ),
        ),
      );
    }

    return photos;
  }

  Widget _buildHexagonPhoto(
    String imageUrl,
    double size, {
    bool isCenter = false,
    Duration delay = Duration.zero,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000) + delay,
      curve: Curves.elasticOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: ClipPath(
            clipper: HexagonClipper(),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
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
                      color: Colors.white,
                      size: size * 0.4,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom clipper for hexagon shape
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    
    path.moveTo(width * 0.25, 0);
    path.lineTo(width * 0.75, 0);
    path.lineTo(width, height * 0.5);
    path.lineTo(width * 0.75, height);
    path.lineTo(width * 0.25, height);
    path.lineTo(0, height * 0.5);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}