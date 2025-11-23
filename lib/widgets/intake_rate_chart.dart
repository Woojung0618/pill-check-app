import 'package:flutter/material.dart';
import '../providers/pill_provider.dart';
import '../utils/helpers.dart';

class IntakeRateChart extends StatelessWidget {
  final PillProvider provider;
  final int days;

  const IntakeRateChart({
    super.key,
    required this.provider,
    this.days = 7,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final data = List.generate(days, (index) {
      final date = today.subtract(Duration(days: days - 1 - index));
      final rate = provider.getIntakeRateForDate(date);
      return {
        'date': date,
        'rate': rate,
      };
    });

    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((item) {
              final date = item['date'] as DateTime;
              final rate = item['rate'] as double;
              final isToday = DateHelper.isToday(date);

              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateHelper.formatDate(date).split('-')[2],
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
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
                                  borderRadius: BorderRadius.circular(4),
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
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(rate * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

