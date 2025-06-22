import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareScreen extends ConsumerWidget {
  final String invitationId;

  const ShareScreen({
    super.key,
    required this.invitationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitationUrl = 'https://wedding-invitation.com/invite/$invitationId';
    final shareMessage = '홍길동 ♥ 김영희\n\n소중한 분들을 모시고 새로운 시작을 하려 합니다.\n\n2024년 12월 25일 수요일 오후 2시\n더 플라자 호텔 그랜드볼룸\n\n모바일 청첩장: $invitationUrl';

    return Scaffold(
      appBar: AppBar(
        title: const Text('공유하기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // QR Code
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'QR 코드',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: invitationUrl,
                    version: QrVersions.auto,
                    size: 200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'QR 코드를 스캔하면\n모바일 청첩장을 볼 수 있어요',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // URL Copy
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '링크 복사',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            invitationUrl,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: invitationUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('링크가 복사되었습니다')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Share buttons
            Text(
              'SNS 공유',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
              children: [
                _buildShareButton(
                  context,
                  icon: Icons.chat,
                  label: '카카오톡',
                  color: const Color(0xFFFEE500),
                  onTap: () => _shareToKakao(invitationUrl, shareMessage),
                ),
                _buildShareButton(
                  context,
                  icon: Icons.message,
                  label: '문자',
                  color: Colors.green,
                  onTap: () => _shareToSMS(shareMessage),
                ),
                _buildShareButton(
                  context,
                  icon: Icons.link,
                  label: 'URL',
                  color: Colors.blue,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: invitationUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('링크가 복사되었습니다')),
                    );
                  },
                ),
                _buildShareButton(
                  context,
                  icon: Icons.facebook,
                  label: '페이스북',
                  color: const Color(0xFF1877F2),
                  onTap: () => _shareToFacebook(invitationUrl),
                ),
                _buildShareButton(
                  context,
                  icon: Icons.camera_alt,
                  label: '인스타그램',
                  color: const Color(0xFFE4405F),
                  onTap: () => _shareToInstagram(),
                ),
                _buildShareButton(
                  context,
                  icon: Icons.more_horiz,
                  label: '기타',
                  color: Colors.grey,
                  onTap: () => _shareToOther(shareMessage),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareToKakao(String url, String message) async {
    // TODO: Implement Kakao SDK
    final kakaoUrl = Uri.parse('kakaolink://send?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(kakaoUrl)) {
      await launchUrl(kakaoUrl);
    } else {
      // Fallback
      _shareToOther(message);
    }
  }

  Future<void> _shareToSMS(String message) async {
    final smsUrl = Uri.parse('sms:?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(smsUrl)) {
      await launchUrl(smsUrl);
    }
  }

  Future<void> _shareToFacebook(String url) async {
    final fbUrl = Uri.parse('https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}');
    if (await canLaunchUrl(fbUrl)) {
      await launchUrl(fbUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _shareToInstagram() {
    // Instagram doesn't support direct URL sharing
    // Show instruction instead
    // TODO: Implement Instagram story sharing with image
  }

  void _shareToOther(String message) {
    // TODO: Use share_plus package for native sharing
  }
}
