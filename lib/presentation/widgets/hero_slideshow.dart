import 'package:flutter/material.dart';
import 'dart:async';

class HeroSlideshow extends StatefulWidget {
  final List<String> images;
  final double height;
  final Duration slideDuration;
  final Duration transitionDuration;
  final Widget? overlay;
  final bool showIndicators;
  final bool autoPlay;

  const HeroSlideshow({
    super.key,
    required this.images,
    this.height = 400,
    this.slideDuration = const Duration(seconds: 4),
    this.transitionDuration = const Duration(milliseconds: 800),
    this.overlay,
    this.showIndicators = true,
    this.autoPlay = true,
  });

  @override
  State<HeroSlideshow> createState() => _HeroSlideshowState();
}

class _HeroSlideshowState extends State<HeroSlideshow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late Timer? _autoPlayTimer;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _overlayController;
  
  int _currentIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    
    // Animation controllers
    _fadeController = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Start animations
    _fadeController.forward();
    _overlayController.forward();
    _startKenBurnsEffect();
    
    // Auto play timer
    if (widget.autoPlay && widget.images.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(widget.slideDuration, (timer) {
      if (!_isAnimating && mounted) {
        _nextSlide();
      }
    });
  }

  void _startKenBurnsEffect() {
    _scaleController.repeat(reverse: true);
  }

  void _nextSlide() {
    if (widget.images.length <= 1) return;
    
    setState(() {
      _isAnimating = true;
    });
    
    final nextIndex = (_currentIndex + 1) % widget.images.length;
    
    _pageController
        .animateToPage(
          nextIndex,
          duration: widget.transitionDuration,
          curve: Curves.easeInOut,
        )
        .then((_) {
      if (mounted) {
        setState(() {
          _currentIndex = nextIndex;
          _isAnimating = false;
        });
      }
    });
  }

  void _previousSlide() {
    if (widget.images.length <= 1) return;
    
    setState(() {
      _isAnimating = true;
    });
    
    final prevIndex = (_currentIndex - 1 + widget.images.length) % widget.images.length;
    
    _pageController
        .animateToPage(
          prevIndex,
          duration: widget.transitionDuration,
          curve: Curves.easeInOut,
        )
        .then((_) {
      if (mounted) {
        setState(() {
          _currentIndex = prevIndex;
          _isAnimating = false;
        });
      }
    });
  }

  void _goToSlide(int index) {
    if (index == _currentIndex || _isAnimating) return;
    
    setState(() {
      _isAnimating = true;
    });
    
    _pageController
        .animateToPage(
          index,
          duration: widget.transitionDuration,
          curve: Curves.easeInOut,
        )
        .then((_) {
      if (mounted) {
        setState(() {
          _currentIndex = index;
          _isAnimating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade100,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.favorite,
            size: 80,
            color: Colors.white,
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Main slideshow
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildSlideItem(widget.images[index]);
            },
          ),
          
          // Overlay content
          if (widget.overlay != null)
            Positioned.fill(
              child: FadeTransition(
                opacity: _overlayController,
                child: widget.overlay!,
              ),
            ),
          
          // Navigation arrows (only show if more than 1 image)
          if (widget.images.length > 1) ...[
            // Previous button
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _previousSlide,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            
            // Next button
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _nextSlide,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
          
          // Page indicators
          if (widget.showIndicators && widget.images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.images.asMap().entries.map((entry) {
                  final index = entry.key;
                  final isActive = index == _currentIndex;
                  
                  return GestureDetector(
                    onTap: () => _goToSlide(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive 
                            ? Colors.white 
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlideItem(String imagePath) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        final scale = 1.0 + (_scaleController.value * 0.1);
        
        return Transform.scale(
          scale: scale,
          child: FadeTransition(
            opacity: _fadeController,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}