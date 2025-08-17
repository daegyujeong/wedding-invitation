import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/guestbook_message_model.dart';

class GuestbookMessageCard extends StatelessWidget {
  final GuestbookMessage message;
  final Color textColor;
  final Color accentColor;
  final bool isEditMode;
  final Function(String)? onDelete;

  const GuestbookMessageCard({
    super.key,
    required this.message,
    required this.textColor,
    required this.accentColor,
    this.isEditMode = false,
    this.onDelete,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
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
      return DateFormat('yyyy.MM.dd').format(date);
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
                backgroundColor: accentColor.withOpacity(0.1),
                backgroundImage: message.avatarUrl != null
                    ? NetworkImage(message.avatarUrl!)
                    : null,
                child: message.avatarUrl == null
                    ? Text(
                        message.name.isNotEmpty 
                            ? message.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
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
                          message.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        if (message.relationship != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getRelationshipColor(message.relationship),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message.relationship!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(message.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Delete button (edit mode only)
              if (isEditMode && onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  onPressed: () => onDelete!(message.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
              message.message,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: textColor.withOpacity(0.9),
              ),
            ),
          ),
          
          // Approval status (if not approved)
          if (!message.isApproved)
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
    );
  }
}