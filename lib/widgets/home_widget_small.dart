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
        final isChecked = records.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
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
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pill.name,
                  style: Theme.of(context).textTheme.bodySmall,
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
}

