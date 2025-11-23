import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/local_storage_service.dart';
import 'providers/pill_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Hive 초기화
    await LocalStorageService.init();
  } catch (e, stackTrace) {
    // ignore: avoid_print
    print('Hive 초기화 실패: $e');
    // ignore: avoid_print
    print('Stack trace: $stackTrace');
    // 에러가 발생해도 앱은 실행되도록 함
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PillProvider()),
      ],
      child: MaterialApp(
        title: '영양제 체크',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
