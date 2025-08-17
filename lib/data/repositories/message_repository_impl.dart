// lib/data/repositories/message_repository_impl.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import 'interfaces/message_repository.dart';

class MessageRepositoryImpl implements IMessageRepository {
  static const String _storageKey = 'messages';
  static const String _likesStorageKey = 'message_likes';

  @override
  Future<List<MessageModel>> getMessages(String invitationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('${_storageKey}_$invitationId');
      
      if (messagesJson == null) {
        return [];
      }

      final List<dynamic> messagesList = json.decode(messagesJson);
      return messagesList
          .map((json) => MessageModel.fromJson(json))
          .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Latest first
    } catch (e) {
      print('Error loading messages: $e');
      return [];
    }
  }

  @override
  Future<bool> addMessage(MessageModel message) async {
    try {
      final messages = await getMessages(message.invitationId);
      messages.insert(0, message); // Add to beginning
      
      return await _saveMessages(message.invitationId, messages);
    } catch (e) {
      print('Error adding message: $e');
      return false;
    }
  }

  @override
  Future<bool> updateMessage(MessageModel message) async {
    try {
      final messages = await getMessages(message.invitationId);
      final index = messages.indexWhere((m) => m.id == message.id);
      
      if (index == -1) return false;
      
      messages[index] = message;
      return await _saveMessages(message.invitationId, messages);
    } catch (e) {
      print('Error updating message: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteMessage(String messageId) async {
    try {
      // Find the message first to get invitationId
      final message = await getMessageById(messageId);
      if (message == null) return false;
      
      final messages = await getMessages(message.invitationId);
      messages.removeWhere((m) => m.id == messageId);
      
      return await _saveMessages(message.invitationId, messages);
    } catch (e) {
      print('Error deleting message: $e');
      return false;
    }
  }

  @override
  Future<List<MessageModel>> getMessagesByAuthor(String authorName) async {
    try {
      // Get all messages from all invitations and filter by author
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('${_storageKey}_'));
      
      List<MessageModel> allMessages = [];
      for (final key in keys) {
        final invitationId = key.replaceFirst('${_storageKey}_', '');
        final messages = await getMessages(invitationId);
        allMessages.addAll(messages);
      }
      
      return allMessages.where((message) => 
        message.name.toLowerCase() == authorName.toLowerCase()
      ).toList();
    } catch (e) {
      print('Error getting messages by author: $e');
      return [];
    }
  }

  @override
  Future<List<MessageModel>> getPopularMessages(String invitationId, {int limit = 10}) async {
    final messages = await getMessages(invitationId);
    messages.sort((a, b) => b.likes.compareTo(a.likes)); // Sort by likes descending
    return messages.take(limit).toList();
  }

  @override
  Future<bool> toggleMessageLike(String messageId) async {
    try {
      final message = await getMessageById(messageId);
      if (message == null) return false;
      
      final updatedMessage = message.copyWith(likes: message.likes + 1);
      return await updateMessage(updatedMessage);
    } catch (e) {
      print('Error toggling message like: $e');
      return false;
    }
  }

  @override
  Future<int> getMessageCount(String invitationId) async {
    final messages = await getMessages(invitationId);
    return messages.length;
  }

  @override
  Future<List<MessageModel>> getRecentMessages(String invitationId, {int limit = 20}) async {
    final messages = await getMessages(invitationId);
    return messages.take(limit).toList(); // Already sorted by date
  }

  @override
  Future<List<MessageModel>> searchMessages(String invitationId, String searchQuery) async {
    final messages = await getMessages(invitationId);
    final query = searchQuery.toLowerCase();
    return messages.where((message) => 
      message.name.toLowerCase().contains(query) ||
      message.message.toLowerCase().contains(query)
    ).toList();
  }

  @override
  Future<bool> clearMessages(String invitationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('${_storageKey}_$invitationId');
    } catch (e) {
      print('Error clearing messages: $e');
      return false;
    }
  }

  @override
  Future<MessageModel?> getMessageById(String messageId) async {
    try {
      // Search across all invitations
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('${_storageKey}_'));
      
      for (final key in keys) {
        final invitationId = key.replaceFirst('${_storageKey}_', '');
        final messages = await getMessages(invitationId);
        
        try {
          return messages.firstWhere((message) => message.id == messageId);
        } catch (e) {
          // Continue searching in other invitations
          continue;
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting message by ID: $e');
      return null;
    }
  }

  @override
  Future<bool> hasUserLeftMessage(String invitationId, String userName) async {
    final messages = await getMessages(invitationId);
    return messages.any((message) => 
      message.name.toLowerCase() == userName.toLowerCase()
    );
  }

  // Private helper method
  Future<bool> _saveMessages(String invitationId, List<MessageModel> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = json.encode(messages.map((m) => m.toJson()).toList());
      return await prefs.setString('${_storageKey}_$invitationId', messagesJson);
    } catch (e) {
      print('Error saving messages: $e');
      return false;
    }
  }
}