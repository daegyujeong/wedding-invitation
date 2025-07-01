import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

// Wedding Header with elegant design
class WeddingHeader extends StatelessWidget {
  final String backgroundImage;
  final String groomName;
  final String brideName;
  final DateTime weddingDate;
  final String venue;

  const WeddingHeader({
    super.key,
    required this.backgroundImage,
    required this.groomName,
    required this.brideName,
    required this.weddingDate,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.pink.shade50,
            Colors.pink.shade100.withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade200.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: FloralPatternPainter(),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decorative element
                Container(
                  width: 80,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.pink.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Wedding announcement
                Text(
                  '결혼합니다',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.pink.shade700,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Names with heart
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        groomName,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          color: Colors.pink.shade800,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.pink.shade400,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        brideName,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          color: Colors.pink.shade800,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Date
                Text(
                  DateFormat('yyyy년 MM월 dd일', 'ko_KR').format(weddingDate),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.pink.shade600,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Venue
                Text(
                  venue,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.pink.shade500,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Decorative element
                Container(
                  width: 80,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.pink.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Wedding Invitation Card
class WeddingInvitationCard extends StatelessWidget {
  final String greetingText;

  const WeddingInvitationCard({
    super.key,
    required this.greetingText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade100.withOpacity(0.6),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Decorative top element
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 3; i++) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
                if (i < 2) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 20),
          
          // Greeting text
          Text(
            greetingText,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Decorative bottom element
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 3; i++) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
                if (i < 2) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Wedding Countdown
class WeddingCountdown extends StatelessWidget {
  final Duration timeUntilWedding;

  const WeddingCountdown({
    super.key,
    required this.timeUntilWedding,
  });

  @override
  Widget build(BuildContext context) {
    final days = timeUntilWedding.inDays;
    final hours = timeUntilWedding.inHours.remainder(24);
    final minutes = timeUntilWedding.inMinutes.remainder(60);
    final seconds = timeUntilWedding.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.pink.shade50,
            Colors.pink.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.pink.shade100,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '결혼식까지 남은 시간',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.pink.shade700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeUnit(days, '일', Colors.pink.shade600),
              _buildTimeUnit(hours, '시간', Colors.pink.shade500),
              _buildTimeUnit(minutes, '분', Colors.pink.shade400),
              _buildTimeUnit(seconds, '초', Colors.pink.shade300),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Wedding Details
class WeddingDetails extends StatelessWidget {
  final DateTime weddingDate;
  final String venue;

  const WeddingDetails({
    super.key,
    required this.weddingDate,
    required this.venue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today,
            color: Colors.pink.shade400,
            size: 32,
          ),
          const SizedBox(height: 16),
          
          Text(
            DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(weddingDate),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            DateFormat('aa hh시 mm분', 'ko_KR').format(weddingDate),
            style: TextStyle(
              fontSize: 18,
              color: Colors.pink.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          
          Divider(
            color: Colors.pink.shade100,
            thickness: 1,
          ),
          const SizedBox(height: 16),
          
          Icon(
            Icons.location_on,
            color: Colors.pink.shade400,
            size: 28,
          ),
          const SizedBox(height: 8),
          
          Text(
            venue,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Wedding Navigation Buttons
class WeddingNavigationButtons extends StatelessWidget {
  final VoidCallback onGalleryPressed;
  final VoidCallback onLocationPressed;
  final VoidCallback onMessagePressed;
  final VoidCallback onEditorPressed;

  const WeddingNavigationButtons({
    super.key,
    required this.onGalleryPressed,
    required this.onLocationPressed,
    required this.onMessagePressed,
    required this.onEditorPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '메뉴',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.pink.shade700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              icon: Icons.photo_library,
              label: '갤러리',
              color: Colors.pink.shade400,
              onPressed: onGalleryPressed,
            ),
            _buildNavButton(
              icon: Icons.location_on,
              label: '오시는 길',
              color: Colors.orange.shade400,
              onPressed: onLocationPressed,
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              icon: Icons.message,
              label: '축하 메시지',
              color: Colors.purple.shade400,
              onPressed: onMessagePressed,
            ),
            _buildNavButton(
              icon: Icons.edit,
              label: '에디터',
              color: Colors.blue.shade400,
              onPressed: onEditorPressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 140,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for floral pattern
class FloralPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pink.shade100.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    for (int i = 0; i < 20; i++) {
      final x = (i * 50.0) % size.width;
      final y = (i * 30.0) % size.height;
      final radius = (i % 3 + 1) * 2.0;
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }

    // Draw curved lines
    final path = Path();
    final linePaint = Paint()
      ..color = Colors.pink.shade200.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 5; i++) {
      path.reset();
      final startY = (i * size.height / 5);
      path.moveTo(0, startY);
      
      for (double x = 0; x <= size.width; x += 20) {
        final y = startY + math.sin(x / 50) * 20;
        path.lineTo(x, y);
      }
      
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}