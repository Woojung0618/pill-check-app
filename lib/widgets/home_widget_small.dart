import 'package:flutter/material.dart';
import '../models/pill.dart';
import '../models/intake_record.dart';
import '../services/local_storage_service.dart';
import '../services/home_widget_service.dart';

class HomeWidgetSmall extends StatelessWidget {
  const HomeWidgetSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pill>>(
      future: _loadPills(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('등록된 영양제가 없습니다'),
          );
        }

        final pills = snapshot.data!;
        final today = DateTime.now();

        return Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오늘의 영양제',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...pills.take(3).map((pill) => _buildPillCheckItem(
                    context,
                    pill,
                    today,
                  )),
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
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: pillColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
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
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isChecked ? pillColor : Colors.transparent,
                          border: Border.all(
                            color: isChecked ? pillColor : Colors.grey.shade400,
                            width: 1.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: isChecked
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 10,
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  pillColor,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/images/icon-pill.png',
                  width: 14,
                  height: 14,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  pill.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: pillColor.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColorFromHex(String hex) {
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }

  Future<List<Pill>> _loadPills() async {
    return LocalStorageService.getAllPills();
  }

  Future<List<IntakeRecord>> _getIntakeRecords(
    String pillId,
    DateTime date,
  ) async {
    return LocalStorageService.getIntakeRecordsByPillAndDate(pillId, date);
  }
}

