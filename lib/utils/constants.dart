import 'package:flutter/material.dart';

// 색상 팔레트
class PillColors {
  static const List<Color> colorPalette = [
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

  static const List<String> colorNames = [
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

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static Color hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }
}

// 아이콘 타입
class PillIcons {
  static const List<String> iconTypes = [
    'circle',    // 동글
    'square',    // 각진
    'pill',      // 의약품 모양
    'capsule',   // 캡슐
  ];

  static const List<String> iconNames = [
    '동글',
    '각진',
    '의약품',
    '캡슐',
  ];
}

// Hive Box 이름
class HiveBoxes {
  static const String pills = 'pills';
  static const String intakeRecords = 'intakeRecords';
}

