// lib/data/repositories/interfaces/message_repository.dart
import '../../models/message_model.dart';

/// Abstract repository interface for message data operations
abstract class IMessageRepository {
  /// Get all messages for a specific invitation
  Future<List<MessageModel>> getMessages(String invitationId);

  /// Add a new message
  Future<bool> addMessage(MessageModel message);

  /// Update an existing message
  Future<bool> updateMessage(MessageModel message);

  /// Delete a message
  Future<bool> deleteMessage(String messageId);

  /// Get messages by author
  Future<List<MessageModel>> getMessagesByAuthor(String authorName);

  /// Get popular messages (sorted by likes)
  Future<List<MessageModel>> getPopularMessages(String invitationId, {int limit = 10});

  /// Like/unlike a message
  Future<bool> toggleMessageLike(String messageId);

  /// Get total message count for invitation
  Future<int> getMessageCount(String invitationId);

  /// Get recent messages
  Future<List<MessageModel>> getRecentMessages(String invitationId, {int limit = 20});

  /// Search messages by content
  Future<List<MessageModel>> searchMessages(String invitationId, String searchQuery);

  /// Clear all messages for an invitation
  Future<bool> clearMessages(String invitationId);

  /// Get message by ID
  Future<MessageModel?> getMessageById(String messageId);

  /// Check if user has already left a message (by name)
  Future<bool> hasUserLeftMessage(String invitationId, String userName);
}