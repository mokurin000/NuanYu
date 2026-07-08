import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: const Center(child: Text('设置', style: TextStyle(fontSize: 18))),
    );
  }
}
