import 'package:flutter/material.dart';

/// 앱에서 사용하는 색상들을 관리하는 클래스
class AppColors {
  AppColors._(); // private constructor

  // Primary Colors
  static const Color primary = Color(0xFF7F57);
  static const Color primary2 = Color(0xFF9064);
  static const Color primaryLight = Color(0xFDC9A6);

  // Secondary Colors
  static const Color secondary = Color(0xFF9064);
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF81C784);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF7F57);
  static const Color textSecondary = Color(0xFF9064);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Divider
  static const Color divider = Color(0xFFE0E0E0);

  // 영양제 색상 팔레트
  static const List<Color> pillColorPalette = [
    Color(0xFFFFEB3B), // 노란색
    Color(0xFF4CAF50), // 초록색
    Color(0xFF2196F3), // 파란색
    Color(0xFF9C27B0), // 보라색
    Color(0xFFFF5722), // 주황색
    Color(0xFFE91E63), // 분홍색
    Color(0xFF00BCD4), // 하늘색
    Color(0xFFFFC107), // 앰버
    Color(0xFF795548), // 갈색
    Color(0xFF9E9E9E), // 회색
    Color(0xFFFFFFFF), // 흰색 (투명 캡슐)
    Color(0xFF000000), // 검정색
  ];

  static const List<String> pillColorNames = [
    '노란색',
    '초록색',
    '파란색',
    '보라색',
    '주황색',
    '분홍색',
    '하늘색',
    '앰버',
    '갈색',
    '회색',
    '투명',
    '검정색',
  ];

  /// Hex 문자열을 Color로 변환
  static Color hexToColor(String hex) {
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }

  /// Color를 Hex 문자열로 변환
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

