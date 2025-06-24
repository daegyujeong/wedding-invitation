import 'package:flutter/material.dart';
import '../../features/gallery/presentation/screens/gallery_screen.dart';
import '../../features/location/presentation/screens/location_screen.dart';
import '../../features/messages/presentation/screens/messages_screen.dart';
import '../../features/share/presentation/screens/share_screen.dart';

class AppRouter {
  static const String gallery = '/gallery';
  static const String location = '/location';
  static const String messages = '/messages';
  static const String share = '/share';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String invitationId = settings.arguments as String? ?? 'default';

    switch (settings.name) {
      case gallery:
        return MaterialPageRoute(
          builder: (_) => GalleryScreen(invitationId: invitationId),
        );
      case location:
        return MaterialPageRoute(
          builder: (_) => LocationScreen(invitationId: invitationId),
        );
      case messages:
        return MaterialPageRoute(
          builder: (_) => MessagesScreen(invitationId: invitationId),
        );
      case share:
        return MaterialPageRoute(
          builder: (_) => ShareScreen(invitationId: invitationId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}
