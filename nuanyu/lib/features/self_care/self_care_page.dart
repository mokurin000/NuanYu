import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SelfCarePage extends StatelessWidget {
  const SelfCarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('关怀'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: const Center(child: Text('自我关怀', style: TextStyle(fontSize: 18))),
    );
  }
}
