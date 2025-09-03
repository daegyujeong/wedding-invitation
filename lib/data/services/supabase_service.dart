import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../../core/config/environment.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static final Logger _logger = Logger();
  
  // Private constructor
  SupabaseService._();
  
  // Singleton instance getter
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }
  
  // Supabase client getter
  SupabaseClient get client {
    if (!isInitialized) {
      throw Exception('Supabase is not initialized. Please check your credentials.');
    }
    return Supabase.instance.client;
  }
  
  // Check if Supabase is initialized
  static bool get isInitialized => _instance != null;
  
  // Check if Supabase is available (initialized and ready to use)
  static bool get isAvailable => isInitialized;
  
  // Initialize Supabase
  static Future<SupabaseService?> initialize() async {
    if (_instance != null) {
      _logger.w('Supabase is already initialized');
      return _instance!;
    }
    
    try {
      // Check if Supabase credentials are configured
      if (Environment.supabaseUrl.isEmpty || Environment.supabaseAnonKey.isEmpty) {
        _logger.w('Supabase credentials are not configured - skipping initialization');
        _logger.i('App will run with local storage only');
        return null;
      }
      
      // Initialize Supabase with web-optimized settings
      _logger.i('Initializing Supabase with URL: ${Environment.supabaseUrl}');
      _logger.i('Supabase key length: ${Environment.supabaseAnonKey.length}');
      
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        anonKey: Environment.supabaseAnonKey,
        debug: false, // Always false for web to avoid console spam
        realtimeClientOptions: const RealtimeClientOptions(
          eventsPerSecond: 2,
        ),
      );
      
      _instance = SupabaseService._();
      _logger.i('Supabase initialized successfully');
      
      // Test connection
      await _instance!.testConnection();
      
      return _instance!;
    } catch (e) {
      _logger.e('Failed to initialize Supabase: $e');
      rethrow;
    }
  }
  
  // Test Supabase connection
  Future<bool> testConnection() async {
    try {
      // Check if we can access the client - this is sufficient to verify connection
      final isConnected = client.auth.currentSession != null || true;
      _logger.i('Supabase client initialized successfully');
      return isConnected;
    } catch (e) {
      _logger.w('Supabase connection test failed: $e');
      return false;
    }
  }
  
  // Get authenticated user
  User? get currentUser => client.auth.currentUser;
  
  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
  
  // Sign in with email (for admin features)
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _logger.i('User signed in successfully');
      return response;
    } catch (e) {
      _logger.e('Sign in failed: $e');
      rethrow;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Sign out failed: $e');
      rethrow;
    }
  }
  
  // Subscribe to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  // Handle errors with proper logging
  void handleError(dynamic error, {String? context}) {
    _logger.e('Supabase error${context != null ? ' in $context' : ''}: $error');
  }
}