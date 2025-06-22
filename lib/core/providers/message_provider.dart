import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/supabase_service.dart';
import 'invitation_provider.dart';

final messagesProvider = FutureProvider.family<List<MessageModel>, String>(
  (ref, invitationId) async {
    final service = ref.watch(supabaseServiceProvider);
    return await service.getMessages(invitationId);
  },
);

final createMessageProvider = FutureProvider.family<MessageModel, Map<String, String>>(
  (ref, params) async {
    final service = ref.watch(supabaseServiceProvider);
    final message = await service.createMessage(
      params['invitationId']!,
      params['name']!,
      params['message']!,
    );
    ref.invalidate(messagesProvider(params['invitationId']!));
    return message;
  },
);

final likeMessageProvider = FutureProvider.family<void, Map<String, String>>(
  (ref, params) async {
    final service = ref.watch(supabaseServiceProvider);
    await service.likeMessage(params['messageId']!);
    ref.invalidate(messagesProvider(params['invitationId']!));
  },
);
