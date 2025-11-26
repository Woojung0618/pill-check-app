import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/intake_record.dart';
import '../services/local_storage_service.dart';
import '../utils/helpers.dart';

class HomeWidgetService {
  static const String _widgetName = 'PillCheckWidget';

  /// 위젯 초기화
  /// 
  /// iOS: App Group 설정 필요 (Xcode에서 WidgetKit Extension 추가 후)
  /// Android: AndroidManifest.xml에 위젯 등록 필요 (이미 완료됨)
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId('group.pill.check.app');
      debugPrint('위젯 초기화 성공');
    } catch (e) {
      debugPrint('위젯 초기화 실패: $e');
      debugPrint('iOS의 경우: Xcode에서 WidgetKit Extension을 추가하고 App Group을 설정해야 합니다.');
      debugPrint('자세한 내용은 WIDGET_SETUP_GUIDE.md를 참고하세요.');
      rethrow;
    }
  }

  /// 위젯 업데이트
  static Future<void> updateWidget() async {
    try {
      final pills = LocalStorageService.getAllPills();
      final today = DateTime.now();
      
      debugPrint('위젯 업데이트 시작: 영양제 ${pills.length}개');
      
      // 오늘의 복용률 계산
      final todayRecords = LocalStorageService.getIntakeRecordsByDate(today);
      final totalRequired = pills.fold<int>(0, (sum, pill) => sum + pill.dailyIntakeCount);
      final totalChecked = todayRecords.length;
      final intakeRate = totalRequired > 0 ? (totalChecked / totalRequired) : 0.0;

      debugPrint('복용률: $totalChecked/$totalRequired = ${intakeRate.toStringAsFixed(2)}');

      // 위젯 데이터 업데이트
      await HomeWidget.saveWidgetData<String>('pill_count', '${pills.length}');
      await HomeWidget.saveWidgetData<String>('checked_count', '$totalChecked');
      await HomeWidget.saveWidgetData<String>('total_required', '$totalRequired');
      await HomeWidget.saveWidgetData<String>('intake_rate', intakeRate.toStringAsFixed(2));
      await HomeWidget.saveWidgetData<String>('date', DateHelper.formatDate(today));

      // 영양제 목록 (최대 5개) - JSON 문자열로 변환하여 저장
      final pillsData = pills.take(5).map((pill) => {
        'id': pill.id,
        'name': pill.name,
        'color': pill.color,
        'brand': pill.brand ?? '',
      }).toList();

      final pillsJson = jsonEncode(pillsData);
      await HomeWidget.saveWidgetData<String>('pills', pillsJson);
      debugPrint('영양제 데이터 저장: $pillsJson');

      // 각 영양제의 체크 상태 - JSON 문자열로 변환하여 저장
      final checkedPills = <String>[];
      for (final pill in pills.take(5)) {
        final records = LocalStorageService.getIntakeRecordsByPillAndDate(
          pill.id,
          today,
        );
        if (records.isNotEmpty) {
          checkedPills.add(pill.id);
        }
      }
      final checkedPillsJson = jsonEncode(checkedPills);
      await HomeWidget.saveWidgetData<String>('checked_pills', checkedPillsJson);
      debugPrint('체크된 영양제: $checkedPillsJson');

      // 위젯 새로고침
      // androidName은 AndroidManifest.xml에 등록된 AppWidgetProvider의 클래스 이름과 일치해야 합니다
      await HomeWidget.updateWidget(
        name: _widgetName,
        iOSName: 'PillCheckWidget',
        androidName: 'PillCheckWidgetProvider',
      );
      
      debugPrint('위젯 업데이트 완료');
    } catch (e, stackTrace) {
      debugPrint('위젯 업데이트 실패: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// 위젯에서 체크 상태 변경
  static Future<void> togglePillCheck(
    String pillId,
    bool isChecked, {
    int? intakeCount,
    String? recordId,
  }) async {
    try {
      final today = DateTime.now();
      
      if (isChecked) {
        // 체크 추가
        final now = DateTime.now();
        final record = IntakeRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: null,
          pillId: pillId,
          date: DateHelper.getDateStart(today),
          intakeCount: intakeCount ?? 1,
          checkedAt: now,
          createdAt: now,
          isLocal: true,
        );
        await LocalStorageService.saveIntakeRecord(record);
      } else {
        // 체크 제거
        if (recordId != null) {
          // 특정 recordId로 삭제
          await LocalStorageService.deleteIntakeRecord(recordId);
        } else {
          // intakeCount로 찾아서 삭제
          final records = LocalStorageService.getIntakeRecordsByPillAndDate(
            pillId,
            today,
          );
          if (intakeCount != null) {
            final record = records.firstWhere(
              (r) => r.intakeCount == intakeCount,
              orElse: () => records.first,
            );
            if (records.isNotEmpty) {
              await LocalStorageService.deleteIntakeRecord(record.id);
            }
          } else if (records.isNotEmpty) {
            await LocalStorageService.deleteIntakeRecord(records.first.id);
          }
        }
      }

      // 위젯 업데이트
      await updateWidget();
    } catch (e) {
      debugPrint('위젯 체크 토글 실패: $e');
    }
  }
}

