import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class JournalListPage extends StatelessWidget {
  const JournalListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('日记'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: const Center(child: Text('日记记录', style: TextStyle(fontSize: 18))),
    );
  }
}
