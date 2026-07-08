import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../data/models/journal_entry.dart';
import 'providers/journal_provider.dart';

class JournalEditPage extends ConsumerStatefulWidget {
  final JournalEntry? existingEntry;

  const JournalEditPage({super.key, this.existingEntry});

  @override
  ConsumerState<JournalEditPage> createState() => _JournalEditPageState();
}

class _JournalEditPageState extends ConsumerState<JournalEditPage> {
  late TextEditingController _contentController;
  int? _moodScore;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.existingEntry?.content ?? '',
    );
    _moodScore = widget.existingEntry?.moodScore;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();

    if (widget.existingEntry != null) {
      final updated = widget.existingEntry!.copyWith(
        content: text,
        moodScore: () => _moodScore,
        updatedAt: () => now.toIso8601String(),
      );
      await ref.read(journalProvider.notifier).updateEntry(updated);
    } else {
      final entry = JournalEntry(
        id: '',
        date: du.formatDate(now),
        time: du.formatTime(now),
        content: text,
        moodScore: _moodScore,
        createdAt: now.toIso8601String(),
      );
      await ref.read(journalProvider.notifier).addEntry(entry);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final currentText = _contentController.text.trim();
        final originalText = widget.existingEntry?.content ?? '';
        if (currentText.isNotEmpty && currentText != originalText) {
          _showDiscardDialog();
        } else {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(widget.existingEntry != null ? '编辑日记' : '新建日记'),
          backgroundColor: AppColors.backgroundColor,
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text(
                '保存',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('关联情绪（可选）',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const Spacer(),
                  if (_moodScore != null)
                    Text(
                      '$_moodScore 分',
                      style: const TextStyle(color: AppColors.primaryColor),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 11,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final score = index;
                    final isSelected = _moodScore == score;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _moodScore = isSelected ? null : score;
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.cardColor,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.textSecondary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: '写下今天的想法...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('放弃编辑？'),
        content: const Text('你有未保存的内容，确定放弃吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('继续编辑'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: const Text('放弃', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
