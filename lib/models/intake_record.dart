import 'package:hive/hive.dart';

part 'intake_record.g.dart';

@HiveType(typeId: 1)
class IntakeRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? userId; // 비로그인 상태에서는 null

  @HiveField(2)
  String pillId;

  @HiveField(3)
  DateTime date; // 복용 날짜 (시간 제외)

  @HiveField(4)
  int intakeCount; // 하루 중 몇 번째 복용인지 (1부터 시작)

  @HiveField(5)
  DateTime checkedAt; // 체크한 시간

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  bool? isLocal; // 로컬에서 생성된 데이터인지 표시

  IntakeRecord({
    required this.id,
    this.userId,
    required this.pillId,
    required this.date,
    required this.intakeCount,
    required this.checkedAt,
    required this.createdAt,
    this.isLocal,
  });

  IntakeRecord copyWith({
    String? id,
    String? userId,
    String? pillId,
    DateTime? date,
    int? intakeCount,
    DateTime? checkedAt,
    DateTime? createdAt,
    bool? isLocal,
  }) {
    return IntakeRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pillId: pillId ?? this.pillId,
      date: date ?? this.date,
      intakeCount: intakeCount ?? this.intakeCount,
      checkedAt: checkedAt ?? this.checkedAt,
      createdAt: createdAt ?? this.createdAt,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'pillId': pillId,
      'date': date.toIso8601String(),
      'intakeCount': intakeCount,
      'checkedAt': checkedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isLocal': isLocal,
    };
  }

  factory IntakeRecord.fromJson(Map<String, dynamic> json) {
    return IntakeRecord(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      pillId: json['pillId'] as String,
      date: DateTime.parse(json['date'] as String),
      intakeCount: json['intakeCount'] as int,
      checkedAt: DateTime.parse(json['checkedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isLocal: json['isLocal'] as bool?,
    );
  }

  // 날짜만 비교 (시간 제외)
  bool isSameDate(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }
}

