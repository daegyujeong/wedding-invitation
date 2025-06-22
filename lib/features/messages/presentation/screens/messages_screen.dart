import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/utils/date_formatter.dart';
import '../widgets/message_card.dart';
import '../widgets/message_input_dialog.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  final String invitationId;

  const MessagesScreen({
    super.key,
    required this.invitationId,
  });

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'name': '친구1',
      'message': '결혼 축하해! 행복하게 잘 살아~',
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      'likes': 5,
    },
    {
      'id': '2',
      'name': '친구2',
      'message': '예쁘게 잘 살아요 ♥',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      'likes': 3,
    },
  ];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('축하 메시지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: _showMessageInputDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: '메시지를 불러오고 있습니다...')
          : _messages.isEmpty
              ? EmptyWidget(
                  title: '아직 축하 메시지가 없어요',
                  subtitle: '첫 번째 축하 메시지를 남겨주세요',
                  icon: Icons.message_outlined,
                  action: ElevatedButton.icon(
                    onPressed: _showMessageInputDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('메시지 남기기'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return MessageCard(
                      message: message,
                      onLike: () => _toggleLike(message['id']),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMessageInputDialog,
        child: const Icon(Icons.edit),
      ),
    );
  }

  void _showMessageInputDialog() {
    showDialog(
      context: context,
      builder: (context) => MessageInputDialog(
        onSubmit: (name, message) {
          setState(() {
            _messages.insert(0, {
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'name': name,
              'message': message,
              'createdAt': DateTime.now(),
              'likes': 0,
            });
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('메시지가 등록되었습니다')),
          );
        },
      ),
    );
  }

  void _toggleLike(String messageId) {
    setState(() {
      final index = _messages.indexWhere((m) => m['id'] == messageId);
      if (index != -1) {
        _messages[index]['likes'] = (_messages[index]['likes'] as int) + 1;
      }
    });
  }
}
