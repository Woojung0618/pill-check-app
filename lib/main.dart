import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/local_storage_service.dart';
import 'services/home_widget_service.dart';
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

  // 홈 위젯 초기화
  // iOS의 경우: Xcode에서 WidgetKit Extension 추가 및 App Group 설정 필요
  // Android의 경우: 이미 설정 완료됨
  try {
    await HomeWidgetService.initialize();
  } catch (e) {
    // 위젯 초기화 실패 시 앱은 정상 동작하지만 위젯 기능은 사용 불가
    // WIDGET_SETUP_GUIDE.md 참고하여 네이티브 설정 완료 필요
    debugPrint('위젯 초기화 실패: $e');
    debugPrint('위젯을 사용하려면 WIDGET_SETUP_GUIDE.md의 설정을 완료하세요.');
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
      child: Builder(
        builder: (context) {
          // 앱 시작 시 위젯 업데이트
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final provider = Provider.of<PillProvider>(context, listen: false);
            provider.loadDataAndUpdateWidget();
          });
          
          return MaterialApp(
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
          );
        },
      ),
    );
  }
}
