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
        final isChecked = records.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: isChecked,
                  onChanged: (value) async {
                    await HomeWidgetService.togglePillCheck(
                      pill.id,
                      value ?? false,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _getColorFromHex(pill.color),
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
                  style: Theme.of(context).textTheme.bodyMedium,
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

