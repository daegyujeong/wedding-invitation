import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../widgets/photo_viewer.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  final String invitationId;

  const GalleryScreen({
    super.key,
    required this.invitationId,
  });

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final List<String> _photos = [
    'https://via.placeholder.com/600x800/FFE4E1/FF69B4?text=Photo+1',
    'https://via.placeholder.com/600x800/E6E6FA/9370DB?text=Photo+2',
    'https://via.placeholder.com/600x800/FFF0F5/FF1493?text=Photo+3',
    'https://via.placeholder.com/600x800/F0FFF0/228B22?text=Photo+4',
    'https://via.placeholder.com/600x800/F5F5F5/696969?text=Photo+5',
    'https://via.placeholder.com/600x800/FFFAF0/FFD700?text=Photo+6',
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 갤러리'),
      ),
      body: _photos.isEmpty
          ? const EmptyWidget(
              message: '아직 갤러리에 사진이 업로드되지 않았습니다',
              icon: Icons.photo_library_outlined,
            )
          : Column(
              children: [
                Expanded(
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: double.infinity,
                      viewportFraction: 0.85,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    items: _photos.map((photo) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoViewer(
                                imageUrls: _photos,
                                initialIndex: _photos.indexOf(photo),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              photo,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _photos.asMap().entries.map((entry) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor.withOpacity(
                                _currentIndex == entry.key ? 1.0 : 0.3,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Thumbnail grid
                Container(
                  height: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoViewer(
                                imageUrls: _photos,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _currentIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              _photos[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
