import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pill_provider.dart';
import '../models/pill.dart';
import '../models/intake_record.dart';
import '../utils/helpers.dart';

class CalendarCheckScreen extends StatefulWidget {
  const CalendarCheckScreen({super.key});

  @override
  State<CalendarCheckScreen> createState() => _CalendarCheckScreenState();
}

class _CalendarCheckScreenState extends State<CalendarCheckScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('달력 & 체크'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: Column(
        children: [
          // 달력 영역
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 월 네비게이션
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month - 1,
                          );
                        });
                      },
                    ),
                    Text(
                      '${_selectedDate.year}년 ${_selectedDate.month}월',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 간단한 달력 뷰
                _buildSimpleCalendar(),
              ],
            ),
          ),
          const Divider(height: 1),
          // 체크 리스트 영역
          Expanded(
            child: _buildCheckList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCalendar() {
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final firstWeekday = firstDay.weekday;
    final daysInMonth = lastDay.day;

    return Consumer<PillProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // 요일 헤더
            Row(
              children: ['일', '월', '화', '수', '목', '금', '토']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // 날짜 그리드
            ...List.generate(
              (daysInMonth + firstWeekday - 1) ~/ 7 + 1,
              (weekIndex) {
                return Row(
                  children: List.generate(7, (dayIndex) {
                    final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 2;
                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return const Expanded(child: SizedBox());
                    }

                    final date = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      dayNumber,
                    );
                    final isSelected = DateHelper.isSameDay(date, _selectedDate);
                    final isToday = DateHelper.isToday(date);
                    final dateRecords = provider.getIntakeRecordsByDate(date);
                    
                    // 해당 날짜에 체크된 영양제들의 색상 가져오기
                    final checkedPillColors = <String>[];
                    for (final record in dateRecords) {
                      try {
                        final pill = provider.pills.firstWhere(
                          (p) => p.id == record.pillId,
                        );
                        if (!checkedPillColors.contains(pill.color)) {
                          checkedPillColors.add(pill.color);
                        }
                      } catch (e) {
                        // 영양제를 찾을 수 없는 경우 무시
                      }
                    }

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isToday
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$dayNumber',
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : null,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : null,
                                ),
                              ),
                              if (checkedPillColors.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Wrap(
                                    spacing: 2,
                                    alignment: WrapAlignment.center,
                                    children: checkedPillColors.map((colorHex) {
                                      return Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: _getColorFromHex(colorHex),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckList() {
    return Consumer<PillProvider>(
      builder: (context, provider, child) {
        final selectedDatePills = provider.todayPills;
        final selectedDateRecords =
            provider.getIntakeRecordsByDate(_selectedDate);

        if (selectedDatePills.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '등록된 영양제가 없습니다',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              DateHelper.isToday(_selectedDate)
                  ? '오늘 챙겨야 할 영양제'
                  : DateHelper.formatDate(_selectedDate),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...selectedDatePills.map((pill) {
              return _buildPillCheckItem(
                context,
                provider,
                pill,
                selectedDateRecords,
                _selectedDate,
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildPillCheckItem(
    BuildContext context,
    PillProvider provider,
    Pill pill,
    List<IntakeRecord> records,
    DateTime date,
  ) {
    final pillRecords = records
        .where((record) => record.pillId == pill.id)
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ColorFiltered(
          colorFilter: ColorFilter.mode(
            _getColorFromHex(pill.color),
            BlendMode.srcIn,
          ),
          child: Image.asset(
            'assets/images/icon-pill.png',
            width: 40,
            height: 40,
          ),
        ),
        title: Text(pill.name),
        subtitle: pill.brand != null ? Text(pill.brand!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            pill.dailyIntakeCount,
            (index) {
              final intakeCount = index + 1;
              final isChecked = pillRecords.any(
                (record) => record.intakeCount == intakeCount,
              );

              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: GestureDetector(
                  onTap: () async {
                    if (isChecked) {
                      // 체크 해제
                      final record = pillRecords.firstWhere(
                        (r) => r.intakeCount == intakeCount,
                      );
                      await provider.deleteIntakeRecord(record.id);
                    } else {
                      // 체크
                      await provider.addIntakeRecord(
                        pillId: pill.id,
                        date: date,
                        intakeCount: intakeCount,
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isChecked
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isChecked
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: isChecked
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 20,
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getColorFromHex(String hex) {
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }

}

