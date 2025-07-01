import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/editor_viewmodel.dart';
import '../../widgets/wedding_invitation_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final String _currentLanguage = 'ko';

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

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
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<HomeViewModel, EditorViewModel>(
        builder: (context, homeViewModel, editorViewModel, child) {
          if (homeViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
              ),
            );
          }

          if (homeViewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    '오류: ${homeViewModel.errorMessage}',
                    style: TextStyle(color: Colors.red.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (homeViewModel.invitation == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_photography, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '데이터를 불러올 수 없습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final invitation = homeViewModel.invitation!;
          final timeUntilWedding = homeViewModel.getTimeUntilWedding();
          final weddingVenue = invitation.venues.firstWhere(
            (venue) => venue.eventType == 'Wedding',
            orElse: () => invitation.venues.first,
          );

          // Get edited content from editor view model
          String greetingText =
              invitation.greetingMessage.getText(_currentLanguage);

          if (!editorViewModel.isLoading && editorViewModel.pages.isNotEmpty) {
            // Find the main page (order 0 or title "메인")
            final mainPage = editorViewModel.pages.firstWhere(
              (page) => page.order == 0 || page.title == '메인',
              orElse: () => editorViewModel.pages.first,
            );

            // Look for greeting text widget in the main page
            if (mainPage.widgets.isNotEmpty) {
              final greetingWidgets = mainPage.widgets.where((widget) =>
                  widget.type.index == 0 && // WidgetType.text has index 0
                  widget.properties.containsKey('text'));

              if (greetingWidgets.isNotEmpty) {
                final greetingWidget = greetingWidgets.first;
                if (greetingWidget.properties.containsKey('text')) {
                  greetingText = greetingWidget.properties['text'];
                }
              }
            }
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF5F5),
                  Color(0xFFFFE4E6),
                  Color(0xFFFFF0F0),
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Elegant Header with decorative elements
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: WeddingHeader(
                        backgroundImage: invitation.backgroundImage,
                        groomName: invitation.groomName.getText(_currentLanguage),
                        brideName: invitation.brideName.getText(_currentLanguage),
                        weddingDate: weddingVenue.eventDate,
                        venue: weddingVenue.name,
                      ),
                    ),
                  ),

                  // Invitation Message
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: WeddingInvitationCard(
                        greetingText: greetingText,
                      ),
                    ),
                  ),

                  // Countdown Timer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: WeddingCountdown(
                        timeUntilWedding: timeUntilWedding,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Wedding Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: WeddingDetails(
                        weddingDate: weddingVenue.eventDate,
                        venue: weddingVenue.name,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Navigation Buttons
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: WeddingNavigationButtons(
                        onGalleryPressed: () => Navigator.pushNamed(context, '/gallery'),
                        onLocationPressed: () => Navigator.pushNamed(context, '/location'),
                        onMessagePressed: () => Navigator.pushNamed(context, '/message'),
                        onEditorPressed: () => Navigator.pushNamed(context, '/editor'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 1,
                          color: Colors.pink.shade200,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '함께해 주셔서 감사합니다',
                          style: TextStyle(
                            color: Colors.pink.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '💕',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.pink.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}