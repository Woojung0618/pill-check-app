import 'package:hive/hive.dart';

part 'pill.g.dart';

@HiveType(typeId: 0)
class Pill extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? userId; // 비로그인 상태에서는 null

  @HiveField(2)
  String name;

  @HiveField(3)
  String color; // 색상 코드 (예: "#FFEB3B")

  @HiveField(4)
  String? brand; // 선택 사항

  @HiveField(5)
  String icon; // 아이콘 타입 (예: "circle", "square", "pill")

  @HiveField(6)
  int dailyIntakeCount; // 하루 복용 횟수

  @HiveField(7)
  bool notificationEnabled;

  @HiveField(8)
  List<String>? notificationTimes; // "HH:mm" 형식의 문자열 리스트

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  Pill({
    required this.id,
    this.userId,
    required this.name,
    required this.color,
    this.brand,
    required this.icon,
    this.dailyIntakeCount = 1,
    this.notificationEnabled = false,
    this.notificationTimes,
    required this.createdAt,
    required this.updatedAt,
  });

  Pill copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    String? brand,
    String? icon,
    int? dailyIntakeCount,
    bool? notificationEnabled,
    List<String>? notificationTimes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pill(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      brand: brand ?? this.brand,
      icon: icon ?? this.icon,
      dailyIntakeCount: dailyIntakeCount ?? this.dailyIntakeCount,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationTimes: notificationTimes ?? this.notificationTimes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'color': color,
      'brand': brand,
      'icon': icon,
      'dailyIntakeCount': dailyIntakeCount,
      'notificationEnabled': notificationEnabled,
      'notificationTimes': notificationTimes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Pill.fromJson(Map<String, dynamic> json) {
    return Pill(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      name: json['name'] as String,
      color: json['color'] as String,
      brand: json['brand'] as String?,
      icon: json['icon'] as String,
      dailyIntakeCount: json['dailyIntakeCount'] as int? ?? 1,
      notificationEnabled: json['notificationEnabled'] as bool? ?? false,
      notificationTimes: json['notificationTimes'] != null
          ? List<String>.from(json['notificationTimes'] as List)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

