import 'package:flutter/material.dart';
import 'package:wedding_invitation/data/models/venue_model.dart';
import '../../data/models/invitation_model.dart';

class HomeViewModel extends ChangeNotifier {
  InvitationModel? _invitation;
  bool _isLoading = false;
  String? _errorMessage;

  InvitationModel? get invitation => _invitation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadInvitation(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 여기서 실제 데이터를 로드합니다
      await Future.delayed(const Duration(seconds: 1)); // 임시 지연

      // 임시 데이터
      _invitation = InvitationModel(
        id: '1',
        title: MultiLanguageText(
          translations: {'ko': '우리의 결혼식', 'en': 'Our Wedding'},
          defaultLanguage: 'ko',
        ),
        groomName: MultiLanguageText(
          translations: {'ko': '김철수', 'en': 'Kim Cheolsu'},
          defaultLanguage: 'ko',
        ),
        brideName: MultiLanguageText(
          translations: {'ko': '이영희', 'en': 'Lee Younghee'},
          defaultLanguage: 'ko',
        ),
        greetingMessage: MultiLanguageText(
          translations: {
            'ko': '저희 두 사람이 사랑과 믿음으로 새로운 가정을 이루게 되었습니다.',
            'en': 'We are delighted to invite you to celebrate our marriage.'
          },
          defaultLanguage: 'ko',
        ),
        venues: [
          VenueModel(
            id: '1',
            name: '그랜드 호텔 3층 그랜드볼룸',
            address: '서울특별시 중구 을지로 30',
            latitude: 37.5665,
            longitude: 126.9780,
            country: 'Korea',
            eventType: 'Wedding',
            eventDate: DateTime(2025, 5, 31, 13, 0),
            mapLinks: {
              'google':
                  'https://www.google.com/maps/search/?api=1&query=37.5665,126.9780',
              'kakao': 'kakaomap://route?ep=37.5665,126.9780&by=CAR',
              'naver': 'nmap://route/car?dlat=37.5665&dlng=126.9780&dname=그랜드호텔'
            },
          )
        ],
        backgroundImage: 'assets/images/background.png',
        template: 'classic',
        supportedLanguages: ['ko', 'en'],
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Duration getTimeUntilWedding() {
    if (_invitation == null || _invitation!.venues.isEmpty) {
      return Duration.zero;
    }

    final now = DateTime.now();

    // 첫 번째 결혼식 장소의 날짜를 사용하거나, Wedding 유형의 이벤트를 찾습니다
    final weddingVenue = _invitation!.venues.firstWhere(
      (venue) => venue.eventType == 'Wedding',
      orElse: () => _invitation!.venues.first,
    );

    return weddingVenue.eventDate.difference(now);
  }
}