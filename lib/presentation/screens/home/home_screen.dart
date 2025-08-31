import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/editor_viewmodel.dart';
import '../../../data/models/editor_widget_model.dart';
import '../../../data/models/guestbook_message_model.dart';
import '../../../data/repositories/interfaces/guestbook_repository.dart';
import '../../../core/di/dependency_injection.dart';
import '../../widgets/floating_music_player.dart';
import '../../../features/location/presentation/widgets/multi_map_widget.dart';
import '../../widgets/auto_scroll_gallery_preview.dart';
import '../../../widgets/language_selector.dart';
import '../../widgets/expandable_banking_widget.dart';
import '../../widgets/welcome_selection_popup.dart';
import '../../../providers/venue_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../widgets/guestbook/guestbook_message_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  final String _currentLanguage = 'ko';

  // Welcome popup control
  bool _showWelcomePopup = false;

  // Guestbook state
  IGuestbookRepository? _guestbookRepository;
  List<GuestbookMessage> _messages = [];
  bool _isLoadingMessages = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<List<GuestbookMessage>>? _messagesSubscription;

  // Scroll control for ticket navigation
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _ticketKeys = [
    GlobalKey(), // Malaysia
    GlobalKey(), // Singapore
    GlobalKey(), // Korea
  ];

  // Map section navigation
  final GlobalKey _mapSectionKey = GlobalKey();
  int _selectedMapTab = 0; // 0: Malaysia, 1: Singapore, 2: Korea

  // Hero slideshow variables
  Timer? _slideshowTimer;
  int _currentSlideIndex = 0;
  final List<String> _heroImages = [
    'assets/images/M01.01_dance_together.jpg',
    'assets/images/M03.03_beach_wedding.jpg',
    'assets/images/M04.04_sky_field_portrait.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).loadInvitation('1');
      Provider.of<EditorViewModel>(context, listen: false).loadData('1');

      // Check URL parameters and show popup if needed
      _handleUrlParameters();
    });

    // 타이머 설정 (1초마다 갱신)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });

    // Initialize slideshow timer
    _startSlideshow();

    // Initialize guestbook
    _initializeGuestbook();
  }

  void _handleUrlParameters() {
    final venueProvider = Provider.of<VenueProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    // Get URL parameters
    final uri = GoRouterState.of(context).uri;
    final venueParam = uri.queryParameters['venue'];
    final languageParam = uri.queryParameters['ln'];

    // Set language from URL parameter
    if (languageParam != null) {
      final locale = LocaleProvider.supportedLocales.firstWhere(
        (l) => l.languageCode == languageParam,
        orElse: () => const Locale('en'),
      );
      localeProvider.setLocale(locale);
    }

    // Set venue from URL parameter
    if (venueParam != null) {
      venueProvider.setFromUrlParams(venueParam);
    }

    // Show popup if user hasn't made selections yet
    if (venueProvider.shouldShowSelectionPopup()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showWelcomePopup = true;
          });
        }
      });
    }
  }

  void _initializeGuestbook() {
    try {
      _guestbookRepository = serviceLocator<IGuestbookRepository>();
      _setupRealtimeUpdates();
    } catch (e) {
      setState(() {
        _isLoadingMessages = false;
      });
    }
  }

  void _setupRealtimeUpdates() {
    if (_guestbookRepository == null) return;

    _messagesSubscription =
        _guestbookRepository!.getApprovedMessagesStream().listen(
      (messages) {
        if (mounted) {
          setState(() {
            _messages =
                messages.take(3).toList(); // Show only latest 3 messages
            _isLoadingMessages = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoadingMessages = false;
          });
        }
      },
    );
  }

  void _startSlideshow() {
    _slideshowTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentSlideIndex = (_currentSlideIndex + 1) % _heroImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _slideshowTimer?.cancel();
    _messagesSubscription?.cancel();
    _nameController.dispose();
    _messageController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer2<HomeViewModel, EditorViewModel>(
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
              final weddingVenue = invitation.venues.firstWhere(
                (venue) => venue.eventType == 'Wedding',
                orElse: () => invitation.venues.first,
              );

              // Get edited content from editor view model
              String greetingText =
                  invitation.greetingMessage.getText(_currentLanguage);

              if (!editorViewModel.isLoading &&
                  editorViewModel.pages.isNotEmpty) {
                // Find the main page (order 0 or title "메인")
                final mainPage = editorViewModel.pages.firstWhere(
                  (page) => page.order == 0 || page.title == '메인',
                  orElse: () => editorViewModel.pages.first,
                );

                // Look for greeting text widget in the main page
                if (mainPage.widgets.isNotEmpty) {
                  final greetingWidgets = mainPage.widgets
                      .where((widget) => widget.type == WidgetType.Text);

                  if (greetingWidgets.isNotEmpty) {
                    final greetingWidget = greetingWidgets.first;
                    if (greetingWidget is TextWidget) {
                      greetingText = greetingWidget.text.getText('ko');
                    }
                  }
                }
              }

              return Container(
                color: const Color(0xFFFAF7F4), // Warm beige background
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Title section
                      _buildTitleSection(),

                      // Hero wedding photo section
                      _buildHeroSection(),

                      // Wedding announcement
                      _buildWeddingAnnouncement(invitation, greetingText),

                      // Couple and parents info section
                      _buildFamilySection(invitation),

                      // Location and map - filter by venue
                      Consumer<VenueProvider>(
                        builder: (context, venueProvider, child) {
                          // Only show location section if we have venues to display
                          final hasVenuesToShow =
                              venueProvider.shouldShowVenue('my') ||
                                  venueProvider.shouldShowVenue('sg') ||
                                  venueProvider.shouldShowVenue('ko');

                          if (hasVenuesToShow) {
                            return _buildLocationSection(weddingVenue);
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Gallery preview section
                      _buildGalleryPreview(),

                      // Guestbook section
                      _buildKoreanGuestbook(),

                      // Banking information - only show for Korea
                      Consumer<VenueProvider>(
                        builder: (context, venueProvider, child) {
                          // Only show banking section for Korea or All venues
                          if (venueProvider.shouldShowVenue('ko')) {
                            return const ExpandableBankingWidget();
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // RSVP section
                      _buildKoreanRSVPSection(),

                      // Footer
                      _buildFooter(),

                      const SizedBox(
                          height: 100), // Space for floating music player
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating Music Player
          FloatingMusicPlayer(
            playlist: [
              WeddingSong(
                title: '결혼행진곡',
                artist: '멘델스존',
                duration: const Duration(minutes: 3, seconds: 30),
              ),
              WeddingSong(
                title: '사랑의 인사',
                artist: '엘가',
                duration: const Duration(minutes: 2, seconds: 45),
              ),
              WeddingSong(
                title: '캐논 변주곡',
                artist: '파헬벨',
                duration: const Duration(minutes: 4, seconds: 20),
              ),
            ],
            autoPlay: false,
          ),

          // Welcome selection popup overlay
          if (_showWelcomePopup)
            WelcomeSelectionPopup(
              onComplete: () {
                setState(() {
                  _showWelcomePopup = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Responsive values
    final horizontalPadding = isMobile ? 16.0 : 24.0;
    final verticalPadding = isMobile ? 24.0 : 40.0;
    final smallFontSize = isMobile ? 12.0 : 14.0;
    final largeFontSize = isMobile ? 22.0 : 28.0;
    final letterSpacing = isMobile ? 2.0 : 3.0;
    final largeLetterSpacing = isMobile ? 1.0 : 2.0;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: Stack(
        children: [
          // Language selector in top right
          const Positioned(
            top: 0,
            right: 0,
            child: CompactLanguageSelector(),
          ),
          // Title content
          Column(
            children: [
              Text(
                l10n.weddingInvitation.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD4A574),
                  letterSpacing: letterSpacing,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                l10n.weddingInvitation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: largeFontSize,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87,
                  letterSpacing: largeLetterSpacing,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),
              Container(
                width: isMobile ? 50 : 60,
                height: 2,
                color: const Color(0xFFD4A574),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Responsive height calculation
    final heroHeight = isMobile
        ? (screenHeight * 0.4)
            .clamp(280.0, 400.0) // 40% of screen height, min 280, max 400
        : 500.0;

    return Container(
      width: double.infinity,
      height: heroHeight,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Slideshow images with crossfade
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Container(
              key: ValueKey(_currentSlideIndex),
              width: double.infinity,
              height: heroHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_heroImages[_currentSlideIndex]),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
          ),
          // Slideshow indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _heroImages.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentSlideIndex == entry.key
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeddingAnnouncement(invitation, greetingText) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isNarrow = screenWidth < 400;

    // Responsive values
    final horizontalPadding = isNarrow ? 16.0 : (isMobile ? 20.0 : 24.0);
    final verticalPadding = isMobile ? 32.0 : 40.0;
    final fontSize = isNarrow ? 14.0 : (isMobile ? 15.0 : 16.0);
    final lineHeight = isNarrow ? 1.6 : (isMobile ? 1.7 : 1.8);
    final decoratorWidth = isMobile ? 50.0 : 60.0;
    final spacing = isMobile ? 24.0 : 30.0;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        children: [
          // Decorative element
          Container(
            width: decoratorWidth,
            height: 2,
            color: const Color(0xFFD4A574),
            margin: EdgeInsets.only(bottom: spacing),
          ),

          // Main message with better responsive text handling
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isNarrow ? 8.0 : 0.0),
            child: Text(
              l10n.ourStory,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                height: lineHeight,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          SizedBox(height: spacing),

          // Decorative element
          Container(
            width: decoratorWidth,
            height: 2,
            color: const Color(0xFFD4A574),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilySection(invitation) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isNarrow = screenWidth < 400;

    // Responsive values
    final horizontalPadding = isNarrow ? 12.0 : (isMobile ? 16.0 : 24.0);
    final verticalPadding = isMobile ? 32.0 : 40.0;
    final titleFontSize = isNarrow ? 16.0 : (isMobile ? 18.0 : 20.0);
    final letterSpacing = isMobile ? 1.0 : 2.0;
    final titleSpacing = isMobile ? 16.0 : 20.0;

    return Container(
      width: double.infinity,
      color: const Color(0xFFFAF7F4),
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        children: [
          Text(
            l10n.ourJourney,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: letterSpacing,
            ),
          ),

          SizedBox(height: titleSpacing),

          // Bookmark navigation - show all venues, highlight selected, enable only selected
          Consumer<VenueProvider>(
            builder: (context, venueProvider, child) {
              // Define all venues with highlight/enable status
              final allVenues = [
                {
                  'icon': '🇲🇾',
                  'label': l10n.malaysia,
                  'date': 'Sep 12',
                  'index': 0,
                  'venueCode': 'my',
                },
                {
                  'icon': '🇸🇬',
                  'label': l10n.singapore,
                  'date': 'Nov 9',
                  'index': 1,
                  'venueCode': 'sg',
                },
                {
                  'icon': '🇰🇷',
                  'label': l10n.korea,
                  'date': 'Nov 30',
                  'index': 2,
                  'venueCode': 'ko',
                }
              ];

              if (isNarrow) {
                // Narrow layout - show all venues in column
                return Column(
                  children: allVenues.map((venue) {
                    final isSelected = venueProvider
                        .shouldShowVenue(venue['venueCode'] as String);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildBookmark(
                        icon: venue['icon'] as String,
                        label: venue['label'] as String,
                        date: venue['date'] as String,
                        onTap: isSelected
                            ? () => _scrollToTicket(venue['index'] as int)
                            : null,
                        compact: true,
                        isHighlighted: isSelected,
                        isEnabled: isSelected,
                      ),
                    );
                  }).toList(),
                );
              }

              // Wide layout - show all venues in row with arrows
              final widgets = <Widget>[];
              for (int i = 0; i < allVenues.length; i++) {
                final venue = allVenues[i];
                final isSelected =
                    venueProvider.shouldShowVenue(venue['venueCode'] as String);

                // Add venue bookmark
                widgets.add(_buildBookmark(
                  icon: venue['icon'] as String,
                  label: venue['label'] as String,
                  date: venue['date'] as String,
                  onTap: isSelected
                      ? () => _scrollToTicket(venue['index'] as int)
                      : null,
                  isHighlighted: isSelected,
                  isEnabled: isSelected,
                ));

                // Add arrow between venues (not after the last one)
                if (i < allVenues.length - 1) {
                  widgets.add(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isMobile ? Icons.flight_land : Icons.flight_takeoff,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 20,
                          height: 1,
                          color: Colors.black54,
                        ),
                        const SizedBox(height: 2),
                        Icon(
                          isMobile ? Icons.south : Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ));
                }
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widgets,
              );
            },
          ),

          const SizedBox(height: 30),

          // Bride and Groom names section (moved above tickets)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 12.0 : (isMobile ? 16.0 : 24.0),
              vertical: isMobile ? 24.0 : 32.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${l10n.groom} · ${l10n.bride}',
                  style: TextStyle(
                    fontSize: isMobile ? 16.0 : 18.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: isMobile ? 1.0 : 2.0,
                  ),
                ),

                SizedBox(height: isMobile ? 16.0 : 20.0),

                // Couple names with flight ticket style
                Row(
                  children: [
                    // Groom section
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            l10n.groom.toUpperCase(),
                            style: TextStyle(
                              fontSize: isMobile ? 11.0 : 12.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 16,
                                vertical: isMobile ? 10 : 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              invitation.groomName.getText('en'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 14.0 : 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: isMobile ? 12.0 : 16.0),

                    // Bride section
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            l10n.bride.toUpperCase(),
                            style: TextStyle(
                              fontSize: isMobile ? 11.0 : 12.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 16,
                                vertical: isMobile ? 10 : 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCE4EC).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              invitation.brideName.getText('en'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 14.0 : 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 24.0 : 30.0),

          // Malaysia Dinner Party - September 12
          Consumer<VenueProvider>(
            builder: (context, venueProvider, child) {
              if (!venueProvider.shouldShowVenue('my'))
                return const SizedBox.shrink();
              return Container(
                key: _ticketKeys[0],
                child: _buildEventTicket(
                  eventTitle: l10n.dinnerParty,
                  date: '2025년 9월 12일 금요일',
                  location: '쿠안탄, 말레이시아',
                  locationSub: 'Kuantan, Malaysia',
                  time: '7:00 PM',
                  gradientColors: const [
                    Color(0xFFFFE0B2),
                    Color(0xFFFFCC02)
                  ], // Golden
                  flagIcon: '🇲🇾',
                  invitation: invitation,
                  mapIndex: 0, // Malaysia
                ),
              );
            },
          ),

          Consumer<VenueProvider>(
            builder: (context, venueProvider, child) {
              if (!venueProvider.shouldShowVenue('my'))
                return const SizedBox.shrink();
              return const SizedBox(height: 20);
            },
          ),

          // Singapore ROM - November 9
          Consumer<VenueProvider>(
            builder: (context, venueProvider, child) {
              if (!venueProvider.shouldShowVenue('sg'))
                return const SizedBox.shrink();
              return Container(
                key: _ticketKeys[1],
                child: _buildEventTicket(
                  eventTitle: l10n.registryOfMarriage,
                  date: '2025년 11월 9일 일요일',
                  location: '싱가폴',
                  locationSub: 'Singapore',
                  time: '7:00 PM',
                  gradientColors: const [
                    Color(0xFFE8F5E8),
                    Color(0xFF4CAF50)
                  ], // Green
                  flagIcon: '🇸🇬',
                  invitation: invitation,
                  mapIndex: 1, // Singapore
                ),
              );
            },
          ),

          Consumer<VenueProvider>(
            builder: (context, venueProvider, child) {
              if (!venueProvider.shouldShowVenue('sg'))
                return const SizedBox.shrink();
              return const SizedBox(height: 20);
            },
          ),

          // Korea Wedding - November 30
          Consumer<VenueProvider>(
            builder: (context, venueProvider, child) {
              if (!venueProvider.shouldShowVenue('ko'))
                return const SizedBox.shrink();
              return Container(
                key: _ticketKeys[2],
                child: _buildEventTicket(
                  eventTitle: l10n.afterParty,
                  date: '2025년 11월 30일 일요일',
                  location: '울산, 대한민국',
                  locationSub: 'Ulsan, South Korea',
                  time: '7:00 PM',
                  gradientColors: const [
                    Color(0xFFE3F2FD),
                    Color(0xFFBBDEFB)
                  ], // Blue
                  flagIcon: '🇰🇷',
                  invitation: invitation,
                  mapIndex: 2, // Korea
                ),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEventTicket({
    required String eventTitle,
    required String date,
    required String location,
    required String locationSub,
    required String time,
    required List<Color> gradientColors,
    required String flagIcon,
    required dynamic invitation,
    required int mapIndex, // 0: Malaysia, 1: Singapore, 2: Korea
  }) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Column(
            children: [
              // Header with boarding pass title
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.boardingPass.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        flagIcon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Event title below boarding pass
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          eventTitle,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 20 : 24),

              // Flight ticket style main section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Main info
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        Text(
                          l10n.date.toUpperCase(),
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: isMobile ? 16 : 20),

                        // Country
                        Text(
                          'COUNTRY',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getCountryName(mapIndex),
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Perforated line separator with flight icon
                  Container(
                    width: 2,
                    height: 100,
                    margin:
                        EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: List.generate(
                            20,
                            (index) => Container(
                              width: 2,
                              height: 3,
                              margin: const EdgeInsets.symmetric(vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                        // Flight icon in the middle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Icon(
                            isMobile ? Icons.flight_land : Icons.flight_takeoff,
                            size: isMobile ? 12 : 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side - Time and Venue
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TIME',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: isMobile ? 28 : 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        Text(
                          'VENUE',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getVenueCode(mapIndex),
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 16 : 20),

              // Detailed address section - full width
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADDRESS',
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDetailedAddress(mapIndex),
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 16 : 20),

              // Barcode placeholder
              Container(
                width: double.infinity,
                height: isMobile ? 25 : 30,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '|| ||| || |||| | ||| || | |||| ||| || | |||',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 10 : 12,
                      fontFamily: 'monospace',
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: isMobile ? 16 : 20),

              // Directions button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToMap(mapIndex),
                  icon: const Icon(Icons.location_on, size: 18),
                  label: Text(
                    l10n.directions,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection(weddingVenue) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final isKorean = locale.languageCode == 'ko';

    final List<Map<String, dynamic>> locations = [
      {
        'title': isKorean ? '쿠안탄, 말레이시아' : 'Kuantan, Malaysia',
        'subtitle': isKorean ? 'Kuantan, Malaysia' : '',
        'address':
            'AC Hotel Kuantan\nJalan Teluk Sisek\nKuantan, Pahang, Malaysia',
        'flagIcon': '🇲🇾',
        'color': const Color(0xFFFFCC02),
        'venue': 'AC Hotel Kuantan',
        'latitude': 3.8077,
        'longitude': 103.3260,
      },
      {
        'title': isKorean ? '싱가폴' : 'Singapore',
        'subtitle': isKorean ? 'Singapore' : '',
        'address': 'Arbora\n109 Mount Faber Road\nSingapore 099203',
        'flagIcon': '🇸🇬',
        'color': const Color(0xFF4CAF50),
        'venue': 'Arbora',
        'latitude': 1.273806,
        'longitude': 103.817497,
      },
      {
        'title': isKorean ? '울산, 대한민국' : 'Ulsan, South Korea',
        'subtitle': isKorean ? 'Ulsan, South Korea' : '',
        'address': isKorean
            ? '일월의정원\n울산광역시 울주군 두동면 은편리 891\nTel. 052-264-0891'
            : 'Garden of the Sun and the Moon\n891 Eunpyeon-ri, Dudong-myeon\nUlju-gun, Ulsan\nTel. 052-264-0891',
        'flagIcon': '🇰🇷',
        'color': const Color(0xFF2196F3),
        'venue': isKorean ? '일월의정원' : 'Garden of the Sun and the Moon',
        'latitude': 35.6288349,
        'longitude': 129.2087028,
      },
    ];

    return Container(
      key: _mapSectionKey,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            l10n.directions,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 2.0,
            ),
          ),

          const SizedBox(height: 30),

          // Location tabs - filter based on venue selection
          Consumer<VenueProvider>(
            builder: (context, venueProvider, child) {
              // Filter locations based on venue selection
              final filteredLocations =
                  locations.asMap().entries.where((entry) {
                final index = entry.key;
                final venueCode =
                    index == 0 ? 'my' : (index == 1 ? 'sg' : 'ko');
                return venueProvider.shouldShowVenue(venueCode);
              }).toList();

              // If no locations to show, return empty container
              if (filteredLocations.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F4),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: filteredLocations.map((entry) {
                    final int originalIndex = entry.key;
                    final int filteredIndex = filteredLocations.indexOf(entry);
                    final location = entry.value;
                    final bool isSelected = _selectedMapTab == filteredIndex;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMapTab = filteredIndex;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(21),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  location['flagIcon'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    location['title']
                                        .split(',')[0], // Show only city name
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          // Selected location details - also filter based on venue selection
          Consumer<VenueProvider>(builder: (context, venueProvider, child) {
            // Filter locations based on venue selection
            final filteredLocations = locations.asMap().entries.where((entry) {
              final index = entry.key;
              final venueCode = index == 0 ? 'my' : (index == 1 ? 'sg' : 'ko');
              return venueProvider.shouldShowVenue(venueCode);
            }).toList();

            // If no locations to show, return empty container
            if (filteredLocations.isEmpty) {
              return const SizedBox.shrink();
            }

            // Ensure _selectedMapTab is within bounds
            final currentIndex = _selectedMapTab < filteredLocations.length
                ? _selectedMapTab
                : 0;
            final currentLocation = filteredLocations[currentIndex].value;

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(currentIndex),
                child: Column(
                  children: [
                    Text(
                      currentLocation['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (currentLocation['subtitle'].isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        currentLocation['subtitle'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      currentLocation['address'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Map widget for selected location
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 480,
                        child: Theme.of(context).platform == TargetPlatform.iOS
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.map,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      currentLocation['venue'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      currentLocation['address'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : Consumer<VenueProvider>(
                                builder: (context, venueProvider, child) {
                                  final selectedVenue =
                                      venueProvider.selectedVenue;

                                  // Use venue-specific map provider
                                  MapProvider mapProvider =
                                      selectedVenue == 'ko'
                                          ? MapProvider.naver
                                          : MapProvider.google;

                                  return MultiMapWidget(
                                    latitude:
                                        currentLocation['latitude'] ?? 0.0,
                                    longitude:
                                        currentLocation['longitude'] ?? 0.0,
                                    venue: currentLocation['venue'] ?? '',
                                    provider: mapProvider,
                                    showControls: true,
                                    showDirections: true,
                                    height: 400,
                                    isEditMode: false,
                                  );
                                },
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Show navigation buttons only for Korea location
                    if (filteredLocations[currentIndex].key == 2) ...[
                      // Navigation apps title
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          l10n.navigationApps,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Navigation apps grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildNavigationButton(
                              l10n.kakaoNavi,
                              '🟡',
                              Colors.amber.shade600,
                              () => _openKakaoMap(
                                currentLocation['latitude'],
                                currentLocation['longitude'],
                                currentLocation['venue'],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildNavigationButton(
                              l10n.naverMap,
                              '🟢',
                              Colors.green.shade600,
                              () => _openNaverMap(
                                currentLocation['latitude'],
                                currentLocation['longitude'],
                                currentLocation['venue'],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildNavigationButton(
                              l10n.tmap,
                              '🔵',
                              Colors.blue.shade700,
                              () => _openTMap(
                                currentLocation['latitude'],
                                currentLocation['longitude'],
                                currentLocation['venue'],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGalleryPreview() {
    final l10n = AppLocalizations.of(context)!;
    // Featured wedding photos for preview - DSC series
    final List<String> galleryPhotos = [
      'assets/images/DSC07932.jpg',
      'assets/images/DSC07939.jpg',
      'assets/images/DSC07943.jpg',
      'assets/images/DSC07956.jpg',
      'assets/images/DSC08050.jpg',
      'assets/images/DSC08078.jpg',
      'assets/images/DSC08089.jpg',
      'assets/images/DSC08219.jpg',
      'assets/images/DSC08212.jpg',
      'assets/images/DSC08174.jpg',
      'assets/images/DSC08298.jpg',
      'assets/images/DSC08383.jpg',
      'assets/images/DSC08488.jpg',
      'assets/images/DSC08428.jpg',
      'assets/images/DSC08514.jpg',
      'assets/images/DSC08496.jpg',
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFFAF7F4),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            l10n.gallery,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD4A574),
              letterSpacing: 2.0,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            l10n.touchPhotoForFullGallery,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 30),

          // Auto-scrolling 2-row gallery preview similar to CSS animation
          AutoScrollGalleryPreview(
            imageUrls: galleryPhotos,
            height: 280,
            minItemHeight: 120,
            maxItemHeight: 200,
          ),

          const SizedBox(height: 20),

          // Alternative layouts (comment out above and uncomment one of these):

          // CSS Style continuous scrolling:
          // CSSStyleAutoScrollGallery(
          //   imageUrls: galleryPhotos,
          //   height: 280,
          // ),

          // Apple Watch style (previous implementation):
          // Center(
          //   child: AppleWatchGallery(
          //     imageUrls: galleryPhotos,
          //     size: 320,
          //   ),
          // ),

          TextButton.icon(
            onPressed: () => context.push('/gallery'),
            icon: const Icon(
              Icons.photo_library,
              size: 16,
              color: Color(0xFFD4A574),
            ),
            label: Text(
              l10n.viewAllPhotos,
              style: const TextStyle(
                color: Color(0xFFD4A574),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKoreanGuestbook() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            l10n.guestbook,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 30),
          if (_isLoadingMessages)
            const CircularProgressIndicator()
          else if (_messages.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.leaveFirstMessage,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Column(
              children: _messages
                  .take(3)
                  .map(
                    (message) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: GuestbookMessageCard(
                        message: message,
                        textColor: Colors.black87,
                        accentColor: const Color(0xFFD4A574),
                        onDelete: _handleDeleteMessage,
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showAddMessageDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A574),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.leaveCongratMessage,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.go('/guestbook'),
            child: Text(
              l10n.viewAllMessages,
              style: const TextStyle(
                color: Color(0xFFD4A574),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKoreanBankingSection() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      color: const Color(0xFFFAF7F4),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            l10n.whereToDonate,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 30),

          // Digital Payment Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  '간편결제 / Digital Payments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),

                // Korea section label
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Text(
                        '🇰🇷',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Korea',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // KakaoPay button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Replace this URL with your actual KakaoPay link
                          const String kakaopayUrl =
                              'https://qr.kakaopay.com/your_kakaopay_id';

                          try {
                            if (await canLaunchUrl(Uri.parse(kakaopayUrl))) {
                              await launchUrl(
                                Uri.parse(kakaopayUrl),
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              throw 'Could not launch $kakaopayUrl';
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('카카오페이 링크를 열 수 없습니다\n링크를 확인해주세요'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.brown.shade800,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              '카',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        label: const Text(
                          '카카오페이',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFE812),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // TossPay button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Replace this URL with your actual Toss link
                          const String tossUrl = 'https://toss.me/your_toss_id';

                          try {
                            if (await canLaunchUrl(Uri.parse(tossUrl))) {
                              await launchUrl(
                                Uri.parse(tossUrl),
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              throw 'Could not launch $tossUrl';
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('토스 링크를 열 수 없습니다\n링크를 확인해주세요'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3182F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              '토',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        label: const Text(
                          '토스',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3182F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Singapore section label
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Text(
                        '🇸🇬',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Singapore',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Malaysia section label
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Text(
                        '🇲🇾',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Malaysia',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Malaysian payment options
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // DuitNow QR button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // DuitNow QR or mobile number
                            // Replace with your actual DuitNow ID or mobile number
                            const String duitnowId =
                                '+60123456789'; // or account number

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'DuitNow ID: $duitnowId\n(수동으로 DuitNow 앱에 입력해 주세요)'),
                                  backgroundColor: Color(0xFF1E88E5),
                                  duration: Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                          icon: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E88E5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Text(
                                'D',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          label: const Text(
                            'DuitNow',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Touch 'n Go eWallet and GrabPay row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                const String tngUrl = 'touchngo://';

                                try {
                                  if (await canLaunchUrl(Uri.parse(tngUrl))) {
                                    await launchUrl(Uri.parse(tngUrl));
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Touch \'n Go eWallet 앱을 설치해 주세요'),
                                          backgroundColor: Color(0xFF1976D2),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Touch \'n Go eWallet 앱을 직접 열어주세요'),
                                        backgroundColor: Color(0xFF1976D2),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1976D2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Center(
                                  child: Text(
                                    'T',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              label: const Text(
                                'TnG',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                const String grabUrl = 'grab://';

                                try {
                                  if (await canLaunchUrl(Uri.parse(grabUrl))) {
                                    await launchUrl(Uri.parse(grabUrl));
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Grab 앱을 설치해 주세요'),
                                          backgroundColor: Color(0xFF00B14F),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Grab 앱을 직접 열어주세요'),
                                        backgroundColor: Color(0xFF00B14F),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00B14F),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Center(
                                  child: Text(
                                    'G',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              label: const Text(
                                'Grab',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B14F),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 1,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Text(
                        'DuitNow ID: +60 12 345 6789\n(Replace with your actual mobile number)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  '버튼을 누르면 간편결제 앱이 열립니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Traditional Bank Accounts Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: Text(
              '계좌이체',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          _buildBankAccountKorean(
              '신랑측', 'John Smith', 'KB국민은행', '123456789012'),
          _buildBankAccountKorean('신부측', 'Jane Doe', '신한은행', '987654321098'),
          _buildBankAccountKorean(
              '신랑 아버지', 'Robert Smith', 'NH농협은행', '456789123456'),
          _buildBankAccountKorean('신부 어머니', 'Mary Doe', '우리은행', '654321987654'),
        ],
      ),
    );
  }

  Widget _buildBankAccountKorean(
      String relation, String name, String bank, String account) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$relation $name',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Copy account number
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('계좌번호가 복사되었습니다'),
                      backgroundColor: Color(0xFFD4A574),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.copy,
                  size: 18,
                  color: Color(0xFFD4A574),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bank,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            account,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKoreanRSVPSection() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text(
            l10n.rsvp,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.willYouAttend,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.attendanceConfirmed),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: Text(l10n.attending),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.absenceConfirmed),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: Text(l10n.notAttending),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      color: const Color(0xFFFAF7F4),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 1,
            color: const Color(0xFFD4A574),
            margin: const EdgeInsets.only(bottom: 20),
          ),
          Text(
            l10n.invitingPreciousPeople,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 60,
            height: 1,
            color: const Color(0xFFD4A574),
          ),
        ],
      ),
    );
  }

  void _showAddMessageDialog() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  l10n.leaveCongratMessage,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.yourName,
                    hintText: l10n.enterYourName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterYourName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Message field
                TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: l10n.congratMessage,
                    hintText: l10n.enterCongratMessage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  maxLength: 200,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterCongratMessage;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: '삭제 비밀번호 (선택사항)',
                    hintText: '메시지 삭제시 필요한 비밀번호',
                    helperText: '나중에 메시지를 삭제하려면 비밀번호를 설정하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _addMessage();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A574),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.submit),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addMessage() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate() || _guestbookRepository == null) {
      return;
    }

    final message = GuestbookMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      message: _messageController.text.trim(),
      createdAt: DateTime.now(),
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
    );

    try {
      final success = await _guestbookRepository!.addMessage(message);
      if (success) {
        _nameController.clear();
        _messageController.clear();
        _passwordController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.messageSubmitted),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Scroll to specific ticket
  void _scrollToTicket(int index) {
    if (index < _ticketKeys.length) {
      final context = _ticketKeys[index].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          alignment: 0.1, // Position near top of screen
        );
      }
    }
  }

  // Navigate to map section with specific tab
  void _navigateToMap(int tabIndex) {
    setState(() {
      _selectedMapTab = tabIndex;
    });

    final context = _mapSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        alignment: 0.1, // Position near top of screen
      );
    }
  }

  Future<void> _handleDeleteMessage(String messageIdWithPassword) async {
    final parts = messageIdWithPassword.split('|');
    if (parts.length != 2) return;
    
    final messageId = parts[0];
    final password = parts[1];
    
    try {
      final success = await _guestbookRepository!.deleteMessageWithPassword(messageId, password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '메시지가 삭제되었습니다.' : '비밀번호가 일치하지 않습니다.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('삭제 중 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Launch URL helper
  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Build enhanced navigation button with icon
  Widget _buildNavigationButton(
      String title, String icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Build map navigation button (legacy)
  Widget _buildMapButton(String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Open Kakao Navi (Navigation)
  void _openKakaoMap(double latitude, double longitude, String venue) async {
    // Try Kakao Navi first for actual navigation
    final kakaonavi =
        Uri.parse('kakaonavi://navigate?ep=$longitude,$latitude&by=CAR');
    // Fallback to Kakao Map
    final kakaomap = Uri.parse('kakaomap://look?p=$latitude,$longitude');
    final webUrl = Uri.parse(
        'https://map.kakao.com/?q=${Uri.encodeComponent(venue)}&x=$longitude&y=$latitude');

    try {
      if (await canLaunchUrl(kakaonavi)) {
        await launchUrl(kakaonavi);
      } else if (await canLaunchUrl(kakaomap)) {
        await launchUrl(kakaomap);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      } else {
        // Redirect to app store if no Kakao apps available
        _showAppInstallDialog(
            '카카오내비',
            'https://play.google.com/store/apps/details?id=com.locnall.KimGiSa',
            'https://apps.apple.com/kr/app/kakaonavi/id417698849');
      }
    } catch (e) {
      debugPrint('Error opening Kakao navigation: $e');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      }
    }
  }

  // Open Naver Map with enhanced URL scheme
  void _openNaverMap(double latitude, double longitude, String venue) async {
    // Try Naver Map URL scheme first
    final appUrl = Uri.parse(
        'nmap://map?lat=$latitude&lng=$longitude&name=${Uri.encodeComponent(venue)}&zoom=15&appname=wedding_invitation');
    // Fallback to specific venue URL
    final webUrl = Uri.parse('https://naver.me/G7V4yE72');

    try {
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      } else {
        // Redirect to app store
        _showAppInstallDialog(
            '네이버맵',
            'https://play.google.com/store/apps/details?id=com.nhn.android.nmap',
            'https://apps.apple.com/kr/app/naver-map-navigation/id311867728');
      }
    } catch (e) {
      debugPrint('Error opening Naver Map: $e');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      }
    }
  }

  // Open T Map Navigation
  void _openTMap(double latitude, double longitude, String venue) async {
    // T Map URL scheme for navigation
    final appUrl = Uri.parse(
        'tmap://route?goalx=$longitude&goaly=$latitude&goalname=${Uri.encodeComponent(venue)}');
    // Alternative T Map scheme
    final altUrl = Uri.parse(
        'tmapapp://route?goalx=$longitude&goaly=$latitude&goalname=${Uri.encodeComponent(venue)}');

    try {
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else if (await canLaunchUrl(altUrl)) {
        await launchUrl(altUrl);
      } else {
        // Redirect to T Map app store
        _showAppInstallDialog(
            '티맵',
            'https://play.google.com/store/apps/details?id=com.skt.tmap.ku',
            'https://apps.apple.com/kr/app/t-map/id431589174');
      }
    } catch (e) {
      debugPrint('Error opening T Map: $e');
      _showAppInstallDialog(
          '티맵',
          'https://play.google.com/store/apps/details?id=com.skt.tmap.ku',
          'https://apps.apple.com/kr/app/t-map/id431589174');
    }
  }

  // Enhanced Google Maps with navigation
  void _openGoogleMaps(double latitude, double longitude, String venue) async {
    // Google Maps with navigation mode
    final appUrl = Uri.parse(
        'googlemaps://?daddr=$latitude,$longitude&directionsmode=driving');
    final webUrl = Uri.parse('https://maps.app.goo.gl/MEbVPxKa3UYWWGmj8');

    try {
      if (await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl);
      } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      }
    } catch (e) {
      debugPrint('Error opening Google Maps: $e');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl);
      }
    }
  }

  // Show app install dialog
  void _showAppInstallDialog(
      String appName, String playStoreUrl, String appStoreUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$appName 설치 필요'),
          content: Text('$appName이 설치되어 있지 않습니다. 앱을 설치하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final storeUrl =
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? appStoreUrl
                        : playStoreUrl;
                final url = Uri.parse(storeUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: const Text('설치'),
            ),
          ],
        );
      },
    );
  }

  // Get country name for boarding pass
  String _getCountryName(int mapIndex) {
    switch (mapIndex) {
      case 0: // Malaysia
        return 'MALAYSIA';
      case 1: // Singapore
        return 'SINGAPORE';
      case 2: // Korea
        return 'SOUTH KOREA';
      default:
        return 'COUNTRY';
    }
  }

  // Get detailed address for boarding pass
  String _getDetailedAddress(int mapIndex) {
    switch (mapIndex) {
      case 0: // Malaysia
        return 'AC Hotel Kuantan\nJalan Teluk Sisek, Kuantan, Pahang, Malaysia';
      case 1: // Singapore
        return 'Arbora\n109 Mount Faber Road, Singapore 099203';
      case 2: // Korea
        return '일월의정원\n울산광역시 울주군 두동면 은편리 891\nTel. 052-264-0891';
      default:
        return 'Address information';
    }
  }

  // Get venue code for boarding pass
  String _getVenueCode(int mapIndex) {
    switch (mapIndex) {
      case 0: // Malaysia
        return 'AC HOTEL';
      case 1: // Singapore
        return 'ARBORA';
      case 2: // Korea
        return '일월의정원';
      default:
        return 'VENUE';
    }
  }

  // Build bookmark navigation item
  Widget _buildBookmark({
    required String icon,
    required String label,
    required String date,
    VoidCallback? onTap,
    bool compact = false,
    bool isHighlighted = false,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: compact ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 12,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFFD63384).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isHighlighted
              ? Border.all(color: const Color(0xFFD63384), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isEnabled ? 0.08 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: compact
            ? Row(
                children: [
                  Opacity(
                    opacity: isEnabled ? 1.0 : 0.4,
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isEnabled
                                ? (isHighlighted
                                    ? const Color(0xFFD63384)
                                    : Colors.black87)
                                : Colors.grey.shade400,
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 10,
                            color: isEnabled
                                ? Colors.grey.shade600
                                : Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: isEnabled ? 1.0 : 0.4,
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isEnabled
                          ? (isHighlighted
                              ? const Color(0xFFD63384)
                              : Colors.black87)
                          : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 10,
                      color: isEnabled
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  const DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 2.0;

    const dashHeight = 8.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
