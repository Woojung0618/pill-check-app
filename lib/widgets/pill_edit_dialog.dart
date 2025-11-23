import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pill_provider.dart';
import '../models/pill.dart';
import '../utils/constants.dart';

class PillEditDialog extends StatefulWidget {
  final Pill pill;

  const PillEditDialog({
    super.key,
    required this.pill,
  });

  @override
  State<PillEditDialog> createState() => _PillEditDialogState();
}

class _PillEditDialogState extends State<PillEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;

  late String _selectedColor;
  late int _dailyIntakeCount;
  late bool _notificationEnabled;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pill.name);
    _brandController = TextEditingController(text: widget.pill.brand ?? '');
    _selectedColor = widget.pill.color;
    _dailyIntakeCount = widget.pill.dailyIntakeCount;
    _notificationEnabled = widget.pill.notificationEnabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _updatePill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final provider = Provider.of<PillProvider>(context, listen: false);
      final updatedPill = widget.pill.copyWith(
        name: _nameController.text.trim(),
        color: _selectedColor,
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        icon: 'pill', // 항상 알약 아이콘 사용
        dailyIntakeCount: _dailyIntakeCount,
        notificationEnabled: _notificationEnabled,
        updatedAt: DateTime.now(),
      );

      await provider.updatePill(updatedPill);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('영양제가 수정되었습니다')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '영양제 수정',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 내용
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 영양제 이름
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '영양제 이름 *',
                          hintText: '예: 비타민D',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '영양제 이름을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // 색상 선택
                      Text(
                        '색상 선택',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(
                          PillColors.colorPalette.length,
                          (index) {
                            final color = PillColors.colorPalette[index];
                            final colorHex = PillColors.colorToHex(color);
                            final isSelected = _selectedColor == colorHex;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = colorHex;
                                });
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.shade300,
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: color == Colors.white
                                            ? Colors.black
                                            : Colors.white,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 브랜드 (선택)
                      TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                          labelText: '브랜드 (선택)',
                          hintText: '예: 네이처메이드',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 하루 복용 횟수
                      Text(
                        '하루 복용 횟수',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<int>(
                        segments: List.generate(
                          5,
                          (index) => ButtonSegment(
                            value: index + 1,
                            label: Text('${index + 1}회'),
                          ),
                        ),
                        selected: {_dailyIntakeCount},
                        onSelectionChanged: (Set<int> newSelection) {
                          setState(() {
                            _dailyIntakeCount = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // 알림 설정
                      SwitchListTile(
                        title: const Text('알림 설정'),
                        subtitle: const Text('복용 시간에 알림을 받습니다'),
                        value: _notificationEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationEnabled = value;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            // 저장 버튼
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updatePill,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('저장'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

