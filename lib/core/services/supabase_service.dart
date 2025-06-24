import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invitation_model.dart';
import '../models/message_model.dart';
import '../models/template_model.dart';

import 'package:uuid/uuid.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final _uuid = const Uuid();

  // Auth methods
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Invitation methods
  Future<List<InvitationModel>> getMyInvitations() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('invitations')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => InvitationModel.fromJson(json))
        .toList();
  }

  Future<InvitationModel?> getInvitation(String id) async {
    final response =
        await _client.from('invitations').select().eq('id', id).single();

    return InvitationModel.fromJson(response);
  }

  Future<InvitationModel> createInvitation(InvitationModel invitation) async {
    final newInvitation = invitation.copyWith(
      id: _uuid.v4(),
      userId: currentUser?.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final response = await _client
        .from('invitations')
        .insert(newInvitation.toJson())
        .select()
        .single();

    return InvitationModel.fromJson(response);
  }

  Future<InvitationModel> updateInvitation(InvitationModel invitation) async {
    final response = await _client
        .from('invitations')
        .update(invitation.copyWith(updatedAt: DateTime.now()).toJson())
        .eq('id', invitation.id)
        .select()
        .single();

    return InvitationModel.fromJson(response);
  }

  Future<void> deleteInvitation(String id) async {
    await _client.from('invitations').delete().eq('id', id);
  }

  // Message methods
  Future<List<MessageModel>> getMessages(String invitationId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('invitation_id', invitationId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => MessageModel.fromJson(json))
        .toList();
  }

  Future<MessageModel> createMessage(
      String invitationId, String name, String message) async {
    final newMessage = MessageModel(
      id: _uuid.v4(),
      invitationId: invitationId,
      name: name,
      message: message,
      likes: 0,
      createdAt: DateTime.now(),
    );

    final response = await _client
        .from('messages')
        .insert(newMessage.toJson())
        .select()
        .single();

    return MessageModel.fromJson(response);
  }

  Future<void> likeMessage(String messageId) async {
    await _client
        .rpc('increment_message_likes', params: {'message_id': messageId});
  }

  // Template methods
  Future<List<TemplateModel>> getTemplates() async {
    final response = await _client
        .from('templates')
        .select()
        .eq('is_active', true)
        .order('name');

    return (response as List)
        .map((json) => TemplateModel.fromJson(json))
        .toList();
  }

  // Storage methods
  Future<String> uploadImage(
      String bucket, String path, List<int> fileBytes) async {
    final fileName = '${_uuid.v4()}.jpg';
    final filePath = '$path/$fileName';

    await _client.storage
        .from(bucket)
        .uploadBinary(filePath, Uint8List.fromList(fileBytes));

    return _client.storage.from(bucket).getPublicUrl(filePath);
  }

  Future<void> deleteImage(String bucket, String filePath) async {
    await _client.storage.from(bucket).remove([filePath]);
  }
}
