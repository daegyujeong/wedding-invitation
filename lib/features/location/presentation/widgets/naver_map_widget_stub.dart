import 'package:flutter/material.dart';

class NaverMapWidgetWeb extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String venue;
  final String? address;
  final bool showControls;
  final double height;
  final bool isLocked;

  const NaverMapWidgetWeb({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.venue,
    this.address,
    this.showControls = true,
    this.height = 300,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Naver Maps',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Web only',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}