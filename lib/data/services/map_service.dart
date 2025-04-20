// lib/data/services/map_service.dart
import 'package:url_launcher/url_launcher.dart';
import '../models/venue_model.dart';

enum MapType { Google, Kakao, Naver, Waze }

class MapService {
  // 장소 정보로 지도 서비스 URL 생성
  Map<String, String> generateMapLinks(VenueModel venue) {
    Map<String, String> links = {};

    // 구글 맵
    links['google'] =
        'https://www.google.com/maps/search/?api=1&query=${venue.latitude},${venue.longitude}';

    // 카카오맵 (한국)
    if (venue.country == 'Korea') {
      links['kakao'] =
          'kakaomap://route?ep=${venue.latitude},${venue.longitude}&by=CAR';
    }

    // 네이버 맵 (한국)
    if (venue.country == 'Korea') {
      links['naver'] =
          'nmap://route/car?dlat=${venue.latitude}&dlng=${venue.longitude}&dname=${Uri.encodeFull(venue.name)}';
    }

    // Waze (싱가포르, 말레이시아)
    if (venue.country == 'Singapore' || venue.country == 'Malaysia') {
      links['waze'] =
          'waze://?ll=${venue.latitude},${venue.longitude}&navigate=yes';
    }

    return links;
  }

  // 지도 앱 열기
  Future<void> openMap(MapType mapType, VenueModel venue) async {
    String url;

    switch (mapType) {
      case MapType.Google:
        url =
            'https://www.google.com/maps/search/?api=1&query=${venue.latitude},${venue.longitude}';
        break;
      case MapType.Kakao:
        url = 'kakaomap://route?ep=${venue.latitude},${venue.longitude}&by=CAR';
        break;
      case MapType.Naver:
        url =
            'nmap://route/car?dlat=${venue.latitude}&dlng=${venue.longitude}&dname=${Uri.encodeFull(venue.name)}';
        break;
      case MapType.Waze:
        url = 'waze://?ll=${venue.latitude},${venue.longitude}&navigate=yes';
        break;
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // 앱이 설치되어 있지 않은 경우 웹 버전으로 열기
      String webUrl =
          'https://www.google.com/maps/search/?api=1&query=${venue.latitude},${venue.longitude}';
      await launch(webUrl);
    }
  }
}
