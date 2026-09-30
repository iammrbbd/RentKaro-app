class AppUpdateInfo {
  const AppUpdateInfo({
    required this.latestVersion,
    required this.minimumVersion,
    required this.forceUpdate,
    required this.updateUrl,
    required this.title,
    required this.message,
  });

  final String latestVersion;
  final String minimumVersion;
  final bool forceUpdate;
  final String updateUrl;
  final String title;
  final String message;

  factory AppUpdateInfo.fromJson(
      Map<String, dynamic> json,
      ) {
    return AppUpdateInfo(
      latestVersion:
      json['latest_version']?.toString() ??
          '1.0.0',
      minimumVersion:
      json['minimum_version']?.toString() ??
          '1.0.0',
      forceUpdate:
      json['force_update'] == true,
      updateUrl:
      json['update_url']?.toString() ?? '',
      title:
      json['title']?.toString() ??
          'New Update Available',
      message:
      json['message']?.toString() ??
          'A new version of RentKaro is available.',
    );
  }

  AppUpdateInfo copyWith({
    String? latestVersion,
    String? minimumVersion,
    bool? forceUpdate,
    String? updateUrl,
    String? title,
    String? message,
  }) {
    return AppUpdateInfo(
      latestVersion:
      latestVersion ?? this.latestVersion,
      minimumVersion:
      minimumVersion ?? this.minimumVersion,
      forceUpdate:
      forceUpdate ?? this.forceUpdate,
      updateUrl:
      updateUrl ?? this.updateUrl,
      title:
      title ?? this.title,
      message:
      message ?? this.message,
    );
  }
}