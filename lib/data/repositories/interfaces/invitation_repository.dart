// lib/data/repositories/interfaces/invitation_repository.dart
import '../../models/invitation_model.dart';
import '../../models/venue_model.dart';

/// Abstract repository interface for wedding invitation data operations
abstract class InvitationRepository {
  /// Get the complete invitation details
  Future<InvitationModel?> getInvitationDetails();

  /// Update invitation details
  Future<bool> updateInvitation(InvitationModel invitation);

  /// Get supported languages for the invitation
  Future<List<String>> getSupportedLanguages();

  /// Update invitation venues
  Future<bool> updateVenues(List<VenueModel> venues);

  /// Add a new venue to the invitation
  Future<bool> addVenue(VenueModel venue);

  /// Remove a venue from the invitation
  Future<bool> removeVenue(String venueId);

  /// Update background image
  Future<bool> updateBackgroundImage(String imageUrl);

  /// Update invitation template
  Future<bool> updateTemplate(String template);

  /// Update multilingual content
  Future<bool> updateMultiLanguageText({
    Map<String, String>? title,
    Map<String, String>? groomName,
    Map<String, String>? brideName,
    Map<String, String>? greetingMessage,
  });

  /// Get invitation for specific language
  Future<InvitationModel?> getInvitationForLanguage(String languageCode);

  /// Check if invitation exists
  Future<bool> hasInvitation();

  /// Create initial invitation
  Future<bool> createInvitation(InvitationModel invitation);

  /// Delete invitation (for cleanup/reset)
  Future<bool> deleteInvitation();
}