import 'package:flutter/material.dart';
import '../models/pill.dart';
import '../models/intake_record.dart';
import '../services/local_storage_service.dart';
import '../services/home_widget_service.dart';

class HomeWidgetMedium extends StatelessWidget {
  const HomeWidgetMedium({super.key});

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
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오늘의 영양제',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pills.length > 5 ? 5 : pills.length,
                  itemBuilder: (context, index) {
                    return _buildPillCheckItem(
                      context,
                      pills[index],
                      today,
                    );
                  },
                ),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: pillColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
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
                        width: 18,
                        height: 18,
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
                                size: 12,
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
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pill.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Future<List<Pill>> _loadPills() async {
    return LocalStorageService.getAllPills();
  }

  Future<List<IntakeRecord>> _getIntakeRecords(
    String pillId,
    DateTime date,
  ) async {
    return LocalStorageService.getIntakeRecordsByPillAndDate(pillId, date);
  }

  Color _getColorFromHex(String hex) {
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }
}

