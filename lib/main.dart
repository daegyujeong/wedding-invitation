import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/routing/app_router.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/viewmodels/editor_viewmodel.dart';

// Web-specific imports for URL strategy
import 'package:flutter_web_plugins/url_strategy.dart' if (dart.library.io) '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure URL strategy for clean URLs on web (removes # from URLs)
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // 한국어 날짜 형식 초기화
  await initializeDateFormatting('ko_KR', null);

  // 의존성 주입 초기화
  await initializeDependencies();

  // Supabase 초기화
  // final supabaseService = await SupabaseService.initialize();

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
        // 다른 ViewModel 추가
      ],
      child: MaterialApp.router(
        title: '모바일 청첩장',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          fontFamily: 'NotoSansKR',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
