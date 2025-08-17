// lib/data/repositories/index.dart
// Centralized export file for all repositories

// Repository Interfaces
export 'interfaces/invitation_repository.dart';
export 'interfaces/message_repository.dart';
export 'interfaces/guestbook_repository.dart';
export 'interfaces/location_repository.dart';
export 'interfaces/widget_repository.dart';
export 'interfaces/language_repository.dart';

// Concrete Repository Implementations
export 'guestbook_repository.dart';
export 'message_repository.dart';
export 'saved_locations_repository.dart';

// New Repository Implementations
export 'invitation_repository_impl.dart';
export 'message_repository_impl.dart';
export 'location_repository_impl.dart';
export 'widget_repository_impl.dart';
export 'language_repository_impl.dart';