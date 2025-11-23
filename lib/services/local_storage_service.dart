import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pill.dart';
import '../models/intake_record.dart';
import '../utils/constants.dart';

class LocalStorageService {
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      
      // TypeAdapter 등록
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(PillAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(IntakeRecordAdapter());
      }

      // Box 열기 (이미 열려있으면 무시)
      if (!Hive.isBoxOpen(HiveBoxes.pills)) {
        await Hive.openBox<Pill>(HiveBoxes.pills);
      }
      if (!Hive.isBoxOpen(HiveBoxes.intakeRecords)) {
        await Hive.openBox<IntakeRecord>(HiveBoxes.intakeRecords);
      }
    } catch (e) {
      debugPrint('LocalStorageService 초기화 에러: $e');
      rethrow;
    }
  }

  // Pill 관련 메서드
  static Box<Pill>? get _pillsBox {
    try {
      if (Hive.isBoxOpen(HiveBoxes.pills)) {
        return Hive.box<Pill>(HiveBoxes.pills);
      }
      return null;
    } catch (e) {
      debugPrint('PillsBox 접근 에러: $e');
      return null;
    }
  }

  static Future<void> savePill(Pill pill) async {
    final box = _pillsBox;
    if (box == null) {
      throw Exception('PillsBox가 열려있지 않습니다');
    }
    await box.put(pill.id, pill);
  }

  static Future<void> deletePill(String pillId) async {
    final box = _pillsBox;
    if (box == null) {
      throw Exception('PillsBox가 열려있지 않습니다');
    }
    await box.delete(pillId);
  }

  static Pill? getPill(String pillId) {
    final box = _pillsBox;
    if (box == null) return null;
    return box.get(pillId);
  }

  static List<Pill> getAllPills() {
    final box = _pillsBox;
    if (box == null) return [];
    return box.values.toList();
  }

  static Stream<List<Pill>> watchPills() {
    final box = _pillsBox;
    if (box == null) {
      return Stream.value([]);
    }
    return box.watch().map((_) => getAllPills());
  }

  // IntakeRecord 관련 메서드
  static Box<IntakeRecord>? get _intakeRecordsBox {
    try {
      if (Hive.isBoxOpen(HiveBoxes.intakeRecords)) {
        return Hive.box<IntakeRecord>(HiveBoxes.intakeRecords);
      }
      return null;
    } catch (e) {
      debugPrint('IntakeRecordsBox 접근 에러: $e');
      return null;
    }
  }

  static Future<void> saveIntakeRecord(IntakeRecord record) async {
    final box = _intakeRecordsBox;
    if (box == null) {
      throw Exception('IntakeRecordsBox가 열려있지 않습니다');
    }
    await box.put(record.id, record);
  }

  static Future<void> deleteIntakeRecord(String recordId) async {
    final box = _intakeRecordsBox;
    if (box == null) {
      throw Exception('IntakeRecordsBox가 열려있지 않습니다');
    }
    await box.delete(recordId);
  }

  static IntakeRecord? getIntakeRecord(String recordId) {
    final box = _intakeRecordsBox;
    if (box == null) return null;
    return box.get(recordId);
  }

  static List<IntakeRecord> getAllIntakeRecords() {
    final box = _intakeRecordsBox;
    if (box == null) return [];
    return box.values.toList();
  }

  static List<IntakeRecord> getIntakeRecordsByPillId(String pillId) {
    final box = _intakeRecordsBox;
    if (box == null) return [];
    return box.values
        .where((record) => record.pillId == pillId)
        .toList();
  }

  static List<IntakeRecord> getIntakeRecordsByDate(DateTime date) {
    final box = _intakeRecordsBox;
    if (box == null) return [];
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(const Duration(days: 1));

    return box.values
        .where((record) =>
            record.date.isAfter(dateStart.subtract(const Duration(seconds: 1))) &&
            record.date.isBefore(dateEnd))
        .toList();
  }

  static List<IntakeRecord> getIntakeRecordsByPillAndDate(
    String pillId,
    DateTime date,
  ) {
    final box = _intakeRecordsBox;
    if (box == null) return [];
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(const Duration(days: 1));

    return box.values
        .where((record) =>
            record.pillId == pillId &&
            record.date.isAfter(dateStart.subtract(const Duration(seconds: 1))) &&
            record.date.isBefore(dateEnd))
        .toList();
  }

  static Stream<List<IntakeRecord>> watchIntakeRecords() {
    final box = _intakeRecordsBox;
    if (box == null) {
      return Stream.value([]);
    }
    return box.watch().map((_) => getAllIntakeRecords());
  }

  // 데이터 초기화 (테스트용)
  static Future<void> clearAll() async {
    final pillsBox = _pillsBox;
    final recordsBox = _intakeRecordsBox;
    if (pillsBox != null) await pillsBox.clear();
    if (recordsBox != null) await recordsBox.clear();
  }
}

