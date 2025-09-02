// lib/presentation/screens/gallery/gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'photo_viewer_screen.dart';
import '../../../data/utils/image_utils.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  Map<String, double> _aspectRatios = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImageAspectRatios();
  }

  Future<void> _loadImageAspectRatios() async {
    final List<String> imageUrls = [
      'assets/images/DSC07932.webp',
      'assets/images/DSC07939.webp',
      'assets/images/DSC07943.webp',
      'assets/images/DSC07956.webp',
      'assets/images/DSC08050.webp',
      'assets/images/DSC08078.webp',
      'assets/images/DSC08089.webp',
      'assets/images/DSC08219.webp',
      'assets/images/DSC08212.webp',
      'assets/images/DSC08174.webp',
      'assets/images/DSC08298.webp',
      'assets/images/DSC08383.webp',
      'assets/images/DSC08488.webp',
      'assets/images/DSC08428.webp',
      'assets/images/DSC08514.webp',
      'assets/images/DSC08496.webp',
    ];

    try {
      final aspectRatios =
          await ImageUtils.getMultipleAssetImageAspectRatios(imageUrls);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // Custom header within constrained width
              Container(
                height: MediaQuery.of(context).padding.top + 56,
                decoration: BoxDecoration(
                  color: Colors.purple.shade400,
                ),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => context.go('/'),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Gallery content
              Expanded(child: _buildGalleryContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryContent() {
    // Real wedding photos - DSC series only
    final List<String> imageUrls = [
      'assets/images/DSC07932.webp',
      'assets/images/DSC07939.webp',
      'assets/images/DSC07943.webp',
      'assets/images/DSC07956.webp',
      'assets/images/DSC08050.webp',
      'assets/images/DSC08078.webp',
      'assets/images/DSC08089.webp',
      'assets/images/DSC08219.webp',
      'assets/images/DSC08212.webp',
      'assets/images/DSC08174.webp',
      'assets/images/DSC08298.webp',
      'assets/images/DSC08383.webp',
      'assets/images/DSC08488.webp',
      'assets/images/DSC08428.webp',
      'assets/images/DSC08514.webp',
      'assets/images/DSC08496.webp',
    ];

    return Column(
      children: [
        // Enhanced gallery grid with lazy loading
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          '사진을 불러오는 중...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : imageUrls.isEmpty
                    ? const Center(
                        child: Text(
                          'No photos found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : MasonryGridView.custom(
                        gridDelegate:
                            const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        physics: const BouncingScrollPhysics(),
                        childrenDelegate: SliverChildBuilderDelegate(
                          (context, index) {
                            debugPrint(
                                'Building photo thumbnail $index: ${imageUrls[index]}');
                            return _buildPhotoThumbnail(
                                context, imageUrls[index], index, imageUrls);
                          },
                          childCount: imageUrls.length,
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(BuildContext context, String imageUrl, int index,
      List<String> allImages) {
    // Determine aspect ratio based on actual DSC image dimensions
    double aspectRatio = _getAspectRatioForDSCImage(imageUrl);

    return Hero(
      tag: 'photo_$index',
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.black.withOpacity(0.8), // Semi-transparent background
              barrierDismissible: true,
              builder: (context) => Dialog.fullscreen(
                backgroundColor: Colors.transparent,
                child: PhotoViewerScreen(
                  imageUrls: allImages,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Wedding photo asset with proper alignment
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        alignment: _getImageAlignment(imageUrl),
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading image: $imageUrl - $error');
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
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
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
                                Text(
                                  imageUrl.split('/').last,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Removed photo number overlay for cleaner look
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getAspectRatioForDSCImage(String imageUrl) {
    // Use the actual loaded aspect ratio if available
    return _aspectRatios[imageUrl] ?? 1.0; // Default to square if not found
  }

  // Determine image alignment based on DSC image orientation
  Alignment _getImageAlignment(String imageUrl) {
    // For DSC images, determine alignment based on aspect ratio
    final aspectRatio = _getAspectRatioForDSCImage(imageUrl);

    if (aspectRatio < 1.0) {
      // Portrait images - show top portion (faces usually at top)
      return Alignment.topCenter;
    } else {
      // Landscape images - center alignment
      return Alignment.center;
    }
  }
}
