// lib/core/di/dependency_injection.dart
import 'package:get_it/get_it.dart';

// Import all repository interfaces
import '../../data/repositories/interfaces/invitation_repository.dart';
import '../../data/repositories/interfaces/message_repository.dart';
import '../../data/repositories/interfaces/guestbook_repository.dart';
import '../../data/repositories/interfaces/location_repository.dart';
import '../../data/repositories/interfaces/widget_repository.dart';
import '../../data/repositories/interfaces/language_repository.dart';

// Import all repository implementations
import '../../data/repositories/invitation_repository_impl.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../data/repositories/guestbook_repository.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../data/repositories/widget_repository_impl.dart';
import '../../data/repositories/language_repository_impl.dart';

// Import services
import '../../data/services/location_search_service.dart';
import '../../data/services/google_places_web_service.dart';

/// Global service locator instance
final GetIt serviceLocator = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Register services first (dependencies for repositories)
  _registerServices();
  
  // Register repository implementations
  _registerRepositories();
  
  // Register other dependencies (ViewModels, UseCases, etc.)
  _registerViewModels();
  
  // Register utilities and helpers
  _registerUtilities();
}

/// Register core services
void _registerServices() {
  // Location search service (singleton for performance)
  serviceLocator.registerLazySingleton<LocationSearchService>(
    () => LocationSearchService(),
  );
  
  // Google Places web service (singleton to maintain state)
  serviceLocator.registerLazySingleton<GooglePlacesWebService>(
    () => GooglePlacesWebService(),
  );
}

/// Register repository implementations as singletons
/// Using interfaces for dependency inversion principle
void _registerRepositories() {
  // Invitation repository
  serviceLocator.registerLazySingleton<InvitationRepository>(
    () => InvitationRepositoryImpl(),
  );
  
  // Message repository
  serviceLocator.registerLazySingleton<IMessageRepository>(
    () => MessageRepositoryImpl(),
  );
  
  // Guestbook repository
  serviceLocator.registerLazySingleton<IGuestbookRepository>(
    () => GuestbookRepository(),
  );
  
  // Location repository (depends on location search service)
  serviceLocator.registerLazySingleton<ILocationRepository>(
    () => LocationRepositoryImpl(serviceLocator<LocationSearchService>()),
  );
  
  // Widget repository
  serviceLocator.registerLazySingleton<IWidgetRepository>(
    () => WidgetRepositoryImpl(),
  );
  
  // Language repository
  serviceLocator.registerLazySingleton<ILanguageRepository>(
    () => LanguageRepositoryImpl(),
  );
}

/// Register ViewModels as factories (new instance each time)
void _registerViewModels() {
  // ViewModels will be registered here when they are created
  // Example:
  // serviceLocator.registerFactory<InvitationViewModel>(
  //   () => InvitationViewModel(
  //     invitationRepository: serviceLocator<InvitationRepository>(),
  //     languageRepository: serviceLocator<ILanguageRepository>(),
  //   ),
  // );
}

/// Register utilities and other dependencies
void _registerUtilities() {
  // Add utility classes, formatters, validators, etc.
  // Example:
  // serviceLocator.registerLazySingleton<DateFormatter>(() => DateFormatter());
}

/// Clean up all registered dependencies (useful for testing)
Future<void> resetDependencies() async {
  await serviceLocator.reset();
}

/// Convenient getter methods for commonly used repositories
class DI {
  // Repositories
  static InvitationRepository get invitationRepository => 
      serviceLocator<InvitationRepository>();
  
  static IMessageRepository get messageRepository => 
      serviceLocator<IMessageRepository>();
  
  static IGuestbookRepository get guestbookRepository => 
      serviceLocator<IGuestbookRepository>();
  
  static ILocationRepository get locationRepository => 
      serviceLocator<ILocationRepository>();
  
  static IWidgetRepository get widgetRepository => 
      serviceLocator<IWidgetRepository>();
  
  static ILanguageRepository get languageRepository => 
      serviceLocator<ILanguageRepository>();
  
  // Services
  static LocationSearchService get locationSearchService => 
      serviceLocator<LocationSearchService>();
  
  static GooglePlacesWebService get googlePlacesService => 
      serviceLocator<GooglePlacesWebService>();
}

/// Extension for easy access to repositories in any widget or class
extension DIContext on Object {
  InvitationRepository get invitationRepository => DI.invitationRepository;
  IMessageRepository get messageRepository => DI.messageRepository;
  IGuestbookRepository get guestbookRepository => DI.guestbookRepository;
  ILocationRepository get locationRepository => DI.locationRepository;
  IWidgetRepository get widgetRepository => DI.widgetRepository;
  ILanguageRepository get languageRepository => DI.languageRepository;
  LocationSearchService get locationSearchService => DI.locationSearchService;
  GooglePlacesWebService get googlePlacesService => DI.googlePlacesService;
}