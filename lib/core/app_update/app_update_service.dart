import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_update_model.dart';

class AppUpdateService {
  AppUpdateService()
      : _dio = Dio(
    BaseOptions(
      baseUrl: 'https://rentkaro.up.railway.app',
      connectTimeout:
      const Duration(seconds: 10),
      receiveTimeout:
      const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  final Dio _dio;

  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo =
      await PackageInfo.fromPlatform();

      final currentVersion =
      packageInfo.version.trim();

      final response =
      await _dio.get(
        '/api/app/version',
        queryParameters: {
          'current_version':
          currentVersion,
          'build_number':
          packageInfo.buildNumber,
        },
      );

      if (response.data is! Map) {
        return null;
      }

      final data =
      Map<String, dynamic>.from(
        response.data as Map,
      );

      final updateInfo =
      AppUpdateInfo.fromJson(data);

      final needsUpdate =
      _isVersionLower(
        currentVersion,
        updateInfo.latestVersion,
      );

      if (!needsUpdate) {
        return null;
      }

      return updateInfo;
    } catch (_) {
      // Version checking must never block
      // the user from opening the app.
      return null;
    }
  }

  Future<bool> isForceUpdateRequired(
      String currentVersion,
      String minimumVersion,
      ) async {
    return _isVersionLower(
      currentVersion,
      minimumVersion,
    );
  }

  bool _isVersionLower(
      String currentVersion,
      String targetVersion,
      ) {
    final current =
    _parseVersion(currentVersion);

    final target =
    _parseVersion(targetVersion);

    final length =
    current.length > target.length
        ? current.length
        : target.length;

    for (var i = 0; i < length; i++) {
      final currentPart =
      i < current.length
          ? current[i]
          : 0;

      final targetPart =
      i < target.length
          ? target[i]
          : 0;

      if (currentPart < targetPart) {
        return true;
      }

      if (currentPart > targetPart) {
        return false;
      }
    }

    return false;
  }

  List<int> _parseVersion(
      String version,
      ) {
    final cleanVersion =
        version.trim().split('+').first;

    return cleanVersion
        .split('.')
        .map(
          (part) =>
      int.tryParse(part) ?? 0,
    )
        .toList();
  }
}