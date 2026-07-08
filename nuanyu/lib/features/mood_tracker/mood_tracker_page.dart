import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MoodTrackerPage extends StatelessWidget {
  const MoodTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('情绪'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: const Center(child: Text('情绪追踪', style: TextStyle(fontSize: 18))),
    );
  }
}
