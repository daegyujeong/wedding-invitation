// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/invitation/invitation_screen.dart';
import '../../presentation/screens/gallery/gallery_screen.dart';
import '../../presentation/screens/location/location_screen.dart';
import '../../presentation/screens/guestbook/guestbook_screen.dart';
import '../../presentation/screens/share/share_screen.dart';
import '../../presentation/screens/editor/editor_screen.dart';

/// App routes configuration using GoRouter
class AppRouter {
  static const String invitation = '/';
  static const String gallery = '/gallery';
  static const String location = '/location';
  static const String guestbook = '/guestbook';
  static const String share = '/share';
  static const String editor = '/editor';
  
  /// GoRouter configuration
  static GoRouter get router => _router;
  
  static final GoRouter _router = GoRouter(
    initialLocation: invitation,
    debugLogDiagnostics: true,
    
    // Handle redirect and deep linking logic
    redirect: (BuildContext context, GoRouterState state) {
      final String currentUrl = state.uri.toString();
      final String currentPath = state.uri.path;
      
      // Log deep link navigation for debugging
      debugPrint('🔗 Deep link navigation to: $currentUrl');
      
      // Validate routes and handle redirects if needed
      final validRoutes = [invitation, gallery, location, guestbook, share, editor];
      if (!validRoutes.contains(currentPath)) {
        debugPrint('⚠️ Invalid route detected: $currentPath, redirecting to home');
        return invitation;
      }
      
      // Allow navigation to all valid routes
      return null;
    },
    
    routes: [
      // Main invitation screen (home)
      GoRoute(
        path: invitation,
        name: 'invitation',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const InvitationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      
      // Photo gallery
      GoRoute(
        path: gallery,
        name: 'gallery',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const GalleryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
        ),
      ),
      
      // Location and maps
      GoRoute(
        path: location,
        name: 'location',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const LocationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
        ),
      ),
      
      // Guest messages/guestbook
      GoRoute(
        path: guestbook,
        name: 'guestbook',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const GuestbookScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
        ),
      ),
      
      // Sharing options
      GoRoute(
        path: share,
        name: 'share',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ShareScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              ScaleTransition(
                scale: Tween<double>(
                  begin: 0.8,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                )),
                child: child,
              ),
        ),
      ),
      
      // Editor system (for Phase 2)
      GoRoute(
        path: editor,
        name: 'editor',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const EditorScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, -1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              ),
        ),
      ),
    ],
    
    // Error page handling
    errorPageBuilder: (context, state) => MaterialPage<void>(
      key: state.pageKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('페이지를 찾을 수 없습니다')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                '요청하신 페이지를 찾을 수 없습니다.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(invitation),
                child: const Text('홈으로 돌아가기'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Navigation helper methods
extension AppRouterExtension on BuildContext {
  /// Navigate to invitation screen
  void goToInvitation() => go(AppRouter.invitation);
  
  /// Navigate to gallery screen
  void goToGallery() => go(AppRouter.gallery);
  
  /// Navigate to location screen
  void goToLocation() => go(AppRouter.location);
  
  /// Navigate to guestbook screen
  void goToGuestbook() => go(AppRouter.guestbook);
  
  /// Navigate to share screen
  void goToShare() => go(AppRouter.share);
  
  /// Navigate to editor screen
  void goToEditor() => go(AppRouter.editor);
  
  /// Check if currently on specific route
  bool get isOnInvitation => GoRouter.of(this).routerDelegate.currentConfiguration.fullPath == AppRouter.invitation;
  bool get isOnGallery => GoRouter.of(this).routerDelegate.currentConfiguration.fullPath == AppRouter.gallery;
  bool get isOnLocation => GoRouter.of(this).routerDelegate.currentConfiguration.fullPath == AppRouter.location;
  bool get isOnGuestbook => GoRouter.of(this).routerDelegate.currentConfiguration.fullPath == AppRouter.guestbook;
  bool get isOnShare => GoRouter.of(this).routerDelegate.currentConfiguration.fullPath == AppRouter.share;
  bool get isOnEditor => GoRouter.of(this).routerDelegate.currentConfiguration.fullPath == AppRouter.editor;
  
  /// Get current route name
  String get currentRouteName {
    final router = GoRouter.of(this);
    final config = router.routerDelegate.currentConfiguration;
    return config.fullPath;
  }
  
  /// Get shareable URL for current route
  String get shareableUrl {
    final router = GoRouter.of(this);
    final config = router.routerDelegate.currentConfiguration;
    // In a real app, this would be your domain
    return 'https://yourdomain.com${config.fullPath}';
  }
}

/// Deep linking utilities
class DeepLinkHelper {
  /// Parse deep link URL and extract route information
  static Map<String, dynamic> parseDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      return {
        'path': uri.path,
        'queryParameters': uri.queryParameters,
        'fragment': uri.fragment,
        'isValid': _isValidRoute(uri.path),
      };
    } catch (e) {
      debugPrint('Error parsing deep link: $e');
      return {
        'path': AppRouter.invitation,
        'queryParameters': <String, String>{},
        'fragment': '',
        'isValid': false,
      };
    }
  }
  
  /// Check if route path is valid
  static bool _isValidRoute(String path) {
    const validRoutes = [
      AppRouter.invitation,
      AppRouter.gallery,
      AppRouter.location,
      AppRouter.guestbook,
      AppRouter.share,
      AppRouter.editor,
    ];
    return validRoutes.contains(path);
  }
  
  /// Generate shareable deep link for a route
  static String generateDeepLink(String routePath, {Map<String, String>? queryParams}) {
    final uri = Uri(
      scheme: 'https',
      host: 'yourdomain.com', // Replace with your actual domain
      path: routePath,
      queryParameters: queryParams?.isNotEmpty == true ? queryParams : null,
    );
    return uri.toString();
  }
  
  /// Log deep link analytics (placeholder for actual analytics)
  static void logDeepLinkEvent(String path, String? source) {
    debugPrint('📊 Deep link accessed: $path${source != null ? ' from $source' : ''}');
    // TODO: Integrate with actual analytics service (Firebase, etc.)
  }
}

/// Common navigation transitions
class AppTransitions {
  /// Fade transition
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
  
  /// Slide from right transition
  static Widget slideFromRightTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
  
  /// Slide from bottom transition
  static Widget slideFromBottomTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
  
  /// Scale transition with bounce
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      )),
      child: child,
    );
  }
}