import 'package:flutter/material.dart';

import '../../../data/models/editor_widget_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        textWidget.text.getText('ko'), // Use current language
        style: TextStyle(
          fontFamily: textWidget.fontFamily,
          fontSize: textWidget.fontSize,
          color:
              Color(int.parse('FF${textWidget.color.substring(1)}', radix: 16)),
        ),
      ),
    );
  }

  Widget _buildDDayWidget(DDayWidget ddayWidget) {
    // Calculate days remaining (example implementation)
    final eventDate = DateTime(2025, 5, 31); // Get from wedding data
    final today = DateTime.now();
    final daysRemaining = eventDate.difference(today).inDays;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'D-day',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            daysRemaining > 0
                ? 'D-$daysRemaining'
                : daysRemaining == 0
                    ? 'D-Day'
                    : 'D+${-daysRemaining}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapWidget(MapWidget mapWidget) {
    // Example with flutter_map
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
            center: const LatLng(37.5665, 126.9780), // Default to Seoul
            zoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.wedding_invitation',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: const LatLng(37.5665, 126.9780),
                  width: 40,
                  height: 40,
                  builder: (context) => const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
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
      width: imageWidget.width,
      height: imageWidget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
        image: DecorationImage(
          image: NetworkImage(imageWidget.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildGalleryWidget(GalleryWidget galleryWidget) {
    // Simplified gallery for now
    return Container(
      width: 250,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: galleryWidget.imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.network(
              galleryWidget.imageUrls[index],
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          );
        },
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
                    event['time'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(event['description']),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCountdownWidget(CountdownWidget countdownWidget) {
    // Calculate time remaining
    final targetDate = countdownWidget.targetDate;
    final now = DateTime.now();
    final remaining = targetDate.difference(now);

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

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
          Row(
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
        ],
      ),
    );
  }

  Widget _buildCountdownBox(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
