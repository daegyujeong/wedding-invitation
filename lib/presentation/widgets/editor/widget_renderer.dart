import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/editor_widget_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../features/location/presentation/widgets/multi_map_widget.dart';
import '../../../features/location/presentation/widgets/multi_map_widget.dart' show MapProvider;
import '../../../features/location/presentation/widgets/google_map_widget_wrapper.dart';
import '../../../features/location/presentation/widgets/naver_map_widget.dart' as naver_map;
import '../../../features/location/presentation/widgets/kakao_map_widget.dart' as kakao_map;

class WidgetRenderer extends StatelessWidget {
  final EditorWidget widget;
  final bool isEditMode;
  final Function(EditorWidget)? onWidgetUpdated;

  const WidgetRenderer({
    super.key,
    required this.widget,
    this.isEditMode = true, // Default to edit mode for the editor
    this.onWidgetUpdated,
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
      case WidgetType.GoogleMap:
        return _buildGoogleMapWidget(widget as GoogleMapWidget);
      case WidgetType.NaverMap:
        return _buildNaverMapWidget(widget as NaverMapWidget);
      case WidgetType.KakaoMap:
        return _buildKakaoMapWidget(widget as KakaoMapWidget);
      case WidgetType.Image:
        return _buildImageWidget(widget as ImageWidget);
      case WidgetType.Gallery:
        return _buildGalleryWidget(widget as GalleryWidget);
      case WidgetType.Schedule:
        return _buildScheduleWidget(widget as ScheduleWidget);
      case WidgetType.CountdownTimer:
        return _buildCountdownWidget(widget as CountdownWidget);
      case WidgetType.Video:
        return _buildVideoWidget(widget as VideoWidget);
      case WidgetType.Button:
        return _buildButtonWidget(widget as ButtonWidget);
      default:
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
          backgroundColor =
              Color(int.parse('FF${bgColor.substring(1)}', radix: 16));
        }
      }
    } catch (e) {
      textColor = Colors.black;
    }

    return Container(
      padding: EdgeInsets.all(textWidget.data['padding']?.toDouble() ?? 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(
            textWidget.data['borderRadius']?.toDouble() ?? 8),
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

  Widget _buildButtonWidget(ButtonWidget buttonWidget) {
    String displayText = buttonWidget.text.getText('ko');

    Color backgroundColor = Colors.blue;
    Color textColor = Colors.white;

    try {
      if (buttonWidget.backgroundColor.isNotEmpty) {
        backgroundColor = Color(int.parse(
            'FF${buttonWidget.backgroundColor.substring(1)}',
            radix: 16));
      }
      if (buttonWidget.color.isNotEmpty) {
        textColor =
            Color(int.parse('FF${buttonWidget.color.substring(1)}', radix: 16));
      }
    } catch (e) {
      // Use defaults
    }

    if (isEditMode) {
      // In edit mode, render as a container to prevent touch events
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      // In view mode, render as actual button
      return ElevatedButton(
        onPressed: () {
          // Handle button action
          debugPrint(
              'Button pressed: ${buttonWidget.action}, target: ${buttonWidget.actionTarget}');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(displayText),
      );
    }
  }

  Widget _buildVideoWidget(VideoWidget videoWidget) {
    final videoUrl = videoWidget.videoUrl;

    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.video_library, size: 50, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            videoUrl.isEmpty ? '비디오 URL을 설정해주세요' : '비디오: $videoUrl',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '비디오 플레이어 기능은\n개발 중입니다',
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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

    // Calculate days remaining (for future use)
    // final today = DateTime.now();
    // final daysRemaining = eventDate.difference(today).inDays;

    // Get title from data
    String title = ddayWidget.data['title'] ?? 'D-Day';
    String format = ddayWidget.format;

    return LiveDDayWidget(
      eventDate: eventDate,
      title: title,
      format: format,
      style: ddayWidget.style,
    );
  }

  Widget _buildMapWidget(MapWidget mapWidget) {
    // Parse map provider
    MapProvider provider = MapProvider.google;
    switch (mapWidget.mapProvider.toLowerCase()) {
      case 'naver':
        provider = MapProvider.naver;
        break;
      case 'kakao':
        provider = MapProvider.kakao;
        break;
      default:
        provider = MapProvider.google;
    }

    // ROBUST FIX: Use LayoutBuilder to handle both constrained and unconstrained scenarios
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate appropriate width based on constraints
        double mapWidth;
        if (constraints.maxWidth.isFinite) {
          // If parent provides finite width, use it
          mapWidth = constraints.maxWidth;
        } else {
          // If parent provides unconstrained width, use screen width or fallback
          mapWidth = MediaQuery.of(context).size.width * 0.9; // 90% of screen width
        }

        // Ensure minimum width for usability
        mapWidth = mapWidth.clamp(250.0, double.infinity);

        return Container(
          width: mapWidth,
          height: mapWidget.height,
          child: MultiMapWidget(
            latitude: mapWidget.latitude,
            longitude: mapWidget.longitude,
            venue: mapWidget.venue,
            provider: provider,
            showControls: !isEditMode && mapWidget.showControls,
            showDirections: !isEditMode && mapWidget.showDirections,
            height: mapWidget.height,
            isEditMode: isEditMode,
            showSearch: isEditMode, // Enable search in edit mode
            onLocationSelected: isEditMode ? (result) {
              // Update the widget's location when a new location is selected
              if (onWidgetUpdated != null) {
                final updatedData = Map<String, dynamic>.from(mapWidget.data);
                updatedData['latitude'] = result.latitude;
                updatedData['longitude'] = result.longitude;
                updatedData['venue'] = result.name;
                
                final updatedWidget = MapWidget(
                  id: mapWidget.id,
                  data: updatedData,
                );
                
                onWidgetUpdated!(updatedWidget);
                debugPrint('Location updated: ${result.name} (${result.latitude}, ${result.longitude})');
              }
            } : null,
            onMapTap: isEditMode ? () {
              // In edit mode, you might want to open a dialog to select map provider
              debugPrint('Map provider selection in edit mode');
            } : null,
          ),
        );
      },
    );
  }

  // Individual map widget builders
  Widget _buildGoogleMapWidget(GoogleMapWidget googleMapWidget) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double mapWidth;
        if (constraints.maxWidth.isFinite) {
          mapWidth = constraints.maxWidth;
        } else {
          mapWidth = MediaQuery.of(context).size.width * 0.9;
        }
        mapWidth = mapWidth.clamp(250.0, double.infinity);

        return Container(
          width: mapWidth,
          height: googleMapWidget.height,
          child: GoogleMapWidgetWrapper(
            latitude: googleMapWidget.latitude,
            longitude: googleMapWidget.longitude,
            venue: googleMapWidget.venue,
            showControls: !isEditMode && googleMapWidget.showControls,
            height: googleMapWidget.height,
          ),
        );
      },
    );
  }

  Widget _buildNaverMapWidget(NaverMapWidget naverMapWidget) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double mapWidth;
        if (constraints.maxWidth.isFinite) {
          mapWidth = constraints.maxWidth;
        } else {
          mapWidth = MediaQuery.of(context).size.width * 0.9;
        }
        mapWidth = mapWidth.clamp(250.0, double.infinity);

        return Container(
          width: mapWidth,
          height: naverMapWidget.height,
          child: naver_map.NaverMapWidget(
            latitude: naverMapWidget.latitude,
            longitude: naverMapWidget.longitude,
            venue: naverMapWidget.venue,
            showControls: !isEditMode && naverMapWidget.showControls,
            height: naverMapWidget.height,
          ),
        );
      },
    );
  }

  Widget _buildKakaoMapWidget(KakaoMapWidget kakaoMapWidget) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double mapWidth;
        if (constraints.maxWidth.isFinite) {
          mapWidth = constraints.maxWidth;
        } else {
          mapWidth = MediaQuery.of(context).size.width * 0.9;
        }
        mapWidth = mapWidth.clamp(250.0, double.infinity);

        return Container(
          width: mapWidth,
          height: kakaoMapWidget.height,
          child: kakao_map.KakaoMapWidget(
            latitude: kakaoMapWidget.latitude,
            longitude: kakaoMapWidget.longitude,
            venue: kakaoMapWidget.venue,
            showControls: !isEditMode && kakaoMapWidget.showControls,
            height: kakaoMapWidget.height,
          ),
        );
      },
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

  Widget _buildCarouselGallery(
      GalleryWidget galleryWidget, bool showIndicators, bool autoPlay) {
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
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey),
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
                          child: const Icon(Icons.broken_image,
                              color: Colors.grey),
                        );
                      },
                    )
                  : Image.network(
                      galleryWidget.imageUrls[0],
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
            // Overlay with more images indicator
            if (galleryWidget.imageUrls.length > 1)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.photo_library,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+${galleryWidget.imageUrls.length - 1}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
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
