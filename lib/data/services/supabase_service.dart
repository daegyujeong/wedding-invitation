import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;

  SupabaseService._();

  static Future<SupabaseService> initialize() async {
    if (_instance != null) return _instance!;

    // TODO: Replace with your actual Supabase URL and anon key
    const supabaseUrl = 'YOUR_SUPABASE_URL';
    const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );

      _client = Supabase.instance.client;
      _instance = SupabaseService._();
      
      print('Supabase initialized successfully');
      return _instance!;
    } catch (e) {
      print('Failed to initialize Supabase: $e');
      // Return instance even if initialization fails for development
      _instance = SupabaseService._();
      return _instance!;
    }
  }

  static SupabaseClient? get client => _client;

  // Auth methods
  Future<void> signUp(String email, String password) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    await _client!.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signIn(String email, String password) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    await _client!.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    await _client!.auth.signOut();
  }

  // Database methods
  Future<List<Map<String, dynamic>>> getInvitations() async {
    if (_client == null) return [];
    
    try {
      final response = await _client!
          .from('invitations')
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching invitations: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getInvitation(String id) async {
    if (_client == null) return null;
    
    try {
      final response = await _client!
          .from('invitations')
          .select()
          .eq('id', id)
          .single();
      
      return response;
    } catch (e) {
      print('Error fetching invitation: $e');
      return null;
    }
  }

  Future<void> saveInvitation(Map<String, dynamic> invitation) async {
    if (_client == null) throw Exception('Supabase not initialized');
    
    await _client!.from('invitations').upsert(invitation);
  }

  // Storage methods
  Future<String?> uploadImage(String path, List<int> bytes) async {
    if (_client == null) return null;
    
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
      final response = await _client!.storage
          .from('wedding-images')
          .uploadBinary(fileName, Uint8List.fromList(bytes));
      
      return _client!.storage
          .from('wedding-images')
          .getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
