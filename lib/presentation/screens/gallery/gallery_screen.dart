// lib/presentation/screens/gallery/gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'photo_viewer_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '사진 갤러리',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: _buildGalleryContent(),
    );
  }

  Widget _buildGalleryContent() {
    // Placeholder images - in a real app, these would come from a data source
    final List<String> imageUrls = [
      'https://via.placeholder.com/400x300/E91E63/FFFFFF?text=사진+1',
      'https://via.placeholder.com/400x300/9C27B0/FFFFFF?text=사진+2',
      'https://via.placeholder.com/400x300/673AB7/FFFFFF?text=사진+3',
      'https://via.placeholder.com/400x300/3F51B5/FFFFFF?text=사진+4',
      'https://via.placeholder.com/400x300/2196F3/FFFFFF?text=사진+5',
      'https://via.placeholder.com/400x300/00BCD4/FFFFFF?text=사진+6',
      'https://via.placeholder.com/400x300/009688/FFFFFF?text=사진+7',
      'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=사진+8',
      'https://via.placeholder.com/400x300/8BC34A/FFFFFF?text=사진+9',
      'https://via.placeholder.com/400x300/CDDC39/FFFFFF?text=사진+10',
      'https://via.placeholder.com/400x300/FFEB3B/FFFFFF?text=사진+11',
      'https://via.placeholder.com/400x300/FFC107/FFFFFF?text=사진+12',
    ];

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.photo_camera,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              const Text(
                '우리의 소중한 순간들',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${imageUrls.length}장의 추억',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        // Enhanced gallery grid with lazy loading
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: MasonryGridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              itemCount: imageUrls.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildPhotoThumbnail(context, imageUrls[index], index, imageUrls);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(BuildContext context, String imageUrl, int index, List<String> allImages) {
    return Hero(
      tag: 'photo_$index',
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoViewerScreen(
                  imageUrls: allImages,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cached network image with loading placeholder
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
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
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
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
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Photo number overlay
              Positioned(
                top: 8,
                right: 8,
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
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}