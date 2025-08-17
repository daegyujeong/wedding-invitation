// lib/data/repositories/invitation_repository_impl.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invitation_model.dart';
import '../models/venue_model.dart';
import 'interfaces/invitation_repository.dart';

class InvitationRepositoryImpl implements InvitationRepository {
  static const String _invitationKey = 'invitation_details';
  static const String _venuesKey = 'invitation_venues';
  static const String _backgroundImageKey = 'invitation_background';
  static const String _templateKey = 'invitation_template';

  @override
  Future<InvitationModel?> getInvitationDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final invitationJson = prefs.getString(_invitationKey);
      
      if (invitationJson == null) return null;
      
      return InvitationModel.fromJson(json.decode(invitationJson));
    } catch (e) {
      print('Error loading invitation details: $e');
      return null;
    }
  }

  @override
  Future<bool> updateInvitation(InvitationModel invitation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final invitationJson = json.encode(invitation.toJson());
      return await prefs.setString(_invitationKey, invitationJson);
    } catch (e) {
      print('Error updating invitation: $e');
      return false;
    }
  }

  @override
  Future<List<String>> getSupportedLanguages() async {
    final invitation = await getInvitationDetails();
    return invitation?.supportedLanguages ?? ['ko', 'en'];
  }

  @override
  Future<bool> updateVenues(List<VenueModel> venues) async {
    try {
      final invitation = await getInvitationDetails();
      if (invitation == null) return false;
      
      final updatedInvitation = InvitationModel(
        id: invitation.id,
        title: invitation.title,
        groomName: invitation.groomName,
        brideName: invitation.brideName,
        greetingMessage: invitation.greetingMessage,
        venues: venues,
        backgroundImage: invitation.backgroundImage,
        template: invitation.template,
        supportedLanguages: invitation.supportedLanguages,
      );
      
      return await updateInvitation(updatedInvitation);
    } catch (e) {
      print('Error updating venues: $e');
      return false;
    }
  }

  @override
  Future<bool> addVenue(VenueModel venue) async {
    try {
      final invitation = await getInvitationDetails();
      if (invitation == null) return false;
      
      final updatedVenues = [...invitation.venues, venue];
      return await updateVenues(updatedVenues);
    } catch (e) {
      print('Error adding venue: $e');
      return false;
    }
  }

  @override
  Future<bool> removeVenue(String venueId) async {
    try {
      final invitation = await getInvitationDetails();
      if (invitation == null) return false;
      
      final updatedVenues = invitation.venues.where((v) => v.id != venueId).toList();
      return await updateVenues(updatedVenues);
    } catch (e) {
      print('Error removing venue: $e');
      return false;
    }
  }

  @override
  Future<bool> updateBackgroundImage(String imageUrl) async {
    try {
      final invitation = await getInvitationDetails();
      if (invitation == null) return false;
      
      final updatedInvitation = InvitationModel(
        id: invitation.id,
        title: invitation.title,
        groomName: invitation.groomName,
        brideName: invitation.brideName,
        greetingMessage: invitation.greetingMessage,
        venues: invitation.venues,
        backgroundImage: imageUrl,
        template: invitation.template,
        supportedLanguages: invitation.supportedLanguages,
      );
      
      return await updateInvitation(updatedInvitation);
    } catch (e) {
      print('Error updating background image: $e');
      return false;
    }
  }

  @override
  Future<bool> updateTemplate(String template) async {
    try {
      final invitation = await getInvitationDetails();
      if (invitation == null) return false;
      
      final updatedInvitation = InvitationModel(
        id: invitation.id,
        title: invitation.title,
        groomName: invitation.groomName,
        brideName: invitation.brideName,
        greetingMessage: invitation.greetingMessage,
        venues: invitation.venues,
        backgroundImage: invitation.backgroundImage,
        template: template,
        supportedLanguages: invitation.supportedLanguages,
      );
      
      return await updateInvitation(updatedInvitation);
    } catch (e) {
      print('Error updating template: $e');
      return false;
    }
  }

  @override
  Future<bool> updateMultiLanguageText({
    Map<String, String>? title,
    Map<String, String>? groomName,
    Map<String, String>? brideName,
    Map<String, String>? greetingMessage,
  }) async {
    try {
      final invitation = await getInvitationDetails();
      if (invitation == null) return false;
      
      final updatedInvitation = InvitationModel(
        id: invitation.id,
        title: title != null 
            ? MultiLanguageText(translations: title, defaultLanguage: invitation.title.defaultLanguage)
            : invitation.title,
        groomName: groomName != null 
            ? MultiLanguageText(translations: groomName, defaultLanguage: invitation.groomName.defaultLanguage)
            : invitation.groomName,
        brideName: brideName != null 
            ? MultiLanguageText(translations: brideName, defaultLanguage: invitation.brideName.defaultLanguage)
            : invitation.brideName,
        greetingMessage: greetingMessage != null 
            ? MultiLanguageText(translations: greetingMessage, defaultLanguage: invitation.greetingMessage.defaultLanguage)
            : invitation.greetingMessage,
        venues: invitation.venues,
        backgroundImage: invitation.backgroundImage,
        template: invitation.template,
        supportedLanguages: invitation.supportedLanguages,
      );
      
      return await updateInvitation(updatedInvitation);
    } catch (e) {
      print('Error updating multilingual text: $e');
      return false;
    }
  }

  @override
  Future<InvitationModel?> getInvitationForLanguage(String languageCode) async {
    // For now, return the same invitation as language switching is handled by MultiLanguageText
    // In future, could cache language-specific versions
    return await getInvitationDetails();
  }

  @override
  Future<bool> hasInvitation() async {
    final invitation = await getInvitationDetails();
    return invitation != null;
  }

  @override
  Future<bool> createInvitation(InvitationModel invitation) async {
    try {
      // Only create if one doesn't already exist
      if (await hasInvitation()) {
        return false;
      }
      
      return await updateInvitation(invitation);
    } catch (e) {
      print('Error creating invitation: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteInvitation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final results = await Future.wait([
        prefs.remove(_invitationKey),
        prefs.remove(_venuesKey),
        prefs.remove(_backgroundImageKey),
        prefs.remove(_templateKey),
      ]);
      
      return results.every((result) => result);
    } catch (e) {
      print('Error deleting invitation: $e');
      return false;
    }
  }
}