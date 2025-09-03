import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/di/dependency_injection.dart';
import 'data/services/supabase_service.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/viewmodels/editor_viewmodel.dart';
import 'providers/locale_provider.dart';
import 'providers/venue_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Filter out Google Maps deprecation warnings in debug mode
  if (kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null && !message.contains('google.maps.Marker is deprecated')) {
        debugPrintSynchronously(message, wrapWidth: wrapWidth);
      }
    };
  }

  // 한국어 날짜 형식 초기화
  await initializeDateFormatting('ko_KR', null);

  // 의존성 주입 초기화
  await initializeDependencies();

  // Supabase 초기화
  try {
    await SupabaseService.initialize();
  } catch (e) {
    // App will continue with local storage only
    if (kDebugMode) {
      debugPrint('Warning: Supabase initialization failed: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => EditorViewModel()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => VenueProvider()),
      ],
      child: Consumer2<LocaleProvider, VenueProvider>(
        builder: (context, localeProvider, venueProvider, child) {
          // Create larger text theme for parents mode
          final baseTextTheme = ThemeData().textTheme;
          final textTheme = venueProvider.isParentsMode 
              ? baseTextTheme.copyWith(
                  displayLarge: baseTextTheme.displayLarge?.copyWith(fontSize: (baseTextTheme.displayLarge?.fontSize ?? 57) * 1.3),
                  displayMedium: baseTextTheme.displayMedium?.copyWith(fontSize: (baseTextTheme.displayMedium?.fontSize ?? 45) * 1.3),
                  displaySmall: baseTextTheme.displaySmall?.copyWith(fontSize: (baseTextTheme.displaySmall?.fontSize ?? 36) * 1.3),
                  headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontSize: (baseTextTheme.headlineLarge?.fontSize ?? 32) * 1.3),
                  headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontSize: (baseTextTheme.headlineMedium?.fontSize ?? 28) * 1.3),
                  headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontSize: (baseTextTheme.headlineSmall?.fontSize ?? 24) * 1.3),
                  titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: (baseTextTheme.titleLarge?.fontSize ?? 22) * 1.3),
                  titleMedium: baseTextTheme.titleMedium?.copyWith(fontSize: (baseTextTheme.titleMedium?.fontSize ?? 16) * 1.3),
                  titleSmall: baseTextTheme.titleSmall?.copyWith(fontSize: (baseTextTheme.titleSmall?.fontSize ?? 14) * 1.3),
                  bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * 1.3),
                  bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14) * 1.3),
                  bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12) * 1.3),
                  labelLarge: baseTextTheme.labelLarge?.copyWith(fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14) * 1.3),
                  labelMedium: baseTextTheme.labelMedium?.copyWith(fontSize: (baseTextTheme.labelMedium?.fontSize ?? 12) * 1.3),
                  labelSmall: baseTextTheme.labelSmall?.copyWith(fontSize: (baseTextTheme.labelSmall?.fontSize ?? 11) * 1.3),
                )
              : baseTextTheme;

          return MaterialApp.router(
            title: 'Daegyu & Irene Wedding Invitation',
            theme: ThemeData(
              primarySwatch: Colors.pink,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: textTheme,
            ),
            builder: (context, widget) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(venueProvider.isParentsMode ? 1.3 : 1.0),
                ),
                child: widget!,
              );
            },
            routerConfig: AppRouter.router,
            locale: localeProvider.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}