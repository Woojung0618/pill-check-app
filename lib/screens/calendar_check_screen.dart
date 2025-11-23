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
        title: Row(
          mainAxisSize: MainAxisSize.min,
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
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            GestureDetector(
              onTap: () => _showYearMonthPicker(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_selectedDate.year}년 ${_selectedDate.month}월',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
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
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
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
          GestureDetector(
            onHorizontalDragEnd: (details) {
              // 스와이프 속도와 방향 감지
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! > 0) {
                  // 오른쪽으로 스와이프 (이전 달)
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month - 1,
                    );
                  });
                } else if (details.primaryVelocity! < 0) {
                  // 왼쪽으로 스와이프 (다음 달)
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month + 1,
                    );
                  });
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 간단한 달력 뷰
                  _buildSimpleCalendar(),
                ],
              ),
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
                                : isToday
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                    : Colors.transparent,
                            shape: BoxShape.circle,
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
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: checkedPillColors.isNotEmpty
                                    ? Wrap(
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
                                      )
                                    : const SizedBox(height: 6), // 동그라미가 없어도 공간 확보
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

  void _showYearMonthPicker(BuildContext context) {
    final currentYear = _selectedDate.year;
    final currentMonth = _selectedDate.month;
    
    // 년도 범위 설정 (현재 년도 기준 ±50년)
    final now = DateTime.now();
    final minYear = now.year - 50;
    final maxYear = now.year + 50;
    final years = List.generate(maxYear - minYear + 1, (index) => minYear + index);
    final months = List.generate(12, (index) => index + 1);
    
    int selectedYear = currentYear;
    int selectedMonth = currentMonth;
    
    final FixedExtentScrollController yearController = FixedExtentScrollController(
      initialItem: years.indexOf(currentYear),
    );
    final FixedExtentScrollController monthController = FixedExtentScrollController(
      initialItem: currentMonth - 1,
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '년월 선택',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // 스크롤 선택 영역
                Expanded(
                  child: Row(
                    children: [
                      // 년도 선택 휠
                      Expanded(
                        child: Column(
                          children: [
                            
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: yearController,
                                itemExtent: 50,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  setDialogState(() {
                                    selectedYear = years[index];
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    final year = years[index];
                                    final isSelected = year == selectedYear;
                                    return Center(
                                      child: Text(
                                        '$year년',
                                        style: TextStyle(
                                          fontSize: isSelected ? 20 : 16,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: years.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 월 선택 휠
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListWheelScrollView.useDelegate(
                                controller: monthController,
                                itemExtent: 50,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  setDialogState(() {
                                    selectedMonth = months[index];
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    final month = months[index];
                                    final isSelected = month == selectedMonth;
                                    return Center(
                                      child: Text(
                                        '$month월',
                                        style: TextStyle(
                                          fontSize: isSelected ? 20 : 16,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: months.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 선택된 년월 표시
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$selectedYear년 $selectedMonth월',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                // 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(selectedYear, selectedMonth);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('확인'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

