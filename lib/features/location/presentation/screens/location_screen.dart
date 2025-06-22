import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/map_widget.dart';
import '../widgets/transport_info.dart';

class LocationScreen extends ConsumerWidget {
  final String invitationId;

  const LocationScreen({
    super.key,
    required this.invitationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Load location data from Supabase
    const venue = '더 플라자 호텔 그랜드볼룸';
    const address = '서울특별시 중구 소공로 119';
    const latitude = 37.5642;
    const longitude = 126.9758;

    return Scaffold(
      appBar: AppBar(
        title: const Text('오시는 길'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map
            const MapWidget(
              latitude: latitude,
              longitude: longitude,
              venue: venue,
            ),
            // Venue Info
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              venue,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Navigation buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildNavigationButton(
                          context,
                          '카카오맵',
                          Colors.yellow[700]!,
                          () => _launchMap('kakao', latitude, longitude, venue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNavigationButton(
                          context,
                          '네이버맵',
                          Colors.green,
                          () => _launchMap('naver', latitude, longitude, venue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildNavigationButton(
                          context,
                          '구글맵',
                          Colors.blue,
                          () => _launchMap('google', latitude, longitude, venue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Transport info
                  Text(
                    '교통 안내',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const TransportInfo(
                    icon: Icons.subway,
                    title: '지하철',
                    content: '2호선 시청역 12번 출구에서 도보 5분\n1호선 시청역 5번 출구에서 도보 10분',
                    color: Colors.blue,
                  ),
                  const TransportInfo(
                    icon: Icons.directions_bus,
                    title: '버스',
                    content: '시청.덕수궁 정류장\n172, 272, 401, 406번 버스 이용',
                    color: Colors.green,
                  ),
                  const TransportInfo(
                    icon: Icons.directions_car,
                    title: '자가용',
                    content: '호텔 지하 주차장 이용 가능\n주차 요금: 10분당 1,500원',
                    color: Colors.orange,
                  ),
                  const TransportInfo(
                    icon: Icons.local_parking,
                    title: '주차',
                    content: '하객 주차권 제공 (프론트에서 문의)\n대체 주차장: 서울시청 서소문청사 주차장',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchMap(
    String type,
    double lat,
    double lng,
    String name,
  ) async {
    Uri uri;
    switch (type) {
      case 'kakao':
        uri = Uri.parse('kakaomap://look?p=$lat,$lng');
        break;
      case 'naver':
        uri = Uri.parse(
          'nmap://place?lat=$lat&lng=$lng&name=${Uri.encodeComponent(name)}&appname=com.example.wedding_invitation',
        );
        break;
      case 'google':
        uri = Uri.parse('https://maps.google.com/?q=$lat,$lng');
        break;
      default:
        return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback to web version
      Uri webUri;
      switch (type) {
        case 'kakao':
          webUri = Uri.parse('https://map.kakao.com/link/map/${Uri.encodeComponent(name)},$lat,$lng');
          break;
        case 'naver':
          webUri = Uri.parse('https://map.naver.com/v5/search/${Uri.encodeComponent(name)}');
          break;
        case 'google':
          webUri = Uri.parse('https://maps.google.com/?q=$lat,$lng');
          break;
        default:
          return;
      }
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }
}
