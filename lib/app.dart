import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/map_search/presentation/providers/location_provider.dart';

class OptiMealApp extends ConsumerWidget {
  const OptiMealApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Khởi tạo định vị ngay khi mở app để trình duyệt hiện prompt xin quyền,
    // thay vì đợi đến lúc người dùng mở Food Map.
    ref.watch(locationProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default light, can be switched via provider
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'), // Vietnamese (Default)
        Locale('en', 'US'), // English
      ],
      locale: const Locale('vi', 'VN'),
    );
  }
}
