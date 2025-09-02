import 'package:flutter/material.dart';
import 'dart:async';

class FloatingMusicPlayer extends StatefulWidget {
  final List<WeddingSong> playlist;
  final bool autoPlay;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const FloatingMusicPlayer({
    super.key,
    required this.playlist,
    this.autoPlay = true,
    this.size = 60,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<FloatingMusicPlayer> createState() => _FloatingMusicPlayerState();
}

class _FloatingMusicPlayerState extends State<FloatingMusicPlayer>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isExpanded = false;
  int _currentSongIndex = 0;
  Timer? _progressTimer;
  Duration _currentPosition = Duration.zero;
  
  late AnimationController _rotationController;
  late AnimationController _expandController;
  late AnimationController _pulseController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Create animations
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Auto-play if enabled
    if (widget.autoPlay && widget.playlist.isNotEmpty) {
      _startPlayback();
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _rotationController.dispose();
    _expandController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startPlayback() {
    setState(() {
      _isPlaying = true;
    });
    
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    
    // Simulate song playback progress
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying && mounted) {
        setState(() {
          _currentPosition = Duration(seconds: _currentPosition.inSeconds + 1);
          
          // Auto-advance to next song when current ends
          if (_currentPosition >= currentSong.duration) {
            _nextSong();
          }
        });
      }
    });
  }

  void _pausePlayback() {
    setState(() {
      _isPlaying = false;
    });
    
    _rotationController.stop();
    _pulseController.stop();
    _progressTimer?.cancel();
  }

  void _nextSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex + 1) % widget.playlist.length;
      _currentPosition = Duration.zero;
    });
  }

  void _previousSong() {
    setState(() {
      _currentSongIndex = (_currentSongIndex - 1 + widget.playlist.length) % widget.playlist.length;
      _currentPosition = Duration.zero;
    });
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  WeddingSong get currentSong => widget.playlist[_currentSongIndex];

  @override
  Widget build(BuildContext context) {
    if (widget.playlist.isEmpty) {
      return const SizedBox();
    }

    return Positioned(
      right: 20,
      bottom: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Expanded player
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _expandAnimation.value,
                alignment: Alignment.bottomCenter,
                child: _expandAnimation.value > 0.1 ? _buildExpandedPlayer() : const SizedBox(),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Main floating button
          _buildFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: _isExpanded ? _toggleExpansion : null,
      onLongPress: _isExpanded ? null : _toggleExpansion,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPlaying ? _pulseAnimation.value : 1.0,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.pink.shade400,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  if (_isPlaying)
                    BoxShadow(
                      color: (widget.backgroundColor ?? Colors.pink.shade400).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating music note background
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(
                      Icons.music_note,
                      color: (widget.iconColor ?? Colors.white).withOpacity(0.3),
                      size: widget.size * 0.4,
                    ),
                  ),
                  
                  // Play/Pause button
                  GestureDetector(
                    onTap: () {
                      if (_isPlaying) {
                        _pausePlayback();
                      } else {
                        _startPlayback();
                      }
                    },
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: widget.iconColor ?? Colors.white,
                      size: widget.size * 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedPlayer() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          Row(
            children: [
              Icon(
                Icons.music_note,
                color: Colors.pink.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '결혼식 BGM',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: _toggleExpansion,
                color: Colors.grey.shade600,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Current song info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentSong.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  currentSong.artist,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar
          Column(
            children: [
              LinearProgressIndicator(
                value: currentSong.duration.inSeconds > 0
                    ? _currentPosition.inSeconds / currentSong.duration.inSeconds
                    : 0.0,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_currentPosition),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    _formatDuration(currentSong.duration),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: _previousSong,
                color: Colors.grey.shade700,
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
                onPressed: () {
                  if (_isPlaying) {
                    _pausePlayback();
                  } else {
                    _startPlayback();
                  }
                },
                color: Colors.pink.shade400,
                iconSize: 48,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: _nextSong,
                color: Colors.grey.shade700,
              ),
            ],
          ),
          
          // Playlist info
          if (widget.playlist.length > 1) ...[
            const SizedBox(height: 8),
            Text(
              '${_currentSongIndex + 1} / ${widget.playlist.length}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class WeddingSong {
  final String title;
  final String artist;
  final Duration duration;
  final String? audioUrl;

  WeddingSong({
    required this.title,
    required this.artist,
    required this.duration,
    this.audioUrl,
  });
}