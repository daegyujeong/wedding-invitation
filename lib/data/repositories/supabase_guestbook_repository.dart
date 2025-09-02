import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../models/guestbook_message_model.dart';
import '../services/supabase_service.dart';
import 'interfaces/guestbook_repository.dart';

class SupabaseGuestbookRepository implements IGuestbookRepository {
  static const String _tableName = 'guestbook_messages';
  final _logger = Logger();
  
  // Stream controllers for real-time updates
  final StreamController<List<GuestbookMessage>> _messagesController = 
      StreamController<List<GuestbookMessage>>.broadcast();
  final StreamController<int> _messageCountController = 
      StreamController<int>.broadcast();
  
  // Supabase realtime subscription
  RealtimeChannel? _realtimeChannel;
  
  // Cache for messages
  List<GuestbookMessage>? _cachedMessages;
  
  SupabaseGuestbookRepository() {
    if (SupabaseService.isAvailable) {
      // Initialize realtime with error handling
      try {
        _initializeRealtimeSubscription();
        _logger.i('Guestbook repository initialized with realtime');
      } catch (e) {
        _logger.w('Failed to initialize realtime for Guestbook: $e');
        _logger.i('Guestbook repository will work without realtime updates');
      }
    } else {
      _logger.w('Supabase not available - repository will use local cache only');
    }
  }
  
  // Get Supabase client
  SupabaseClient? get _client {
    if (!SupabaseService.isAvailable) {
      return null;
    }
    return SupabaseService.instance.client;
  }
  
  // Initialize real-time subscription
  void _initializeRealtimeSubscription() {
    try {
      final client = _client;
      if (client == null) {
        _logger.w('Cannot initialize realtime subscription - Supabase not available');
        return;
      }
      
      _realtimeChannel = client
          .channel('public:$_tableName')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: _tableName,
            callback: (payload) {
              _logger.i('Realtime event: ${payload.eventType}');
              // Refresh messages when any change occurs
              getMessages();
            },
          );
          
      // Subscribe with error handling
      _realtimeChannel?.subscribe((status, error) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          _logger.i('Realtime subscription successful for $_tableName');
        } else if (status == RealtimeSubscribeStatus.channelError) {
          _logger.w('Realtime subscription error for $_tableName: $error - continuing without realtime');
        }
      });
          
    } catch (e) {
      _logger.w('Failed to initialize realtime subscription: $e - continuing without realtime');
    }
  }
  
  @override
  Future<List<GuestbookMessage>> getMessages() async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - returning cached messages');
      return _cachedMessages ?? [];
    }
    
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('is_deleted', false)
          .order('created_at', ascending: false);
      
      final messages = (response as List)
          .map((json) => GuestbookMessage.fromSupabase(json))
          .toList();
      
      _cachedMessages = messages;
      _notifyStreams();
      return messages;
    } catch (e) {
      _logger.e('Error loading guestbook messages from Supabase: $e');
      return _cachedMessages ?? [];
    }
  }
  
  @override
  Future<bool> addMessage(GuestbookMessage message) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - cannot add message');
      return false;
    }
    
    try {
      await client.from(_tableName).insert({
        'id': message.id,
        'name': message.name,
        'message': message.message,
        'relationship': message.relationship,
        'is_approved': message.isApproved,
        'is_deleted': message.isDeleted,
        'password': message.password,
        'avatar_url': message.avatarUrl,
        'created_at': message.createdAt.toIso8601String(),
      });
      
      // Refresh messages to update cache
      await getMessages();
      return true;
    } catch (e) {
      _logger.e('Error adding guestbook message to Supabase: $e');
      return false;
    }
  }
  
  @override
  Future<bool> updateMessage(GuestbookMessage updatedMessage) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - cannot update message');
      return false;
    }
    
    try {
      await client
          .from(_tableName)
          .update({
            'name': updatedMessage.name,
            'message': updatedMessage.message,
            'relationship': updatedMessage.relationship,
            'is_approved': updatedMessage.isApproved,
            'avatar_url': updatedMessage.avatarUrl,
          })
          .eq('id', updatedMessage.id);
      
      // Refresh messages to update cache
      await getMessages();
      return true;
    } catch (e) {
      _logger.e('Error updating guestbook message in Supabase: $e');
      return false;
    }
  }
  
  @override
  Future<bool> deleteMessage(String messageId) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - cannot delete message');
      return false;
    }
    
    try {
      await client
          .from(_tableName)
          .delete()
          .eq('id', messageId);
      
      // Refresh messages to update cache
      await getMessages();
      return true;
    } catch (e) {
      _logger.e('Error deleting guestbook message from Supabase: $e');
      return false;
    }
  }
  
  @override
  Future<bool> deleteMessageWithPassword(String messageId, String password) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - cannot delete message');
      return false;
    }
    
    try {
      // Call the Supabase function for password-protected deletion
      final response = await client
          .rpc('delete_message_with_password', params: {
            'message_id': messageId,
            'user_password': password,
          });
      
      final success = response as bool;
      
      if (success) {
        // Refresh messages to update cache
        await getMessages();
        _logger.i('Message deleted successfully with password verification');
      } else {
        _logger.w('Failed to delete message - invalid password');
      }
      
      return success;
    } catch (e) {
      _logger.e('Error deleting guestbook message with password: $e');
      return false;
    }
  }
  
  @override
  Future<bool> clearAllMessages() async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - cannot clear messages');
      return false;
    }
    
    try {
      await client.from(_tableName).delete().neq('id', '');
      
      // Refresh messages to update cache
      await getMessages();
      return true;
    } catch (e) {
      _logger.e('Error clearing all guestbook messages from Supabase: $e');
      return false;
    }
  }
  
  @override
  Future<List<GuestbookMessage>> getApprovedMessages() async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - filtering cached messages');
      final messages = _cachedMessages ?? [];
      return messages.where((m) => m.isApproved).toList();
    }
    
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('is_approved', true)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => GuestbookMessage.fromSupabase(json))
          .toList();
    } catch (e) {
      _logger.e('Error loading approved messages from Supabase: $e');
      final messages = await getMessages();
      return messages.where((m) => m.isApproved).toList();
    }
  }
  
  @override
  Future<List<GuestbookMessage>> getPendingMessages() async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - filtering cached messages');
      final messages = _cachedMessages ?? [];
      return messages.where((m) => !m.isApproved).toList();
    }
    
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('is_approved', false)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => GuestbookMessage.fromSupabase(json))
          .toList();
    } catch (e) {
      _logger.e('Error loading pending messages from Supabase: $e');
      final messages = await getMessages();
      return messages.where((m) => !m.isApproved).toList();
    }
  }
  
  @override
  Future<bool> approveMessage(String messageId) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - cannot approve message');
      return false;
    }
    
    try {
      await client
          .from(_tableName)
          .update({'is_approved': true})
          .eq('id', messageId);
      
      // Refresh messages to update cache
      await getMessages();
      return true;
    } catch (e) {
      _logger.e('Error approving message in Supabase: $e');
      return false;
    }
  }
  
  @override
  Future<bool> rejectMessage(String messageId) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - cannot reject message');
      return false;
    }
    
    try {
      await client
          .from(_tableName)
          .update({'is_approved': false})
          .eq('id', messageId);
      
      // Refresh messages to update cache
      await getMessages();
      return true;
    } catch (e) {
      _logger.e('Error rejecting message in Supabase: $e');
      return false;
    }
  }
  
  @override
  Future<List<GuestbookMessage>> getMessagesByRelationship(String relationship) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - filtering cached messages');
      final messages = _cachedMessages ?? [];
      return messages.where((m) => m.relationship == relationship).toList();
    }
    
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('relationship', relationship)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => GuestbookMessage.fromSupabase(json))
          .toList();
    } catch (e) {
      _logger.e('Error loading messages by relationship from Supabase: $e');
      final messages = await getMessages();
      return messages.where((m) => m.relationship == relationship).toList();
    }
  }
  
  @override
  Future<List<GuestbookMessage>> searchMessages(String searchQuery) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - searching cached messages');
      final messages = _cachedMessages ?? [];
      final searchLower = searchQuery.toLowerCase();
      return messages.where((m) =>
          m.name.toLowerCase().contains(searchLower) ||
          m.message.toLowerCase().contains(searchLower)
      ).toList();
    }
    
    try {
      final query = searchQuery.toLowerCase();
      final response = await client
          .from(_tableName)
          .select()
          .or('name.ilike.%$query%,message.ilike.%$query%')
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => GuestbookMessage.fromSupabase(json))
          .toList();
    } catch (e) {
      _logger.e('Error searching messages in Supabase: $e');
      final messages = await getMessages();
      final searchLower = searchQuery.toLowerCase();
      return messages.where((m) =>
          m.name.toLowerCase().contains(searchLower) ||
          m.message.toLowerCase().contains(searchLower)
      ).toList();
    }
  }
  
  @override
  Future<List<GuestbookMessage>> getRecentMessages({int limit = 20}) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - returning cached messages');
      final messages = _cachedMessages ?? [];
      return messages.take(limit).toList();
    }
    
    try {
      final response = await client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((json) => GuestbookMessage.fromSupabase(json))
          .toList();
    } catch (e) {
      _logger.e('Error loading recent messages from Supabase: $e');
      final messages = await getMessages();
      return messages.take(limit).toList();
    }
  }
  
  @override
  Future<int> getMessageCount() async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - counting cached messages');
      return _cachedMessages?.length ?? 0;
    }
    
    try {
      final response = await client
          .from(_tableName)
          .select('id')
          .count(CountOption.exact);
      
      return response.count;
    } catch (e) {
      _logger.e('Error getting message count from Supabase: $e');
      final messages = await getMessages();
      return messages.length;
    }
  }
  
  @override
  Future<int> getApprovedMessageCount() async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - counting cached messages');
      final messages = _cachedMessages ?? [];
      return messages.where((m) => m.isApproved).length;
    }
    
    try {
      final response = await client
          .from(_tableName)
          .select('id')
          .eq('is_approved', true)
          .count(CountOption.exact);
      
      return response.count;
    } catch (e) {
      _logger.e('Error getting approved message count from Supabase: $e');
      final messages = await getApprovedMessages();
      return messages.length;
    }
  }
  
  @override
  Future<GuestbookMessage?> getMessageById(String messageId) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - searching cached messages');
      final messages = _cachedMessages ?? [];
      try {
        return messages.firstWhere((m) => m.id == messageId);
      } catch (e) {
        return null;
      }
    }
    
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('id', messageId)
          .single();
      
      return GuestbookMessage.fromSupabase(response);
    } catch (e) {
      _logger.e('Error getting message by ID from Supabase: $e');
      return null;
    }
  }
  
  @override
  Future<bool> requiresModeration() async {
    // This could be configurable in Supabase settings table
    return true;
  }
  
  @override
  Future<List<String>> getRelationshipTypes() async {
    // This could be fetched from a Supabase configuration table
    return [
      '신랑측',
      '신부측',
      '친구',
      '직장동료',
      '가족',
      '친척',
      '지인',
      '기타'
    ];
  }
  
  // Real-time Stream implementations
  @override
  Stream<List<GuestbookMessage>> getMessagesStream() {
    // Initialize with current data if available
    if (_cachedMessages != null) {
      _messagesController.add(_cachedMessages!);
    } else {
      // Load initial data
      getMessages();
    }
    return _messagesController.stream;
  }
  
  @override
  Stream<List<GuestbookMessage>> getApprovedMessagesStream() {
    return getMessagesStream().map((messages) =>
        messages.where((message) => message.isApproved).toList());
  }
  
  @override
  Stream<List<GuestbookMessage>> getPendingMessagesStream() {
    return getMessagesStream().map((messages) =>
        messages.where((message) => !message.isApproved).toList());
  }
  
  @override
  Stream<List<GuestbookMessage>> getRecentMessagesStream({int limit = 20}) {
    return getMessagesStream().map((messages) =>
        messages.take(limit).toList());
  }
  
  @override
  Stream<int> getMessageCountStream() {
    // Initialize with current count if available
    if (_cachedMessages != null) {
      _messageCountController.add(_cachedMessages!.length);
    } else {
      // Load initial data
      getMessages();
    }
    return _messageCountController.stream;
  }
  
  // Helper method to notify all streams when data changes
  void _notifyStreams() {
    if (_cachedMessages != null) {
      _messagesController.add(_cachedMessages!);
      _messageCountController.add(_cachedMessages!.length);
    }
  }
  
  // Cleanup method for disposing streams and subscriptions
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _messagesController.close();
    _messageCountController.close();
  }
}