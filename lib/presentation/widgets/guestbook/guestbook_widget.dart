import 'package:flutter/material.dart';
import '../../../data/models/editor_widget_model.dart';
import '../../../data/models/guestbook_message_model.dart';
import '../../../data/repositories/guestbook_repository.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../data/repositories/interfaces/guestbook_repository.dart';
import 'guestbook_message_card.dart';
import 'add_message_dialog.dart';

class GuestbookWidgetRenderer extends StatefulWidget {
  final GuestbookWidget widget;
  final bool isEditMode;

  const GuestbookWidgetRenderer({
    super.key,
    required this.widget,
    this.isEditMode = false,
  });

  @override
  State<GuestbookWidgetRenderer> createState() => _GuestbookWidgetRendererState();
}

class _GuestbookWidgetRendererState extends State<GuestbookWidgetRenderer> {
  late final IGuestbookRepository _repository;
  List<GuestbookMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = serviceLocator<IGuestbookRepository>();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = widget.widget.requireModeration
          ? await _repository.getApprovedMessages()
          : await _repository.getMessages();
      
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메시지를 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _addMessage() async {
    if (widget.isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('편집 모드에서는 메시지를 추가할 수 없습니다')),
      );
      return;
    }

    final result = await showDialog<GuestbookMessage>(
      context: context,
      builder: (context) => AddMessageDialog(
        allowAnonymous: widget.widget.allowAnonymous,
        maxLength: widget.widget.maxMessageLength,
        accentColor: _parseColor(widget.widget.accentColor),
      ),
    );

    if (result != null) {
      final success = await _repository.addMessage(result);
      if (success) {
        await _loadMessages();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('축하 메시지가 등록되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('메시지 등록에 실패했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _parseColor(widget.widget.backgroundColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.widget.title.getText('ko'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _parseColor(widget.widget.textColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.widget.description.getText('ko'),
                      style: TextStyle(
                        fontSize: 14,
                        color: _parseColor(widget.widget.textColor).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.isEditMode)
                FloatingActionButton.small(
                  onPressed: _addMessage,
                  backgroundColor: _parseColor(widget.widget.accentColor),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Messages
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_messages.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '아직 축하 메시지가 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (!widget.isEditMode) ...[
                    const SizedBox(height: 8),
                    Text(
                      '첫 번째 축하 메시지를 남겨보세요!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            )
          else
            Column(
              children: [
                // Message count
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '총 ${_messages.length}개의 축하 메시지',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _parseColor(widget.widget.textColor).withOpacity(0.7),
                    ),
                  ),
                ),
                
                // Messages list
                ...List.generate(_messages.length, (index) {
                  final message = _messages[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < _messages.length - 1 ? 12 : 0,
                    ),
                    child: GuestbookMessageCard(
                      message: message,
                      textColor: _parseColor(widget.widget.textColor),
                      accentColor: _parseColor(widget.widget.accentColor),
                      isEditMode: widget.isEditMode,
                      onDelete: (messageIdWithPassword) async {
                        // Parse messageId and password
                        final parts = messageIdWithPassword.split('|');
                        if (parts.length != 2) return;
                        
                        final messageId = parts[0];
                        final password = parts[1];
                        
                        final success = await _repository.deleteMessageWithPassword(messageId, password);
                        if (success) {
                          await _loadMessages();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('메시지가 삭제되었습니다'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('비밀번호가 일치하지 않습니다'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }
}