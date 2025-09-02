import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../models/rsvp_model.dart';
import '../services/supabase_service.dart';
import 'interfaces/rsvp_repository.dart';

class SupabaseRSVPRepository implements IRSVPRepository {
  static const String _tableName = 'rsvp_responses';
  final _logger = Logger();
  
  // Stream controllers for real-time updates
  final StreamController<List<RSVPModel>> _rsvpController = 
      StreamController<List<RSVPModel>>.broadcast();
  final StreamController<int> _attendingCountController = 
      StreamController<int>.broadcast();
  
  // Supabase realtime subscription
  RealtimeChannel? _realtimeChannel;
  
  // Cache for RSVPs
  List<RSVPModel>? _cachedRSVPs;
  
  SupabaseRSVPRepository() {
    if (SupabaseService.isAvailable) {
      // Initialize realtime with error handling
      try {
        _initializeRealtimeSubscription();
        _logger.i('RSVP repository initialized with realtime');
      } catch (e) {
        _logger.w('Failed to initialize realtime for RSVP: $e');
        _logger.i('RSVP repository will work without realtime updates');
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
              _logger.i('RSVP realtime event: ${payload.eventType}');
              // Refresh RSVPs when any change occurs
              getAllRSVPs();
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
  Future<bool> submitRSVP(RSVPModel rsvp) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - cannot submit RSVP');
      return false;
    }
    
    try {
      // Always insert new RSVP (allow duplicate names)
      await client.from(_tableName).insert(rsvp.toJson());
      
      // Refresh cache
      await getAllRSVPs();
      return true;
    } catch (e) {
      _logger.e('Error submitting RSVP to Supabase: $e');
      return false;
    }
  }
  
  @override
  Future<bool> updateRSVP(RSVPModel rsvp) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - cannot update RSVP');
      return false;
    }
    
    try {
      await client
          .from(_tableName)
          .update(rsvp.toJson())
          .eq('id', rsvp.id);
      
      // Refresh cache
      await getAllRSVPs();
      return true;
    } catch (e) {
      _logger.e('Error updating RSVP in Supabase: $e');
      return false;
    }
  }
  
  Future<RSVPModel?> getRSVPByName(String guestName) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - searching cached RSVPs');
      final rsvps = _cachedRSVPs ?? [];
      try {
        return rsvps.firstWhere((r) => r.guestName == guestName);
      } catch (e) {
        return null;
      }
    }
    
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('guest_name', guestName)
          .maybeSingle();
      
      if (response == null) return null;
      
      return RSVPModel.fromJson(response);
    } catch (e) {
      _logger.e('Error getting RSVP by guest name from Supabase: $e');
      return null;
    }
  }
  
  @override
  Future<RSVPModel?> getRSVPByEmail(String email) async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - searching cached RSVPs');
      final rsvps = _cachedRSVPs ?? [];
      try {
        return rsvps.firstWhere((r) => r.email == email);
      } catch (e) {
        return null;
      }
    }
    
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('email', email)
          .maybeSingle();
      
      if (response == null) return null;
      
      return RSVPModel.fromJson(response);
    } catch (e) {
      _logger.e('Error getting RSVP by email from Supabase: $e');
      return null;
    }
  }
  
  @override
  Future<List<RSVPModel>> getAllRSVPs() async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - returning cached RSVPs');
      return _cachedRSVPs ?? [];
    }
    
    try {
      final response = await client
          .from(_tableName)
          .select()
          .order('submitted_at', ascending: false);
      
      final rsvps = (response as List)
          .map((json) => RSVPModel.fromJson(json))
          .toList();
      
      _cachedRSVPs = rsvps;
      _notifyStreams();
      return rsvps;
    } catch (e) {
      _logger.e('Error loading RSVPs from Supabase: $e');
      return _cachedRSVPs ?? [];
    }
  }
  
  @override
  Future<List<RSVPModel>> getAttendingRSVPs() async {
    final client = _client;
    if (client == null) {
      _logger.w('Supabase not available - filtering cached RSVPs');
      final rsvps = _cachedRSVPs ?? [];
      return rsvps.where((r) => r.isAttending).toList();
    }
    
    try {
      final response = await client
          .from(_tableName)
          .select()
          .eq('is_attending', true)
          .order('submitted_at', ascending: false);
      
      return (response as List)
          .map((json) => RSVPModel.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Error loading attending RSVPs from Supabase: $e');
      final rsvps = await getAllRSVPs();
      return rsvps.where((r) => r.isAttending).toList();
    }
  }
  
  @override
  Future<Map<String, int>> getVenueAttendanceCounts() async {
    final attendingRSVPs = await getAttendingRSVPs();
    final counts = <String, int>{
      'my': 0,
      'sg': 0,
      'ko': 0,
    };
    
    for (final rsvp in attendingRSVPs) {
      for (final venue in rsvp.selectedVenues) {
        counts[venue] = (counts[venue] ?? 0) + 1;
      }
    }
    
    return counts;
  }
  
  @override
  Future<int> getTotalAttendingCount() async {
    final attendingRSVPs = await getAttendingRSVPs();
    return attendingRSVPs.length;
  }
  
  // Real-time Stream implementations
  @override
  Stream<List<RSVPModel>> getRSVPsStream() {
    // Initialize with current data if available
    if (_cachedRSVPs != null) {
      _rsvpController.add(_cachedRSVPs!);
    } else {
      // Load initial data
      getAllRSVPs();
    }
    return _rsvpController.stream;
  }
  
  @override
  Stream<int> getAttendingCountStream() {
    // Initialize with current count if available
    if (_cachedRSVPs != null) {
      final attendingCount = _cachedRSVPs!.where((r) => r.isAttending).length;
      _attendingCountController.add(attendingCount);
    } else {
      // Load initial data
      getAllRSVPs();
    }
    return _attendingCountController.stream;
  }
  
  // Helper method to notify all streams when data changes
  void _notifyStreams() {
    if (_cachedRSVPs != null) {
      _rsvpController.add(_cachedRSVPs!);
      final attendingCount = _cachedRSVPs!.where((r) => r.isAttending).length;
      _attendingCountController.add(attendingCount);
    }
  }
  
  // Cleanup method for disposing streams and subscriptions
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _rsvpController.close();
    _attendingCountController.close();
  }
}