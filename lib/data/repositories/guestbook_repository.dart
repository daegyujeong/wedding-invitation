import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/guestbook_message_model.dart';
import 'interfaces/guestbook_repository.dart';
import 'package:logger/logger.dart';

class GuestbookRepository implements IGuestbookRepository {
  static const String _storageKey = 'guestbook_messages';
  final _logger = Logger();

  @override
  Future<List<GuestbookMessage>> getMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_storageKey);
      
      if (messagesJson == null) {
        return [];
      }

      final List<dynamic> messagesList = json.decode(messagesJson);
      return messagesList
          .map((json) => GuestbookMessage.fromJson(json))
          .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Latest first
    } catch (e) {
      _logger.e('Error loading guestbook messages: $e');
      return [];
    }
  }

  @override
  Future<bool> addMessage(GuestbookMessage message) async {
    try {
      final messages = await getMessages();
      messages.insert(0, message); // Add to beginning
      
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = json.encode(messages.map((m) => m.toJson()).toList());
      
      return await prefs.setString(_storageKey, messagesJson);
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
      
      return await prefs.setString(_storageKey, messagesJson);
    } catch (e) {
      _logger.e('Error deleting guestbook message: $e');
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
      
      return await prefs.setString(_storageKey, messagesJson);
    } catch (e) {
      _logger.e('Error updating guestbook message: $e');
      return false;
    }
  }

  @override
  Future<bool> clearAllMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
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
}