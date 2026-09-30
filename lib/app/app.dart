import 'package:flutter/material.dart';

import '../core/app_update/app_update_gate.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class RentKaroApp extends StatelessWidget {
  const RentKaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RentKaro India',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      routerConfig: appRouter,

      builder: (
          context,
          child,
          ) {
        return AppUpdateGate(
          child: child ??
              const SizedBox.shrink(),
        );
      },
    );
  }
}