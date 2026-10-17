class AppInfoModel {
  final String appName;
  final String packageName;
  final String versionName;
  final int versionCode;
  final int targetSdk;
  final int minSdk;
  final bool isSystemApp;
  final int firstInstallTime;
  final int lastUpdateTime;
  final int permissionsCount;
  final List<String> permissions;

  const AppInfoModel({
    required this.appName,
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.targetSdk,
    required this.minSdk,
    required this.isSystemApp,
    required this.firstInstallTime,
    required this.lastUpdateTime,
    required this.permissionsCount,
    required this.permissions,
  });

  factory AppInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return AppInfoModel(
      appName: map['appName'] as String? ?? 'App',
      packageName: map['packageName'] as String? ?? '',
      versionName: map['versionName'] as String? ?? 'Unknown',
      versionCode: map['versionCode'] as int? ?? 0,
      targetSdk: map['targetSdk'] as int? ?? 0,
      minSdk: map['minSdk'] as int? ?? 0,
      isSystemApp: map['isSystemApp'] as bool? ?? false,
      firstInstallTime: map['firstInstallTime'] as int? ?? 0,
      lastUpdateTime: map['lastUpdateTime'] as int? ?? 0,
      permissionsCount: map['permissionsCount'] as int? ?? 0,
      permissions:
          (map['permissions'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'packageName': packageName,
      'versionName': versionName,
      'versionCode': versionCode,
      'targetSdk': targetSdk,
      'isSystemApp': isSystemApp,
      'permissionsCount': permissionsCount,
    };
  }
}
