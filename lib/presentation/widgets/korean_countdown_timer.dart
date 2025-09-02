import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class KoreanCountdownTimer extends StatefulWidget {
  final DateTime targetDate;
  final TextStyle? titleStyle;
  final TextStyle? numberStyle;
  final TextStyle? labelStyle;
  final Color? backgroundColor;
  final Color? cardColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool showTitle;
  final String title;
  final bool animate;

  const KoreanCountdownTimer({
    super.key,
    required this.targetDate,
    this.titleStyle,
    this.numberStyle,
    this.labelStyle,
    this.backgroundColor,
    this.cardColor,
    this.padding,
    this.borderRadius,
    this.showTitle = true,
    this.title = '결혼식까지',
    this.animate = true,
  });

  @override
  State<KoreanCountdownTimer> createState() => _KoreanCountdownTimerState();
}

class _KoreanCountdownTimerState extends State<KoreanCountdownTimer>
    with TickerProviderStateMixin {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _colorController;
  
  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _colorController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Create animations
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _colorAnimation = ColorTween(
      begin: Colors.pink.shade400,
      end: Colors.red.shade400,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations if enabled
    if (widget.animate) {
      _scaleController.forward();
      _pulseController.repeat(reverse: true);
      _rotationController.repeat();
      _colorController.repeat(reverse: true);
    } else {
      _scaleController.value = 1.0;
    }
    
    // Calculate initial time
    _updateTimeRemaining();
    
    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeRemaining();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final difference = widget.targetDate.difference(now);
    
    if (mounted) {
      setState(() {
        _timeRemaining = difference.isNegative ? Duration.zero : difference;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;
    
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.backgroundColor ?? Colors.pink.shade50,
                  widget.backgroundColor?.withOpacity(0.8) ?? Colors.pink.shade100,
                ],
              ),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title with heart animation
                if (widget.showTitle)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.animate)
                        AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: AnimatedBuilder(
                                animation: _colorAnimation,
                                builder: (context, child) {
                                  return Icon(
                                    Icons.favorite,
                                    color: _colorAnimation.value,
                                    size: 24,
                                  );
                                },
                              ),
                            );
                          },
                        )
                      else
                        Icon(
                          Icons.favorite,
                          color: Colors.pink.shade400,
                          size: 24,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        widget.title,
                        style: widget.titleStyle ?? 
                          theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade700,
                          ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.animate)
                        AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: -_rotationAnimation.value,
                              child: AnimatedBuilder(
                                animation: _colorAnimation,
                                builder: (context, child) {
                                  return Icon(
                                    Icons.favorite,
                                    color: _colorAnimation.value,
                                    size: 24,
                                  );
                                },
                              ),
                            );
                          },
                        )
                      else
                        Icon(
                          Icons.favorite,
                          color: Colors.pink.shade400,
                          size: 24,
                        ),
                    ],
                  ),
                
                if (widget.showTitle) const SizedBox(height: 16),
                
                // Countdown numbers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTimeUnit(days, '일', Icons.calendar_today),
                    _buildSeparator(),
                    _buildTimeUnit(hours, '시간', Icons.access_time),
                    _buildSeparator(),
                    _buildTimeUnit(minutes, '분', Icons.timer),
                    _buildSeparator(),
                    _buildTimeUnit(seconds, '초', Icons.timer_10),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Special message based on time remaining
                _buildSpecialMessage(days),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeUnit(int value, String label, IconData icon) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Icon(
            icon,
            size: 16,
            color: Colors.pink.shade600,
          ),
          const SizedBox(height: 4),
          
          // Number container
          AnimatedBuilder(
            animation: widget.animate ? _pulseAnimation : 
                const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              return Transform.scale(
                scale: widget.animate ? _pulseAnimation.value : 1.0,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 50,
                    minHeight: 50,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.cardColor ?? Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.pink.shade200,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    value.toString().padLeft(2, '0'),
                    style: widget.numberStyle ?? 
                      TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade700,
                      ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // Label
          Text(
            label,
            style: widget.labelStyle ?? 
              TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.pink.shade600,
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.pink.shade400,
        ),
      ),
    );
  }

  Widget _buildSpecialMessage(int daysRemaining) {
    List<TextSpan> messageSpans;
    IconData messageIcon;
    Color messageColor;
    
    if (daysRemaining <= 0) {
      messageSpans = [
        _buildEmojiSpan('🎉'),
        _buildTextSpan(' 오늘이 바로 그 날입니다! '),
        _buildEmojiSpan('🎉'),
      ];
      messageIcon = Icons.celebration;
      messageColor = Colors.red.shade600;
    } else if (daysRemaining <= 7) {
      messageSpans = [
        _buildEmojiSpan('💕'),
        _buildTextSpan(' 일주일도 남지 않았어요! '),
        _buildEmojiSpan('💕'),
      ];
      messageIcon = Icons.favorite;
      messageColor = Colors.pink.shade600;
    } else if (daysRemaining <= 30) {
      messageSpans = [
        _buildEmojiSpan('✨'),
        _buildTextSpan(' 한 달도 채 남지 않았네요! '),
        _buildEmojiSpan('✨'),
      ];
      messageIcon = Icons.auto_awesome;
      messageColor = Colors.purple.shade600;
    } else if (daysRemaining <= 100) {
      messageSpans = [
        _buildEmojiSpan('🌸'),
        _buildTextSpan(' 100일도 남지 않았어요! '),
        _buildEmojiSpan('🌸'),
      ];
      messageIcon = Icons.local_florist;
      messageColor = Colors.pink.shade500;
    } else {
      messageSpans = [
        _buildEmojiSpan('💖'),
        _buildTextSpan(' 소중한 날을 기다리고 있어요 '),
        _buildEmojiSpan('💖'),
      ];
      messageIcon = Icons.favorite_outline;
      messageColor = Colors.pink.shade400;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: messageColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: messageColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            messageIcon,
            color: messageColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: messageSpans.map((span) => TextSpan(
                  text: span.text,
                  style: span.style?.copyWith(color: messageColor) ?? TextStyle(
                    color: messageColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build emoji TextSpan with proper font fallbacks
  TextSpan _buildEmojiSpan(String emoji) {
    return TextSpan(
      text: emoji,
      style: const TextStyle(
        fontFamily: 'Noto Color Emoji',
        fontFamilyFallback: [
          'Apple Color Emoji',
          'Segoe UI Emoji',
          'Segoe UI Symbol',
          'Symbola',
        ],
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Helper method to build regular text TextSpan
  TextSpan _buildTextSpan(String text) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}