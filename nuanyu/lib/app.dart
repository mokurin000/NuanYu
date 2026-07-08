import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'routes.dart';

class NuanYuApp extends StatelessWidget {
  const NuanYuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: '暖屿',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: goRouter,
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
