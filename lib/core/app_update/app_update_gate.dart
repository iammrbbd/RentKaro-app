import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_update_dialog.dart';
import 'app_update_service.dart';

class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> {
  bool _checking = false;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    if (_checking || _dialogShown || !mounted) {
      return;
    }

    _checking = true;

    try {
      // ======================================================
      // CURRENT APP VERSION
      // ======================================================

      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersion = packageInfo.version.trim();

      // ======================================================
      // CHECK BACKEND
      // ======================================================

      final service = AppUpdateService();

      final updateInfo = await service.checkForUpdate();

      // ======================================================
      // NO UPDATE INFORMATION
      // ======================================================

      if (updateInfo == null || !mounted) {
        return;
      }

      // ======================================================
      // CHECK MINIMUM SUPPORTED VERSION
      // ======================================================

      final minimumVersionRequiresUpdate =
      service.isForceUpdateRequired(
        currentVersion,
        updateInfo.minimumVersion,
      );

      // ======================================================
      // FINAL FORCE UPDATE DECISION
      // ======================================================
      //
      // Force update if:
      //
      // 1. Backend explicitly says force_update = true
      //
      // OR
      //
      // 2. Current app version is below minimum_version
      //
      // Using == true guarantees that both operands of ||
      // are actual bool values, regardless of whether the
      // source value is nullable/dynamic.
      // ======================================================

      final forceUpdate =
          updateInfo.forceUpdate == true ||
              minimumVersionRequiresUpdate == true;

      // ======================================================
      // FINAL UPDATE INFORMATION
      // ======================================================

      final finalInfo = updateInfo.copyWith(
        forceUpdate: forceUpdate,
      );

      if (!mounted) {
        return;
      }

      // ======================================================
      // PREVENT DUPLICATE DIALOG
      // ======================================================

      _dialogShown = true;

      // ======================================================
      // SHOW UPDATE DIALOG
      // ======================================================

      await showDialog<void>(
        context: context,
        barrierDismissible: !forceUpdate,
        builder: (_) {
          return AppUpdateDialog(
            updateInfo: finalInfo,
          );
        },
      );
    } catch (_) {
      // ======================================================
      // UPDATE CHECK MUST NEVER BLOCK THE APP
      // ======================================================
      //
      // If the server is unavailable, internet is unavailable,
      // response is invalid, or any other error occurs,
      // RentKaro continues normally.
      // ======================================================
    } finally {
      _checking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}