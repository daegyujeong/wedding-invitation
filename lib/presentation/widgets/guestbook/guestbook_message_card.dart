import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/guestbook_message_model.dart';

class GuestbookMessageCard extends StatefulWidget {
  final GuestbookMessage message;
  final Color textColor;
  final Color accentColor;
  final bool isEditMode;
  final Function(String)? onDelete;
  final bool isNewMessage;

  const GuestbookMessageCard({
    super.key,
    required this.message,
    required this.textColor,
    required this.accentColor,
    this.isEditMode = false,
    this.onDelete,
    this.isNewMessage = false,
  });

  @override
  State<GuestbookMessageCard> createState() => _GuestbookMessageCardState();
}

class _GuestbookMessageCardState extends State<GuestbookMessageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    // Start animation after a short delay if this is a new message
    if (widget.isNewMessage) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _animationController.forward();
      });
    } else {
      _animationController.value = 1.0; // Show immediately for existing messages
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    // Ensure we're working with local time for consistent comparison
    final localDate = date.toLocal();
    final now = DateTime.now();
    final difference = now.difference(localDate);

    // Handle negative differences (future dates) by showing absolute time
    if (difference.isNegative) {
      return DateFormat('yyyy.MM.dd HH:mm').format(localDate);
    }

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes <= 1) {
          return '방금 전';
        }
        return '${difference.inMinutes}분 전';
      }
      return '${difference.inHours}시간 전';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('yyyy.MM.dd').format(localDate);
    }
  }

  Color _getRelationshipColor(String? relationship) {
    switch (relationship?.toLowerCase()) {
      case '신랑측':
        return Colors.blue.shade100;
      case '신부측':
        return Colors.pink.shade100;
      case '친구':
        return Colors.green.shade100;
      case '직장동료':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
  
  void _showDeleteDialog() {
    final passwordController = TextEditingController();
    bool showPassword = false;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('메시지 삭제'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('이 메시지를 삭제하시겠습니까?'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      hintText: '메시지 작성시 설정한 비밀번호',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final password = passwordController.text.trim();
                    if (password.isNotEmpty) {
                      Navigator.of(context).pop();
                      widget.onDelete!('${widget.message.id}|$password');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('삭제'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name, relationship, and timestamp
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: widget.accentColor.withOpacity(0.1),
                backgroundImage: widget.message.avatarUrl != null
                    ? NetworkImage(widget.message.avatarUrl!)
                    : null,
                child: widget.message.avatarUrl == null
                    ? Text(
                        widget.message.name.isNotEmpty 
                            ? widget.message.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.accentColor,
                        ),
                      )
                    : null,
              ),
              
              const SizedBox(width: 12),
              
              // Name and relationship
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.message.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: widget.textColor,
                          ),
                        ),
                        if (widget.message.relationship != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getRelationshipColor(widget.message.relationship),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.message.relationship!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: widget.textColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(widget.message.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Delete button (if message has password)
              if (widget.message.password != null && widget.onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  onPressed: () => _showDeleteDialog(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: '메시지 삭제',
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Message content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.message.message,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: widget.textColor.withOpacity(0.9),
              ),
            ),
          ),
          
          // Approval status (if not approved)
          if (!widget.message.isApproved)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '승인 대기 중',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
        ],
      ),
          ),
        ),
      ),
    );
  }
}