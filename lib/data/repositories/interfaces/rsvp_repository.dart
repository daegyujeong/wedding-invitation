import '../../../data/models/rsvp_model.dart';

abstract class IRSVPRepository {
  Future<bool> submitRSVP(RSVPModel rsvp);
  Future<bool> updateRSVP(RSVPModel rsvp);
  Future<RSVPModel?> getRSVPByEmail(String email);
  Future<List<RSVPModel>> getAllRSVPs();
  Future<List<RSVPModel>> getAttendingRSVPs();
  Future<Map<String, int>> getVenueAttendanceCounts();
  Future<int> getTotalAttendingCount();
  
  // Streams for real-time updates
  Stream<List<RSVPModel>> getRSVPsStream();
  Stream<int> getAttendingCountStream();
}