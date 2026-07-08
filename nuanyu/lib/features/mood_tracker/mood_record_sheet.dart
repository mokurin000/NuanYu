import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../core/utils/mood_utils.dart';
import '../../data/models/mood_entry.dart';
import 'providers/mood_provider.dart';

class MoodRecordSheet extends ConsumerStatefulWidget {
  final MoodEntry? existingEntry;

  const MoodRecordSheet({super.key, this.existingEntry});

  @override
  ConsumerState<MoodRecordSheet> createState() => _MoodRecordSheetState();
}

class _MoodRecordSheetState extends ConsumerState<MoodRecordSheet> {
  late double _moodScore;
  late List<String> _selectedLabels;
  late TextEditingController _noteController;

  static const _emotionLabels = [
    '平静', '开心', '感恩', '希望', '满足',
    '焦虑', '悲伤', '愤怒', '恐惧', '羞愧',
    '孤独', '麻木', '疲惫', '困惑',
  ];

  @override
  void initState() {
    super.initState();
    _moodScore = widget.existingEntry?.moodScore.toDouble() ?? 5.0;
    final existingLabel = widget.existingEntry?.emotionLabel;
    _selectedLabels = existingLabel != null && existingLabel.isNotEmpty
        ? existingLabel.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList()
        : [];
    _noteController = TextEditingController(text: widget.existingEntry?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final labelsStr = _selectedLabels.isNotEmpty ? _selectedLabels.join('、') : null;
    final entry = MoodEntry(
      id: widget.existingEntry?.id ?? '',
      date: du.formatDate(now),
      time: du.formatTime(now),
      moodScore: _moodScore.round(),
      emotionLabel: labelsStr,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      createdAt: now.toIso8601String(),
    );

    if (widget.existingEntry != null) {
      await ref.read(moodProvider.notifier).updateEntry(entry);
    } else {
      await ref.read(moodProvider.notifier).addEntry(entry);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final color = moodColor(_moodScore.round());
    final label = moodLabel(_moodScore.round());

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '情绪评分',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${_moodScore.round()}',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            Center(
              child: Text(label, style: TextStyle(fontSize: 16, color: color)),
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                thumbColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _moodScore,
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) => setState(() => _moodScore = v),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '情绪标签（可多选）',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const Spacer(),
                if (_selectedLabels.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _selectedLabels.clear()),
                    child: const Text(
                      '清除',
                      style: TextStyle(fontSize: 13, color: AppColors.primaryColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emotionLabels.map((lbl) {
                final isSelected = _selectedLabels.contains(lbl);
                return FilterChip(
                  label: Text(lbl, style: const TextStyle(fontSize: 13)),
                  selected: isSelected,
                  selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
                  backgroundColor: AppColors.cardColor,
                  checkmarkColor: AppColors.primaryColor,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedLabels.add(lbl);
                      } else {
                        _selectedLabels.remove(lbl);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: '备注（可选）',
                filled: true,
                fillColor: AppColors.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('保存', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
