import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import 'providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          // Export section
          _SectionHeader(title: '数据管理'),
          ListTile(
            leading: const Icon(Icons.download, color: AppColors.primaryColor),
            title: const Text('导出全部数据'),
            subtitle: const Text('将所有记录导出为 JSON 文件'),
            trailing: _exportTrailing(state),
            onTap: state.exportStatus == ExportStatus.exporting
                ? null
                : () => ref.read(settingsProvider.notifier).exportAllData(),
          ),
          if (state.exportStatus == ExportStatus.done && state.exportPath != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '已导出到: ${state.exportPath}',
                style: const TextStyle(fontSize: 12, color: AppColors.moodGreat),
              ),
            ),
          if (state.exportStatus == ExportStatus.cancelled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('已取消导出', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
          if (state.exportStatus == ExportStatus.error)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '导出失败: ${state.exportError}',
                style: const TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
            ),
          const Divider(),
          // About section
          _SectionHeader(title: '关于'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primaryColor),
            title: const Text('关于暖屿'),
            subtitle: const Text('版本 1.0.0'),
            onTap: () => _showAboutDialog(context),
          ),
          const ListTile(
            leading: Icon(Icons.favorite, color: AppColors.primaryColor),
            title: Text('暖屿'),
            subtitle: Text('CPTSD 自我管理 · 温暖陪伴'),
          ),
          const Divider(),
          // Bio auth section
          _SectionHeader(title: '安全'),
          const ListTile(
            leading: Icon(Icons.fingerprint, color: AppColors.primaryColor),
            title: Text('生物验证锁'),
            subtitle: Text('启动应用时需要验证身份'),
            trailing: Icon(Icons.check, color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget? _exportTrailing(SettingsState state) {
    switch (state.exportStatus) {
      case ExportStatus.idle:
        return const Icon(Icons.chevron_right, color: AppColors.textSecondary);
      case ExportStatus.exporting:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case ExportStatus.done:
        return const Icon(Icons.check_circle, color: AppColors.moodGreat);
      case ExportStatus.error:
        return const Icon(Icons.error, color: Colors.redAccent);
      case ExportStatus.cancelled:
        return const Icon(Icons.close, color: AppColors.textSecondary);
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('关于暖屿'),
        content: const Text(
          '暖屿是一款专为 CPTSD 人群设计的自我管理工具。\n\n'
          '功能包括呼吸练习、情绪追踪、自我关怀和日记记录。\n\n'
          '纯离线设计，所有数据仅存储在您的设备上。\n\n'
          '愿你在此找到一片温暖的岛屿。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}


