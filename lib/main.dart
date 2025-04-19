import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/services/supabase_service.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 날짜 형식 초기화
  await initializeDateFormatting('ko_KR', null);

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
        // 다른 ViewModel 추가
      ],
      child: MaterialApp(
        title: '모바일 청첩장',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          fontFamily: 'NotoSansKR',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
        routes: {
          '/gallery': (context) =>
              const Scaffold(body: Center(child: Text('갤러리'))),
          '/location': (context) =>
              const Scaffold(body: Center(child: Text('오시는 길'))),
          '/message': (context) =>
              const Scaffold(body: Center(child: Text('축하 메시지'))),
          '/editor': (context) =>
              const Scaffold(body: Center(child: Text('에디터'))),
        },
      ),
    );
  }
}
