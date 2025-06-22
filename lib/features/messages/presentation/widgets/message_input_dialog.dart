import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';

class MessageInputDialog extends StatefulWidget {
  final Function(String name, String message) onSubmit;

  const MessageInputDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<MessageInputDialog> createState() => _MessageInputDialogState();
}

class _MessageInputDialogState extends State<MessageInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('축하 메시지 남기기'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                hintText: '홍길동',
              ),
              validator: Validators.validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: '축하 메시지',
                hintText: '결혼을 축하하는 따뜻한 메시지를 남겨주세요',
              ),
              maxLines: 4,
              validator: Validators.validateMessage,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(
                _nameController.text,
                _messageController.text,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('등록'),
        ),
      ],
    );
  }
}
