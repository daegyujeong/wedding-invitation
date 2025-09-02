// lib/data/repositories/interfaces/guestbook_repository.dart
import 'dart:async';
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
  
  /// Soft delete a guestbook message with password verification
  Future<bool> deleteMessageWithPassword(String messageId, String password);

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

  // Real-time Stream methods for live updates
  /// Stream of all guestbook messages (real-time updates)
  Stream<List<GuestbookMessage>> getMessagesStream();

  /// Stream of approved messages only (real-time updates)
  Stream<List<GuestbookMessage>> getApprovedMessagesStream();

  /// Stream of pending messages for moderation (real-time updates)
  Stream<List<GuestbookMessage>> getPendingMessagesStream();

  /// Stream of recent messages (real-time updates)
  Stream<List<GuestbookMessage>> getRecentMessagesStream({int limit = 20});

  /// Stream of message count (real-time updates)
  Stream<int> getMessageCountStream();
}