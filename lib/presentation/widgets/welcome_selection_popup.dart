import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';
import '../../providers/venue_provider.dart';
import 'emoji_widget.dart';

class WelcomeSelectionPopup extends StatefulWidget {
  final VoidCallback onComplete;
  
  const WelcomeSelectionPopup({
    super.key,
    required this.onComplete,
  });

  @override
  State<WelcomeSelectionPopup> createState() => _WelcomeSelectionPopupState();
}

class _WelcomeSelectionPopupState extends State<WelcomeSelectionPopup> {
  String? _selectedVenue;
  Locale? _selectedLanguage;


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final venueProvider = Provider.of<VenueProvider>(context);
    
    // Get venue options
    final venueOptions = {
      'my': {
        'code': 'my',
        'name': 'Malaysia',
        'nameKo': '말레이시아',
        'flag': '🇲🇾',
        'date': 'Sep 12, 2025',
      },
      'sg': {
        'code': 'sg', 
        'name': 'Singapore',
        'nameKo': '싱가폴',
        'flag': '🇸🇬',
        'date': 'Nov 9, 2025',
      },
      'ko': {
        'code': 'ko',
        'name': 'South Korea', 
        'nameKo': '대한민국',
        'flag': '🇰🇷',
        'date': 'Nov 30, 2025',
      },
      'all': {
        'code': 'all',
        'name': 'All Events',
        'nameKo': '모든 행사',
        'flag': '🌍',
        'date': 'All Dates',
      },
    };

    return Material(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: screenWidth > 600 ? 500 : screenWidth * 0.9,
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Welcome title
                const EmojiWidget(
                  emoji: WeddingEmojis.celebration,
                  fontSize: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to Our Wedding\n저희 결혼식에 오신 것을 환영합니다',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please select which event you\'ll attend and your preferred language\n참석하실 행사와 원하는 언어를 선택해 주세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Venue selection
                const Text(
                  'Which event will you attend?\n어느 행사에 참석하시나요?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Venue options grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: venueOptions.entries.map((entry) {
                    final venue = entry.value;
                    final isSelected = _selectedVenue == venue['code'];
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedVenue = venue['code'];
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFFD63384) 
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected 
                              ? const Color(0xFFD63384).withOpacity(0.05)
                              : Colors.grey.shade50,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                venue['flag']!,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                venue['name']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected 
                                      ? const Color(0xFFD63384)
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                venue['date']!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                
                // Language selection
                const Text(
                  'Select Language\n언어를 선택해 주세요',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Language options
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: LocaleProvider.supportedLocales.map((locale) {
                    final isSelected = _selectedLanguage == locale;
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedLanguage = locale;
                        });
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFFD63384)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          color: isSelected 
                              ? const Color(0xFFD63384).withOpacity(0.05)
                              : Colors.grey.shade50,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              localeProvider.getFlag(locale),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              localeProvider.getDisplayName(locale),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected 
                                    ? const Color(0xFFD63384)
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                
                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_selectedVenue != null && _selectedLanguage != null)
                        ? () => _continueWithSelections()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD63384),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Continue to Wedding Invitation\n결혼식 초대장으로 이동',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Skip button
                TextButton(
                  onPressed: widget.onComplete,
                  child: Text(
                    'Skip and view all events\n건너뛰고 모든 행사 보기',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _continueWithSelections() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final venueProvider = Provider.of<VenueProvider>(context, listen: false);
    
    // Set selected language
    if (_selectedLanguage != null) {
      localeProvider.setLocale(_selectedLanguage!);
    }
    
    // Set selected venue
    if (_selectedVenue != null) {
      venueProvider.setVenue(_selectedVenue!);
    }
    
    // Update URL with query parameters
    final currentUri = GoRouterState.of(context).uri;
    final newQuery = <String, String>{};
    
    // Add existing query parameters
    currentUri.queryParameters.forEach((key, value) {
      if (key != 'ln' && key != 'venue') {
        newQuery[key] = value;
      }
    });
    
    // Add new parameters
    if (_selectedLanguage != null) {
      newQuery['ln'] = _selectedLanguage!.languageCode;
    }
    if (_selectedVenue != null) {
      newQuery['venue'] = _selectedVenue!;
    }
    
    // Construct new URL
    final newUri = currentUri.replace(queryParameters: newQuery);
    
    // Navigate to updated URL
    context.go(newUri.toString());
    
    // Complete the popup
    widget.onComplete();
  }
}