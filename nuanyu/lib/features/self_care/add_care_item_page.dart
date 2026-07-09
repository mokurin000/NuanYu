import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/self_care_item.dart';
import 'providers/self_care_provider.dart';

class AddCareItemPage extends ConsumerStatefulWidget {
  const AddCareItemPage({super.key});

  @override
  ConsumerState<AddCareItemPage> createState() => _AddCareItemPageState();
}

class _AddCareItemPageState extends ConsumerState<AddCareItemPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _durationMinutes = 10;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;

    final item = SelfCareItem(
      id: '',
      title: _titleController.text.trim(),
      description:
          _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : null,
      durationMinutes: _durationMinutes,
      createdAt: DateTime.now().toIso8601String(),
    );

    await ref.read(selfCareProvider.notifier).addItem(item);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('新增关怀'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '标题',
                filled: true,
                fillColor: AppColors.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: '描述（可选）',
                filled: true,
                fillColor: AppColors.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            const Text(
              '建议时长',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _DurationButton(
                  label: '5分钟',
                  minutes: 5,
                  selected: _durationMinutes,
                  onTap: () => setState(() => _durationMinutes = 5),
                ),
                const SizedBox(width: 8),
                _DurationButton(
                  label: '10分钟',
                  minutes: 10,
                  selected: _durationMinutes,
                  onTap: () => setState(() => _durationMinutes = 10),
                ),
                const SizedBox(width: 8),
                _DurationButton(
                  label: '15分钟',
                  minutes: 15,
                  selected: _durationMinutes,
                  onTap: () => setState(() => _durationMinutes = 15),
                ),
                const SizedBox(width: 8),
                _DurationButton(
                  label: '30分钟',
                  minutes: 30,
                  selected: _durationMinutes,
                  onTap: () => setState(() => _durationMinutes = 30),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('保存', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DurationButton extends StatelessWidget {
  final String label;
  final int minutes;
  final int selected;
  final VoidCallback onTap;

  const _DurationButton({
    required this.label,
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = minutes == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
