import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import '../models/pill.dart';
import '../models/intake_record.dart';
import '../services/local_storage_service.dart';
import '../utils/helpers.dart';

class PillProvider with ChangeNotifier {
  final _uuid = const Uuid();
  List<Pill> _pills = [];
  List<IntakeRecord> _intakeRecords = [];

  List<Pill> get pills => List.unmodifiable(_pills);
  List<IntakeRecord> get intakeRecords => List.unmodifiable(_intakeRecords);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription<List<Pill>>? _pillsSubscription;
  StreamSubscription<List<IntakeRecord>>? _recordsSubscription;

  PillProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadData();
    // 위젯 트리가 완전히 빌드된 후에 스트림 구독 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _watchData();
    });
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pills = LocalStorageService.getAllPills();
      _intakeRecords = LocalStorageService.getAllIntakeRecords();
    } catch (e) {
      debugPrint('데이터 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _watchData() {
    try {
      _pillsSubscription?.cancel();
      _pillsSubscription = LocalStorageService.watchPills().listen(
        (pills) {
          // 리스트가 변경되었거나, 내용이 변경되었는지 확인
          bool hasChanged = false;
          if (_pills.length != pills.length) {
            hasChanged = true;
          } else {
            // 각 영양제의 내용이 변경되었는지 확인
            for (int i = 0; i < pills.length; i++) {
              final newPill = pills[i];
              final oldPill = _pills.firstWhere(
                (p) => p.id == newPill.id,
                orElse: () => newPill,
              );
              if (oldPill.name != newPill.name ||
                  oldPill.color != newPill.color ||
                  oldPill.brand != newPill.brand ||
                  oldPill.icon != newPill.icon ||
                  oldPill.dailyIntakeCount != newPill.dailyIntakeCount ||
                  oldPill.notificationEnabled != newPill.notificationEnabled ||
                  oldPill.updatedAt != newPill.updatedAt) {
                hasChanged = true;
                break;
              }
            }
          }
          
          if (hasChanged) {
            _pills = pills;
            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('Pills watch 에러: $error');
        },
      );

      _recordsSubscription?.cancel();
      _recordsSubscription = LocalStorageService.watchIntakeRecords().listen(
        (records) {
          if (_intakeRecords.length != records.length ||
              !listEquals(_intakeRecords.map((r) => r.id).toList(),
                  records.map((r) => r.id).toList())) {
            _intakeRecords = records;
            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('IntakeRecords watch 에러: $error');
        },
      );
    } catch (e) {
      debugPrint('Watch 데이터 설정 실패: $e');
    }
  }

  @override
  void dispose() {
    _pillsSubscription?.cancel();
    _recordsSubscription?.cancel();
    super.dispose();
  }

  // 영양제 추가
  Future<void> addPill({
    required String name,
    required String color,
    String? brand,
    required String icon,
    int dailyIntakeCount = 1,
    bool notificationEnabled = false,
    List<String>? notificationTimes,
  }) async {
    try {
      final now = DateTime.now();
      final pill = Pill(
        id: _uuid.v4(),
        userId: null, // 비로그인 상태
        name: name,
        color: color,
        brand: brand,
        icon: icon,
        dailyIntakeCount: dailyIntakeCount,
        notificationEnabled: notificationEnabled,
        notificationTimes: notificationTimes,
        createdAt: now,
        updatedAt: now,
      );

      await LocalStorageService.savePill(pill);
      // _loadData()는 watch를 통해 자동으로 업데이트됨
    } catch (e) {
      debugPrint('영양제 추가 실패: $e');
      rethrow;
    }
  }

  // 영양제 수정
  Future<void> updatePill(Pill pill) async {
    try {
      // updatedAt이 이미 설정되어 있으면 그대로 사용, 아니면 현재 시간으로 설정
      final updatedPill = pill.updatedAt == pill.createdAt
          ? pill.copyWith(updatedAt: DateTime.now())
          : pill;
      await LocalStorageService.savePill(updatedPill);
      
      // watch 스트림이 변경을 감지하지 못할 수 있으므로 수동으로 업데이트
      final index = _pills.indexWhere((p) => p.id == pill.id);
      if (index != -1) {
        _pills[index] = updatedPill;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('영양제 수정 실패: $e');
      rethrow;
    }
  }

  // 영양제 삭제
  Future<void> deletePill(String pillId) async {
    try {
      // 관련된 복용 기록도 삭제
      final relatedRecords = _intakeRecords
          .where((record) => record.pillId == pillId)
          .toList();

      for (final record in relatedRecords) {
        await LocalStorageService.deleteIntakeRecord(record.id);
      }

      await LocalStorageService.deletePill(pillId);
    } catch (e) {
      debugPrint('영양제 삭제 실패: $e');
      rethrow;
    }
  }

  // 복용 기록 추가
  Future<void> addIntakeRecord({
    required String pillId,
    required DateTime date,
    required int intakeCount,
  }) async {
    try {
      final now = DateTime.now();
      final record = IntakeRecord(
        id: _uuid.v4(),
        userId: null, // 비로그인 상태
        pillId: pillId,
        date: DateHelper.getDateStart(date),
        intakeCount: intakeCount,
        checkedAt: now,
        createdAt: now,
        isLocal: true,
      );

      await LocalStorageService.saveIntakeRecord(record);
    } catch (e) {
      debugPrint('복용 기록 추가 실패: $e');
      rethrow;
    }
  }

  // 복용 기록 삭제
  Future<void> deleteIntakeRecord(String recordId) async {
    try {
      await LocalStorageService.deleteIntakeRecord(recordId);
    } catch (e) {
      debugPrint('복용 기록 삭제 실패: $e');
      rethrow;
    }
  }

  // 특정 날짜의 복용 기록 조회
  List<IntakeRecord> getIntakeRecordsByDate(DateTime date) {
    return _intakeRecords
        .where((record) => DateHelper.isSameDay(record.date, date))
        .toList();
  }

  // 특정 영양제의 특정 날짜 복용 기록 조회
  List<IntakeRecord> getIntakeRecordsByPillAndDate(
    String pillId,
    DateTime date,
  ) {
    return _intakeRecords
        .where((record) =>
            record.pillId == pillId &&
            DateHelper.isSameDay(record.date, date))
        .toList();
  }

  // 특정 날짜의 복용률 계산
  double getIntakeRateForDate(DateTime date) {
    if (_pills.isEmpty) return 0.0;

    final dateRecords = getIntakeRecordsByDate(date);
    final datePills = _pills.where((pill) {
      // 해당 날짜에 복용해야 하는 영양제인지 확인
      return true; // 모든 영양제가 매일 복용 대상
    }).toList();

    if (datePills.isEmpty) return 0.0;

    int totalRequired = 0;
    int totalChecked = 0;

    for (final pill in datePills) {
      totalRequired += pill.dailyIntakeCount;
      final pillRecords = dateRecords
          .where((record) => record.pillId == pill.id)
          .toList();
      totalChecked += pillRecords.length;
    }

    if (totalRequired == 0) return 0.0;
    return (totalChecked / totalRequired).clamp(0.0, 1.0);
  }

  // 오늘의 복용률
  double get todayIntakeRate => getIntakeRateForDate(DateTime.now());

  // 오늘의 영양제 목록
  List<Pill> get todayPills => _pills;

  // 특정 날짜에 복용했는지 확인
  bool isPillCheckedOnDate(String pillId, DateTime date, int intakeCount) {
    return _intakeRecords.any((record) =>
        record.pillId == pillId &&
        DateHelper.isSameDay(record.date, date) &&
        record.intakeCount == intakeCount);
  }
}

