import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pill_provider.dart';
import '../utils/constants.dart';

class PillRegisterScreen extends StatefulWidget {
  const PillRegisterScreen({super.key});

  @override
  State<PillRegisterScreen> createState() => _PillRegisterScreenState();
}

class _PillRegisterScreenState extends State<PillRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();

  String _selectedColor = PillColors.colorToHex(PillColors.colorPalette[0]);
  int _dailyIntakeCount = 1;
  bool _notificationEnabled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _savePill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final provider = Provider.of<PillProvider>(context, listen: false);
      await provider.addPill(
        name: _nameController.text.trim(),
        color: _selectedColor,
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        icon: 'pill', // 항상 알약 아이콘 사용
        dailyIntakeCount: _dailyIntakeCount,
        notificationEnabled: _notificationEnabled,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('영양제가 등록되었습니다')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영양제 등록'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
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

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePill,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

