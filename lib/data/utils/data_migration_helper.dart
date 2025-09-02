import 'package:logger/logger.dart';
import '../repositories/guestbook_repository.dart';
import '../repositories/supabase_guestbook_repository.dart';
import '../services/supabase_service.dart';

class DataMigrationHelper {
  static final Logger _logger = Logger();
  
  /// Migrate guestbook messages from local storage to Supabase
  static Future<MigrationResult> migrateGuestbookToSupabase() async {
    _logger.i('Starting guestbook data migration to Supabase...');
    
    try {
      // Check if Supabase is initialized
      if (!SupabaseService.isInitialized) {
        _logger.w('Supabase is not initialized. Skipping migration.');
        return MigrationResult(
          success: false,
          message: 'Supabase is not initialized',
          migratedCount: 0,
          failedCount: 0,
        );
      }
      
      // Create repositories
      final localRepo = GuestbookRepository();
      final supabaseRepo = SupabaseGuestbookRepository();
      
      // Get all messages from local storage
      final localMessages = await localRepo.getMessages();
      
      if (localMessages.isEmpty) {
        _logger.i('No local messages to migrate');
        return MigrationResult(
          success: true,
          message: 'No messages to migrate',
          migratedCount: 0,
          failedCount: 0,
        );
      }
      
      _logger.i('Found ${localMessages.length} messages to migrate');
      
      // Check if Supabase already has data
      final supabaseMessages = await supabaseRepo.getMessages();
      final existingIds = supabaseMessages.map((m) => m.id).toSet();
      
      // Filter out messages that already exist in Supabase
      final messagesToMigrate = localMessages
          .where((m) => !existingIds.contains(m.id))
          .toList();
      
      if (messagesToMigrate.isEmpty) {
        _logger.i('All messages already exist in Supabase');
        return MigrationResult(
          success: true,
          message: 'All messages already migrated',
          migratedCount: 0,
          failedCount: 0,
          skippedCount: localMessages.length,
        );
      }
      
      // Migrate messages one by one
      int successCount = 0;
      int failCount = 0;
      final List<String> errors = [];
      
      for (final message in messagesToMigrate) {
        try {
          final success = await supabaseRepo.addMessage(message);
          if (success) {
            successCount++;
            _logger.d('Migrated message: ${message.id}');
          } else {
            failCount++;
            errors.add('Failed to migrate message ${message.id}');
          }
        } catch (e) {
          failCount++;
          errors.add('Error migrating message ${message.id}: $e');
          _logger.e('Error migrating message ${message.id}: $e');
        }
      }
      
      // Prepare result
      final result = MigrationResult(
        success: failCount == 0,
        message: failCount == 0
            ? 'Successfully migrated all messages'
            : 'Migration completed with some errors',
        migratedCount: successCount,
        failedCount: failCount,
        skippedCount: localMessages.length - messagesToMigrate.length,
        errors: errors,
      );
      
      _logger.i('Migration completed: ${result.toString()}');
      
      // Optionally clear local storage after successful migration
      if (result.success && successCount > 0) {
        _logger.i('Consider clearing local storage after verifying migration');
        // Uncomment to auto-clear:
        // await localRepo.clearAllMessages();
      }
      
      return result;
    } catch (e) {
      _logger.e('Migration failed with error: $e');
      return MigrationResult(
        success: false,
        message: 'Migration failed: $e',
        migratedCount: 0,
        failedCount: 0,
      );
    }
  }
  
  /// Check if migration is needed
  static Future<bool> isMigrationNeeded() async {
    try {
      if (!SupabaseService.isInitialized) {
        return false;
      }
      
      final localRepo = GuestbookRepository();
      final localMessages = await localRepo.getMessages();
      
      return localMessages.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking migration status: $e');
      return false;
    }
  }
  
  /// Get migration status
  static Future<MigrationStatus> getMigrationStatus() async {
    try {
      final localRepo = GuestbookRepository();
      final localMessages = await localRepo.getMessages();
      
      if (!SupabaseService.isInitialized) {
        return MigrationStatus(
          localCount: localMessages.length,
          supabaseCount: 0,
          isSupabaseAvailable: false,
        );
      }
      
      final supabaseRepo = SupabaseGuestbookRepository();
      final supabaseMessages = await supabaseRepo.getMessages();
      
      return MigrationStatus(
        localCount: localMessages.length,
        supabaseCount: supabaseMessages.length,
        isSupabaseAvailable: true,
      );
    } catch (e) {
      _logger.e('Error getting migration status: $e');
      return MigrationStatus(
        localCount: 0,
        supabaseCount: 0,
        isSupabaseAvailable: false,
      );
    }
  }
}

/// Result of a migration operation
class MigrationResult {
  final bool success;
  final String message;
  final int migratedCount;
  final int failedCount;
  final int skippedCount;
  final List<String> errors;
  
  MigrationResult({
    required this.success,
    required this.message,
    required this.migratedCount,
    required this.failedCount,
    this.skippedCount = 0,
    this.errors = const [],
  });
  
  @override
  String toString() {
    return 'MigrationResult(success: $success, message: $message, '
        'migrated: $migratedCount, failed: $failedCount, skipped: $skippedCount)';
  }
}

/// Current migration status
class MigrationStatus {
  final int localCount;
  final int supabaseCount;
  final bool isSupabaseAvailable;
  
  MigrationStatus({
    required this.localCount,
    required this.supabaseCount,
    required this.isSupabaseAvailable,
  });
  
  bool get needsMigration => isSupabaseAvailable && localCount > 0;
}