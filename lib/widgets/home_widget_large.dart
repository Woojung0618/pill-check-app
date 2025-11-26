import 'package:flutter/material.dart';
import '../models/pill.dart';
import '../models/intake_record.dart';
import '../utils/helpers.dart';
import '../services/local_storage_service.dart';
import '../services/home_widget_service.dart';

class HomeWidgetLarge extends StatelessWidget {
  const HomeWidgetLarge({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pill>>(
      future: Future.value(_loadPills()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final pills = snapshot.data!;

        if (pills.isEmpty) {
          return const Center(
            child: Text('등록된 영양제가 없습니다'),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 오늘의 영양제 체크 리스트
              Text(
                '오늘의 영양제',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(
                flex: 2,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pills.length,
                  itemBuilder: (context, index) {
                    return _buildPillCheckItem(
                      context,
                      pills[index],
                      DateTime.now(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // 최근 7일 복용률 그래프
              Text(
                '최근 7일 복용률',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 1,
                child: _buildIntakeRateChart(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPillCheckItem(BuildContext context, Pill pill, DateTime date) {
    return FutureBuilder<List<IntakeRecord>>(
      future: _getIntakeRecords(pill.id, date),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];
        final pillColor = _getColorFromHex(pill.color);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: pillColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: pillColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 복용횟수만큼 체크박스 생성
              ...List.generate(
                pill.dailyIntakeCount,
                (index) {
                  final intakeCount = index + 1;
                  final isChecked = records.any(
                    (record) => record.intakeCount == intakeCount,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () async {
                        if (isChecked) {
                          // 체크 해제
                          final record = records.firstWhere(
                            (r) => r.intakeCount == intakeCount,
                            orElse: () => records.first,
                          );
                          await HomeWidgetService.togglePillCheck(
                            pill.id,
                            false,
                            intakeCount: intakeCount,
                            recordId: record.id,
                          );
                        } else {
                          // 체크
                          await HomeWidgetService.togglePillCheck(
                            pill.id,
                            true,
                            intakeCount: intakeCount,
                          );
                        }
                      },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isChecked ? pillColor : Colors.transparent,
                          border: Border.all(
                            color: isChecked ? pillColor : Colors.grey.shade400,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: isChecked
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  pillColor,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/icon-pill.png',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pill.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: pillColor.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (pill.brand != null)
                      Text(
                        pill.brand!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: pillColor.withOpacity(0.7),
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Pill> _loadPills() {
    return LocalStorageService.getAllPills();
  }

  Future<List<IntakeRecord>> _getIntakeRecords(
    String pillId,
    DateTime date,
  ) {
    return Future.value(
      LocalStorageService.getIntakeRecordsByPillAndDate(pillId, date),
    );
  }

  Widget _buildIntakeRateChart(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadChartData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((item) {
              final date = item['date'] as DateTime;
              final rate = item['rate'] as double;
              final isToday = DateHelper.isToday(date);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateHelper.formatDate(date).split('-')[2],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                            ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 60,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: constraints.maxHeight,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                FractionallySizedBox(
                                  heightFactor: rate,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(rate * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 8,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadChartData() async {
    final pills = LocalStorageService.getAllPills();
    final today = DateTime.now();
    final data = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final records = LocalStorageService.getIntakeRecordsByDate(date);
      
      // PillProvider.getIntakeRateForDate와 동일한 로직
      int totalRequired = 0;
      int totalChecked = 0;

      for (final pill in pills) {
        totalRequired += pill.dailyIntakeCount;
        final pillRecords = records
            .where((record) => record.pillId == pill.id)
            .toList();
        totalChecked += pillRecords.length;
      }

      final rate = totalRequired > 0 
          ? (totalChecked / totalRequired).clamp(0.0, 1.0)
          : 0.0;

      data.add({
        'date': date,
        'rate': rate,
      });
    }

    return data;
  }

  Color _getColorFromHex(String hex) {
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }
}

