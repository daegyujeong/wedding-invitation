import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'emoji_widget.dart';

class ExpandableBankingWidget extends StatefulWidget {
  const ExpandableBankingWidget({super.key});

  @override
  State<ExpandableBankingWidget> createState() => _ExpandableBankingWidgetState();
}

class _ExpandableBankingWidgetState extends State<ExpandableBankingWidget> {
  // Banking information data - only groom accounts
  final List<BankAccountInfo> _bankAccounts = [
    BankAccountInfo(
      relation: '신랑',
      bank: '국민은행',
      accountNumber: '67500204110684',
      accountHolder: '정대규',
      hasKakaoPay: true,
      kakaoPayUrl: 'https://qr.kakaopay.com/Ej8dP67xX',
    ),
    BankAccountInfo(
      relation: '신랑 아버지',
      bank: '농협',
      accountNumber: '81511352032161',
      accountHolder: '정주상',
      hasKakaoPay: true,
      kakaoPayUrl: 'https://qr.kakaopay.com/FIkfulbWX',
    ),
    BankAccountInfo(
      relation: '신랑 어머니',
      bank: '농협',
      accountNumber: '81511352001378',
      accountHolder: '최윤교',
      hasKakaoPay: true,
      kakaoPayUrl: 'https://qr.kakaopay.com/FG5tDxJLx',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFAF7F4),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          // Section icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: EmojiWidget(
                emoji: WeddingEmojis.flower,
                fontSize: 36,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          const Text(
            '축하의 마음 전하기',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            '축하의 마음을 담아 축의금을 전달해 보세요.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Banking accounts - always expanded
          Container(
            width: double.infinity,
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title
                  const Text(
                    '계좌번호',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Account items
                  ..._bankAccounts.map((account) => _buildAccountItem(account)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAccountItem(BankAccountInfo account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Relation and name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.relation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    account.accountHolder,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (account.hasKakaoPay)
                _buildKakaoPayButton(account),
            ],
          ),
          const SizedBox(height: 12),
          
          // Bank and account info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.bank,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.accountNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _copyToClipboard(account.accountNumber),
                icon: Icon(
                  Icons.copy_outlined,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                tooltip: '복사하기',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKakaoPayButton(BankAccountInfo account) {
    return InkWell(
      onTap: () => _openKakaoPay(account),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE500),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EmojiWidget(
              emoji: WeddingEmojis.yellowHeart,
              fontSize: 12,
            ),
            const SizedBox(width: 4),
            const Text(
              'pay',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('계좌번호가 복사되었습니다'),
          backgroundColor: const Color(0xFFD4A574),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openKakaoPay(BankAccountInfo account) async {
    // Use the specific Kakao Pay URL for this account
    if (account.kakaoPayUrl == null) {
      debugPrint('No Kakao Pay URL available for this account');
      return;
    }
    
    final kakaoPayUrl = Uri.parse(account.kakaoPayUrl!);
    
    try {
      if (await canLaunchUrl(kakaoPayUrl)) {
        await launchUrl(kakaoPayUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback - show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('카카오페이 링크를 열 수 없습니다'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening Kakao Pay: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('카카오페이 링크 오류가 발생했습니다'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class BankAccountInfo {
  final String relation;
  final String bank;
  final String accountNumber;
  final String accountHolder;
  final bool hasKakaoPay;
  final String? kakaoPayUrl;

  BankAccountInfo({
    required this.relation,
    required this.bank,
    required this.accountNumber,
    required this.accountHolder,
    this.hasKakaoPay = false,
    this.kakaoPayUrl,
  });
}