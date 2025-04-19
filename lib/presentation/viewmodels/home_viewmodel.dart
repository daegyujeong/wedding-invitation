import 'package:flutter/material.dart';
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
        title: '우리의 결혼식',
        groomName: '김철수',
        brideName: '이영희',
        weddingDate: DateTime(2025, 5, 31, 13, 0),
        location: '그랜드 호텔 3층 그랜드볼룸',
        backgroundImage: 'assets/images/main.jpg',
        template: 'classic',
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Duration getTimeUntilWedding() {
    if (_invitation == null) {
      return Duration.zero;
    }

    final now = DateTime.now();
    return _invitation!.weddingDate.difference(now);
  }
}
