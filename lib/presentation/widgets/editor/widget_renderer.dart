import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/editor_widget_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';

class WidgetRenderer extends StatelessWidget {
  final EditorWidget widget;

  const WidgetRenderer({
    super.key,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case WidgetType.Text:
        return _buildTextWidget(widget as TextWidget);
      case WidgetType.DDay:
        return _buildDDayWidget(widget as DDayWidget);
      case WidgetType.Map:
        return _buildMapWidget(widget as MapWidget);
      case WidgetType.Image:
        return _buildImageWidget(widget as ImageWidget);
      case WidgetType.Gallery:
        return _buildGalleryWidget(widget as GalleryWidget);
      case WidgetType.Schedule:
        return _buildScheduleWidget(widget as ScheduleWidget);
      case WidgetType.CountdownTimer:
        return _buildCountdownWidget(widget as CountdownWidget);
      default:
        // Check if it's a video or button widget in text widget data
        if (widget is TextWidget) {
          if (widget.data['isVideo'] == true) {
            return _buildVideoWidget(widget);
          } else if (widget.data['action'] != null) {
            return _buildButtonWidget(widget);
          }
        }
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Unknown Widget Type'),
        );
    }
  }

  Widget _buildTextWidget(TextWidget textWidget) {
    // Handle text properly
    String displayText = 'Enter text';
    try {
      displayText = textWidget.text.getText('ko');
    } catch (e) {
      // Fallback if MultiLanguageText is not available
      if (textWidget.data['text'] is String) {
        displayText = textWidget.data['text'];
      } else if (textWidget.data['text'] is Map) {
        displayText = textWidget.data['text']['ko'] ??
            textWidget.data['text']['en'] ??
            'Enter text';
      }
    }

    // Handle color parsing
    Color textColor = Colors.black;
    Color? backgroundColor;
    try {
      if (textWidget.color.startsWith('#')) {
        textColor =
            Color(int.parse('FF${textWidget.color.substring(1)}', radix: 16));
      } else {
        textColor = Color(int.parse(textWidget.color));
      }
      
      // Check for background color
      if (textWidget.data['backgroundColor'] != null) {
        final bgColor = textWidget.data['backgroundColor'];
        if (bgColor is String && bgColor.startsWith('#')) {
          backgroundColor = Color(int.parse('FF${bgColor.substring(1)}', radix: 16));
        }
      }
    } catch (e) {
      textColor = Colors.black;
    }

    return Container(
      padding: EdgeInsets.all(textWidget.data['padding']?.toDouble() ?? 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(textWidget.data['borderRadius']?.toDouble() ?? 8),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontFamily:
              textWidget.fontFamily.isNotEmpty ? textWidget.fontFamily : null,
          fontSize: textWidget.fontSize > 0 ? textWidget.fontSize : 16,
          color: textColor,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
      ),
    );
  }

  Widget _buildButtonWidget(TextWidget buttonWidget) {
    String displayText = '버튼';
    try {
      displayText = buttonWidget.text.getText('ko');
    } catch (e) {
      if (buttonWidget.data['text'] is Map) {
        displayText = buttonWidget.data['text']['ko'] ?? '버튼';
      }
    }

    Color backgroundColor = Colors.blue;
    Color textColor = Colors.white;
    
    try {
      if (buttonWidget.data['backgroundColor'] != null) {
        final bgColor = buttonWidget.data['backgroundColor'];
        if (bgColor is String && bgColor.startsWith('#')) {
          backgroundColor = Color(int.parse('FF${bgColor.substring(1)}', radix: 16));
        }
      }
      
      if (buttonWidget.color.startsWith('#')) {
        textColor = Color(int.parse('FF${buttonWidget.color.substring(1)}', radix: 16));
      }
    } catch (e) {
      // Use defaults
    }

    return ElevatedButton(
      onPressed: () {
        // Handle button action
        final action = buttonWidget.data['action'];
        final target = buttonWidget.data['actionTarget'];
        print('Button pressed: $action, target: $target');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: EdgeInsets.all(buttonWidget.data['padding']?.toDouble() ?? 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonWidget.data['borderRadius']?.toDouble() ?? 8),
        ),
      ),
      child: Text(
        displayText,
        style: TextStyle(fontSize: buttonWidget.fontSize),
      ),
    );
  }

  Widget _buildVideoWidget(TextWidget videoWidget) {
    final videoUrl = videoWidget.data['videoUrl']?.toString() ?? '';
    
    if (videoUrl.isEmpty) {
      return Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('비디오 URL을 설정해주세요', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return VideoPlayerWidget(videoUrl: videoUrl);
  }

  Widget _buildDDayWidget(DDayWidget ddayWidget) {
    // Get configurable date from widget data
    DateTime eventDate;
    try {
      if (ddayWidget.data.containsKey('targetDate')) {
        eventDate = DateTime.parse(ddayWidget.data['targetDate']);
      } else if (ddayWidget.data.containsKey('eventDate')) {
        eventDate = DateTime.parse(ddayWidget.data['eventDate']);
      } else {
        // Default fallback
        eventDate = DateTime.now().add(const Duration(days: 30));
      }
    } catch (e) {
      eventDate = DateTime.now().add(const Duration(days: 30));
    }

    final today = DateTime.now();
    final daysRemaining = eventDate.difference(today).inDays;

    // Get title from data
    String title = ddayWidget.data['title'] ?? 'D-Day';
    String format = ddayWidget.format ?? 'D-{days}';

    return LiveDDayWidget(
      eventDate: eventDate,
      title: title,
      format: format,
      style: ddayWidget.style,
    );
  }

  Widget _buildMapWidget(MapWidget mapWidget) {
    // Get coordinates from the widget data, with defaults for Seoul
    double latitude = 37.5665; // Default: Seoul
    double longitude = 126.9780; // Default: Seoul
    String venue = '결혼식장 위치';

    // Try to get coordinates from different possible data keys
    if (mapWidget.data.containsKey('latitude') &&
        mapWidget.data.containsKey('longitude')) {
      latitude = (mapWidget.data['latitude'] as num?)?.toDouble() ?? latitude;
      longitude =
          (mapWidget.data['longitude'] as num?)?.toDouble() ?? longitude;
    }

    // Get venue name if available
    if (mapWidget.data.containsKey('venue')) {
      venue = mapWidget.data['venue']?.toString() ?? venue;
    } else if (mapWidget.data.containsKey('title')) {
      venue = mapWidget.data['title']?.toString() ?? venue;
    }

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(latitude, longitude),
            zoom: 15.0,
            maxZoom: 18.0,
            minZoom: 10.0,
            interactiveFlags:
                InteractiveFlag.none, // Disable interaction in preview
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.wedding_invitation',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(latitude, longitude),
                  width: 80,
                  height: 80,
                  builder: (ctx) => Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          venue,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(ImageWidget imageWidget) {
    return Container(
      width: imageWidget.width > 0 ? imageWidget.width : 200,
      height: imageWidget.height > 0 ? imageWidget.height : 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageWidget.imageUrl.startsWith('assets/')
            ? Image.asset(
                imageWidget.imageUrl,
                width: imageWidget.width,
                height: imageWidget.height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: imageWidget.width,
                    height: imageWidget.height,
                    color: Colors.grey.shade200,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 50),
                        Text('이미지 없음', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              )
            : Image.network(
                imageWidget.imageUrl,
                width: imageWidget.width,
                height: imageWidget.height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: imageWidget.width,
                    height: imageWidget.height,
                    color: Colors.grey.shade200,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported,
                            color: Colors.grey, size: 50),
                        Text('이미지 없음', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildGalleryWidget(GalleryWidget galleryWidget) {
    if (galleryWidget.imageUrls.isEmpty) {
      return Container(
        width: 250,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
          color: Colors.grey.shade100,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library, size: 50, color: Colors.grey),
              SizedBox(height: 8),
              Text('갤러리가 비어있습니다', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    // Get style from data
    final style = galleryWidget.data['style']?.toString() ?? 'carousel';
    final showIndicators = galleryWidget.data['showIndicators'] ?? true;
    final autoPlay = galleryWidget.data['autoPlay'] ?? false;

    switch (style) {
      case 'grid':
        return _buildGridGallery(galleryWidget);
      case 'masonry':
        return _buildMasonryGallery(galleryWidget);
      case 'modern':
        return _buildModernGallery(galleryWidget);
      case 'carousel':
      default:
        return _buildCarouselGallery(galleryWidget, showIndicators, autoPlay);
    }
  }

  Widget _buildCarouselGallery(GalleryWidget galleryWidget, bool showIndicators, bool autoPlay) {
    return Container(
      width: 250,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 150,
          autoPlay: autoPlay,
          viewportFraction: 1.0,
          enableInfiniteScroll: galleryWidget.imageUrls.length > 1,
          autoPlayInterval: const Duration(seconds: 3),
        ),
        items: galleryWidget.imageUrls.map((imageUrl) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.startsWith('assets/')
                      ? Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            );
                          },
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            );
                          },
                        ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridGallery(GalleryWidget galleryWidget) {
    return Container(
      width: 250,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: galleryWidget.imageUrls.length.clamp(0, 4),
          itemBuilder: (context, index) {
            final imageUrl = galleryWidget.imageUrls[index];
            return imageUrl.startsWith('assets/')
                ? Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }

  Widget _buildMasonryGallery(GalleryWidget galleryWidget) {
    return Container(
      width: 250,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: galleryWidget.imageUrls.map((imageUrl) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: AspectRatio(
                aspectRatio: 0.7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: imageUrl.startsWith('assets/')
                      ? Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                        ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildModernGallery(GalleryWidget galleryWidget) {
    if (galleryWidget.imageUrls.isEmpty) return const SizedBox();
    
    return Container(
      width: 250,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Main image
            Positioned.fill(
              child: galleryWidget.imageUrls[0].startsWith('assets/')
                  ? Image.asset(
                      galleryWidget.imageUrls[0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    )
                  : Image.network(
                      galleryWidget.imageUrls[0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
            ),
            // Overlay with more images indicator
            if (galleryWidget.imageUrls.length > 1)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.photo_library, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+${galleryWidget.imageUrls.length - 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleWidget(ScheduleWidget scheduleWidget) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '결혼식 일정',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...scheduleWidget.events.map((event) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    event['time']?.toString() ?? '00:00',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event['description']?.toString() ?? '일정',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCountdownWidget(CountdownWidget countdownWidget) {
    return LiveCountdownWidget(
      targetDate: countdownWidget.targetDate,
      format: countdownWidget.format,
    );
  }
}

// Video Player Widget
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
              child: IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Live D-Day widget that updates in real-time
class LiveDDayWidget extends StatefulWidget {
  final DateTime eventDate;
  final String title;
  final String format;
  final String style;

  const LiveDDayWidget({
    super.key,
    required this.eventDate,
    required this.title,
    required this.format,
    required this.style,
  });

  @override
  State<LiveDDayWidget> createState() => _LiveDDayWidgetState();
}

class _LiveDDayWidgetState extends State<LiveDDayWidget> {
  Timer? _timer;
  int _daysRemaining = 0;

  @override
  void initState() {
    super.initState();
    _updateDays();
    _timer = Timer.periodic(const Duration(hours: 1), (timer) {
      _updateDays();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateDays() {
    final today = DateTime.now();
    final remaining = widget.eventDate.difference(today).inDays;
    if (mounted) {
      setState(() {
        _daysRemaining = remaining;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayText;
    if (_daysRemaining > 0) {
      displayText =
          widget.format.replaceAll('{days}', _daysRemaining.toString());
    } else if (_daysRemaining == 0) {
      displayText = 'D-Day';
    } else {
      displayText = widget.format.replaceAll('{days}', '+${-_daysRemaining}');
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Live countdown widget that updates in real-time
class LiveCountdownWidget extends StatefulWidget {
  final DateTime targetDate;
  final String format;

  const LiveCountdownWidget({
    super.key,
    required this.targetDate,
    required this.format,
  });

  @override
  State<LiveCountdownWidget> createState() => _LiveCountdownWidgetState();
}

class _LiveCountdownWidgetState extends State<LiveCountdownWidget> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final remaining = widget.targetDate.difference(now);
    if (mounted) {
      setState(() {
        _remaining = remaining.isNegative ? Duration.zero : remaining;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '결혼식까지',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCountdownBox(days.toString(), '일'),
                const SizedBox(width: 4),
                _buildCountdownBox(hours.toString().padLeft(2, '0'), '시간'),
                const SizedBox(width: 4),
                _buildCountdownBox(minutes.toString().padLeft(2, '0'), '분'),
                const SizedBox(width: 4),
                _buildCountdownBox(seconds.toString().padLeft(2, '0'), '초'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBox(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
