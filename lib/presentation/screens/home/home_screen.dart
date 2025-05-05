import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/editor_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  final String _currentLanguage = 'ko';
  
  @override
  void initState() {
    super.initState();
    // 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).loadInvitation('1');
      Provider.of<EditorViewModel>(context, listen: false).loadData('1');
    });

    // 타이머 설정 (1초마다 갱신)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<HomeViewModel, EditorViewModel>(
        builder: (context, homeViewModel, editorViewModel, child) {
          if (homeViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (homeViewModel.errorMessage != null) {
            return Center(child: Text('오류: ${homeViewModel.errorMessage}'));
          }

          if (homeViewModel.invitation == null) {
            return const Center(child: Text('데이터를 불러올 수 없습니다.'));
          }

          final invitation = homeViewModel.invitation!;
          final timeUntilWedding = homeViewModel.getTimeUntilWedding();
          final weddingVenue = invitation.venues.firstWhere(
            (venue) => venue.eventType == 'Wedding',
            orElse: () => invitation.venues.first,
          );
          
          // Get edited content from editor view model
          String greetingText = invitation.greetingMessage.getText(_currentLanguage);
          
          if (!editorViewModel.isLoading && editorViewModel.pages.isNotEmpty) {
            final mainPages = editorViewModel.pages.where((page) => page.template == 'main');
            if (mainPages.isNotEmpty) {
              final mainPage = mainPages.first;
              if (mainPage.content.containsKey('greeting_text')) {
                greetingText = mainPage.content['greeting_text'];
              }
            }
          }
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // 메인 이미지
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(invitation.backgroundImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // 초대 문구 (에디터에서 편집된 내용)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    greetingText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),

                // 신랑 신부 정보
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        invitation.groomName.getText(_currentLanguage),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const Text(' 그리고 ', style: TextStyle(fontSize: 16)),
                      Text(
                        invitation.brideName.getText(_currentLanguage),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),

                // 카운트다운 타이머
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('결혼식까지 남은 시간', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCountdownItem(timeUntilWedding.inDays, '일'),
                          _buildCountdownItem(
                              timeUntilWedding.inHours % 24, '시간'),
                          _buildCountdownItem(
                              timeUntilWedding.inMinutes % 60, '분'),
                          _buildCountdownItem(
                              timeUntilWedding.inSeconds % 60, '초'),
                        ],
                      ),
                    ],
                  ),
                ),

                // 결혼식 정보
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR')
                            .format(weddingVenue.eventDate),
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        DateFormat('aa hh시 mm분', 'ko_KR')
                            .format(weddingVenue.eventDate),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weddingVenue.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),

                // 네비게이션 버튼들
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavButton(
                        context,
                        Icons.photo_library,
                        '갤러리',
                        () => Navigator.pushNamed(context, '/gallery'),
                      ),
                      _buildNavButton(
                        context,
                        Icons.location_on,
                        '오시는 길',
                        () => Navigator.pushNamed(context, '/location'),
                      ),
                      _buildNavButton(
                        context,
                        Icons.message,
                        '축하 메시지',
                        () => Navigator.pushNamed(context, '/message'),
                      ),
                      _buildNavButton(
                        context,
                        Icons.edit,
                        '에디터',
                        () => Navigator.pushNamed(context, '/editor'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountdownItem(int value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, String label,
      VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}