import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/guestbook_message_model.dart';
import 'interfaces/guestbook_repository.dart';
import 'package:logger/logger.dart';

class GuestbookRepository implements IGuestbookRepository {
  static const String _storageKey = 'guestbook_messages';
  final _logger = Logger();
  
  // Stream controllers for real-time updates
  final StreamController<List<GuestbookMessage>> _messagesController = StreamController<List<GuestbookMessage>>.broadcast();
  final StreamController<int> _messageCountController = StreamController<int>.broadcast();
  
  // Cache for reducing SharedPreferences calls
  List<GuestbookMessage>? _cachedMessages;
  Timer? _refreshTimer;

  @override
  Future<List<GuestbookMessage>> getMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_storageKey);
      
      if (messagesJson == null) {
        _cachedMessages = [];
        _notifyStreams();
        return [];
      }

      final List<dynamic> messagesList = json.decode(messagesJson);
      final messages = messagesList
          .map((json) => GuestbookMessage.fromJson(json))
          .where((message) => !message.isDeleted) // Filter out deleted messages
          .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Latest first
      
      _cachedMessages = messages;
      _notifyStreams();
      return messages;
    } catch (e) {
      _logger.e('Error loading guestbook messages: $e');
      return _cachedMessages ?? [];
    }
  }

  // Helper method to notify all streams when data changes
  void _notifyStreams() {
    if (_cachedMessages != null) {
      _messagesController.add(_cachedMessages!);
      _messageCountController.add(_cachedMessages!.length);
    }
  }

  @override
  Future<bool> addMessage(GuestbookMessage message) async {
    try {
      final messages = await getMessages();
      messages.insert(0, message); // Add to beginning
      
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = json.encode(messages.map((m) => m.toJson()).toList());
      
      final success = await prefs.setString(_storageKey, messagesJson);
      if (success) {
        _cachedMessages = messages;
        _notifyStreams();
      }
      return success;
    } catch (e) {
      _logger.e('Error adding guestbook message: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteMessage(String messageId) async {
    try {
      final messages = await getMessages();
      messages.removeWhere((message) => message.id == messageId);
      
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = json.encode(messages.map((m) => m.toJson()).toList());
      
      final success = await prefs.setString(_storageKey, messagesJson);
      if (success) {
        _cachedMessages = messages;
        _notifyStreams();
      }
      return success;
    } catch (e) {
      _logger.e('Error deleting guestbook message: $e');
      return false;
    }
  }
  
  @override
  Future<bool> deleteMessageWithPassword(String messageId, String password) async {
    try {
      final messages = await getMessages();
      final messageIndex = messages.indexWhere((m) => m.id == messageId);
      
      if (messageIndex == -1) {
        _logger.w('Message not found for deletion');
        return false;
      }
      
      final message = messages[messageIndex];
      
      // Verify password
      if (message.password != password) {
        _logger.w('Invalid password for message deletion');
        return false;
      }
      
      // Soft delete - update the message to mark as deleted
      final updatedMessage = message.copyWith(isDeleted: true);
      messages[messageIndex] = updatedMessage;
      
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = json.encode(messages.map((m) => m.toJson()).toList());
      
      final success = await prefs.setString(_storageKey, messagesJson);
      if (success) {
        _cachedMessages = messages;
        _notifyStreams();
        _logger.i('Message soft deleted successfully');
      }
      return success;
    } catch (e) {
      _logger.e('Error deleting guestbook message with password: $e');
      return false;
    }
  }

  @override
  Future<bool> updateMessage(GuestbookMessage updatedMessage) async {
    try {
      final messages = await getMessages();
      final index = messages.indexWhere((message) => message.id == updatedMessage.id);
      
      if (index == -1) {
        return false;
      }
      
      messages[index] = updatedMessage;
      
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = json.encode(messages.map((m) => m.toJson()).toList());
      
      final success = await prefs.setString(_storageKey, messagesJson);
      if (success) {
        _cachedMessages = messages;
        _notifyStreams();
      }
      return success;
    } catch (e) {
      _logger.e('Error updating guestbook message: $e');
      return false;
    }
  }

  @override
  Future<bool> clearAllMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_storageKey);
      if (success) {
        _cachedMessages = [];
        _notifyStreams();
      }
      return success;
    } catch (e) {
      _logger.e('Error clearing guestbook messages: $e');
      return false;
    }
  }

  @override
  Future<List<GuestbookMessage>> getApprovedMessages() async {
    final messages = await getMessages();
    return messages.where((message) => message.isApproved).toList();
  }

  @override
  Future<List<GuestbookMessage>> getPendingMessages() async {
    final messages = await getMessages();
    return messages.where((message) => !message.isApproved).toList();
  }

  @override
  Future<bool> approveMessage(String messageId) async {
    try {
      final messages = await getMessages();
      final index = messages.indexWhere((message) => message.id == messageId);
      
      if (index == -1) return false;
      
      final approvedMessage = messages[index].copyWith(isApproved: true);
      return await updateMessage(approvedMessage);
    } catch (e) {
      _logger.e('Error approving message: $e');
      return false;
    }
  }

  @override
  Future<bool> rejectMessage(String messageId) async {
    try {
      final messages = await getMessages();
      final index = messages.indexWhere((message) => message.id == messageId);
      
      if (index == -1) return false;
      
      final rejectedMessage = messages[index].copyWith(isApproved: false);
      return await updateMessage(rejectedMessage);
    } catch (e) {
      _logger.e('Error rejecting message: $e');
      return false;
    }
  }

  @override
  Future<List<GuestbookMessage>> getMessagesByRelationship(String relationship) async {
    final messages = await getMessages();
    return messages.where((message) => message.relationship == relationship).toList();
  }

  @override
  Future<List<GuestbookMessage>> searchMessages(String searchQuery) async {
    final messages = await getMessages();
    final query = searchQuery.toLowerCase();
    return messages.where((message) => 
      message.name.toLowerCase().contains(query) ||
      message.message.toLowerCase().contains(query)
    ).toList();
  }

  @override
  Future<List<GuestbookMessage>> getRecentMessages({int limit = 20}) async {
    final messages = await getMessages();
    return messages.take(limit).toList(); // Messages are already sorted by date (latest first)
  }

  @override
  Future<int> getMessageCount() async {
    final messages = await getMessages();
    return messages.length;
  }

  @override
  Future<int> getApprovedMessageCount() async {
    final approvedMessages = await getApprovedMessages();
    return approvedMessages.length;
  }

  @override
  Future<GuestbookMessage?> getMessageById(String messageId) async {
    final messages = await getMessages();
    try {
      return messages.firstWhere((message) => message.id == messageId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> requiresModeration() async {
    // Simple implementation - can be made configurable
    return true;
  }

  @override
  Future<List<String>> getRelationshipTypes() async {
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

  // Cleanup method for disposing streams
  void dispose() {
    _refreshTimer?.cancel();
    _messagesController.close();
    _messageCountController.close();
  }
}