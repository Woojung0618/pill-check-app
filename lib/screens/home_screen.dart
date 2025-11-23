import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pill_provider.dart';
import '../screens/pill_register_screen.dart';
import '../screens/calendar_check_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/helpers.dart';
import '../widgets/intake_rate_chart.dart';
import '../widgets/pill_edit_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영양제 체크'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PillProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final today = DateTime.now();
          final intakeRate = provider.todayIntakeRate;
          final todayPills = provider.todayPills;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 오늘 날짜
                Text(
                  DateHelper.formatDate(today),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '오늘의 복용률',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                // 복용률 바 그래프
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(intakeRate * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${provider.getIntakeRecordsByDate(today).length} / ${todayPills.fold<int>(0, (sum, pill) => sum + pill.dailyIntakeCount)}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: intakeRate,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 오늘의 영양제 체크 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalendarCheckScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('오늘의 영양제 체크'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 최근 7일 그래프
                Text(
                  '최근 7일 복용률',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                IntakeRateChart(
                  provider: provider,
                  days: 7,
                ),
                const SizedBox(height: 24),

                // 영양제 목록
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '등록된 영양제',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PillRegisterScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('추가'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (todayPills.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
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
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PillRegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('영양제 추가하기'),
                        ),
                      ],
                    ),
                  )
                else
                  ...todayPills.map((pill) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
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
                          subtitle: pill.brand != null
                              ? Text(pill.brand!)
                              : Text('하루 ${pill.dailyIntakeCount}회'),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                // 수정 다이얼로그 표시
                                showDialog(
                                  context: context,
                                  builder: (context) => PillEditDialog(pill: pill),
                                );
                              } else if (value == 'delete') {
                                // 삭제 확인
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('삭제 확인'),
                                    content: Text('${pill.name}을(를) 삭제하시겠습니까?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('삭제'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await provider.deletePill(pill.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('삭제되었습니다')),
                                    );
                                  }
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('수정'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 20),
                                    SizedBox(width: 8),
                                    Text('삭제'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PillRegisterScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('영양제 추가'),
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

