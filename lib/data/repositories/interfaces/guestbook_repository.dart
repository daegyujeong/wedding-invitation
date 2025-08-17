// lib/data/repositories/interfaces/guestbook_repository.dart
import '../../models/guestbook_message_model.dart';

/// Abstract repository interface for guestbook message operations
abstract class IGuestbookRepository {
  /// Get all guestbook messages
  Future<List<GuestbookMessage>> getMessages();

  /// Add a new guestbook message
  Future<bool> addMessage(GuestbookMessage message);

  /// Update an existing guestbook message
  Future<bool> updateMessage(GuestbookMessage message);

  /// Delete a guestbook message
  Future<bool> deleteMessage(String messageId);

  /// Get approved messages only
  Future<List<GuestbookMessage>> getApprovedMessages();

  /// Get pending messages (for moderation)
  Future<List<GuestbookMessage>> getPendingMessages();

  /// Approve a message
  Future<bool> approveMessage(String messageId);

  /// Reject/disapprove a message
  Future<bool> rejectMessage(String messageId);

  /// Get messages by relationship (신랑측, 신부측, etc.)
  Future<List<GuestbookMessage>> getMessagesByRelationship(String relationship);

  /// Search messages by author name or content
  Future<List<GuestbookMessage>> searchMessages(String searchQuery);

  /// Get recent messages
  Future<List<GuestbookMessage>> getRecentMessages({int limit = 20});

  /// Get total message count
  Future<int> getMessageCount();

  /// Get total approved message count
  Future<int> getApprovedMessageCount();

  /// Clear all messages
  Future<bool> clearAllMessages();

  /// Get message by ID
  Future<GuestbookMessage?> getMessageById(String messageId);

  /// Check if moderation is required
  Future<bool> requiresModeration();

  /// Get all available relationship types
  Future<List<String>> getRelationshipTypes();
}