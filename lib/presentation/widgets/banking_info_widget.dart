import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class BankingInfoWidget extends StatefulWidget {
  final List<BankAccount> accounts;
  final String title;
  final bool showCopyButton;
  final bool showQRCode;
  final EdgeInsetsGeometry? padding;
  final bool useExpandableGroups;

  const BankingInfoWidget({
    super.key,
    required this.accounts,
    this.title = '마음 전하실 곳',
    this.showCopyButton = true,
    this.showQRCode = false,
    this.padding,
    this.useExpandableGroups = false,
  });

  @override
  State<BankingInfoWidget> createState() => _BankingInfoWidgetState();
}

class _BankingInfoWidgetState extends State<BankingInfoWidget> {
  String? _copiedAccountNumber;

  void _copyToClipboard(String text, String accountNumber) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _copiedAccountNumber = accountNumber;
    });
    
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('계좌번호가 복사되었습니다: $accountNumber'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
    
    // Reset copied state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copiedAccountNumber = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade50,
            Colors.orange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Account list
          ...widget.accounts.map((account) => _buildAccountCard(account)),
          
          if (widget.accounts.isNotEmpty) const SizedBox(height: 16),
          
          // Information note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.shade200,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '축하의 마음을 전해주시는 모든 분들께 감사드립니다.\n계좌번호 터치 시 복사됩니다.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade700,
                      height: 1.4,
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

  Widget _buildAccountCard(BankAccount account) {
    final isCopied = _copiedAccountNumber == account.accountNumber;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCopied ? Colors.green.shade300 : Colors.orange.shade200,
          width: isCopied ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Owner name and relationship
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRelationshipColor(account.relationship),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    account.relationship,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getRelationshipTextColor(account.relationship),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    account.ownerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Bank info and account number
            Row(
              children: [
                // Bank logo/icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getBankColor(account.bankName),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _getBankInitial(account.bankName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Bank name and account number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.bankName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: widget.showCopyButton 
                            ? () => _copyToClipboard(account.accountNumber, account.accountNumber)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  account.formattedAccountNumber,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isCopied ? Colors.green.shade700 : Colors.black87,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              if (widget.showCopyButton) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  isCopied ? Icons.check_circle : Icons.copy,
                                  size: 18,
                                  color: isCopied ? Colors.green.shade600 : Colors.grey.shade600,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // KakaoTalk Pay button if available
            if (account.kakaoPayLink != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement KakaoTalk Pay integration
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('카카오페이 송금 기능은 준비 중입니다.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE812),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.chat_bubble, size: 20),
                  label: const Text(
                    '카카오페이로 송금하기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRelationshipColor(String relationship) {
    switch (relationship) {
      case '신랑':
      case '신랑 아버지':
      case '신랑 어머니':
        return Colors.blue.shade100;
      case '신부':
      case '신부 아버지':  
      case '신부 어머니':
        return Colors.pink.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getRelationshipTextColor(String relationship) {
    switch (relationship) {
      case '신랑':
      case '신랑 아버지':
      case '신랑 어머니':
        return Colors.blue.shade700;
      case '신부':
      case '신부 아버지':
      case '신부 어머니':
        return Colors.pink.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getBankColor(String bankName) {
    switch (bankName.toLowerCase()) {
      case 'kb국민은행':
      case '국민은행':
        return const Color(0xFF6B4C93);
      case '신한은행':
        return const Color(0xFF0066CC);
      case '우리은행':
        return const Color(0xFF1E88E5);
      case 'nh농협은행':
      case '농협은행':
        return const Color(0xFF4CAF50);
      case '하나은행':
        return const Color(0xFF00A651);
      case 'ibk기업은행':
      case '기업은행':
        return const Color(0xFF003366);
      case '카카오뱅크':
        return const Color(0xFFFFE812);
      case '토스뱅크':
        return const Color(0xFF0064FF);
      default:
        return Colors.grey.shade600;
    }
  }

  String _getBankInitial(String bankName) {
    if (bankName.contains('국민')) return 'KB';
    if (bankName.contains('신한')) return '신';
    if (bankName.contains('우리')) return '우';
    if (bankName.contains('농협') || bankName.contains('NH')) return 'NH';
    if (bankName.contains('하나')) return '하';
    if (bankName.contains('기업') || bankName.contains('IBK')) return 'IBK';
    if (bankName.contains('카카오')) return 'K';
    if (bankName.contains('토스')) return 'T';
    return bankName.isNotEmpty ? bankName[0] : '은';
  }
}

class BankAccount {
  final String bankName;
  final String accountNumber;
  final String ownerName;
  final String relationship;
  final String? kakaoPayLink;

  BankAccount({
    required this.bankName,
    required this.accountNumber,
    required this.ownerName,
    required this.relationship,
    this.kakaoPayLink,
  });

  String get formattedAccountNumber {
    // Format account number with spaces for better readability
    if (accountNumber.length <= 4) return accountNumber;
    
    final buffer = StringBuffer();
    for (int i = 0; i < accountNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(accountNumber[i]);
    }
    return buffer.toString();
  }
}