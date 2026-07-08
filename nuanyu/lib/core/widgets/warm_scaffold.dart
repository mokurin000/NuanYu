import "package:flutter/material.dart";

import "../constants/app_colors.dart";

/// A warm-toned scaffold that wraps the standard Flutter Scaffold
/// with NuanYu's default background and app bar styling.
class WarmScaffold extends StatelessWidget {
  const WarmScaffold({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.body,
    this.floatingActionButton,
  });

  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: title != null || actions != null || leading != null
          ? AppBar(
              title: title != null
                  ? Text(
                      title!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    )
                  : null,
              actions: actions,
              leading: leading,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
