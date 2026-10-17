class MemoryInfoModel {
  final int totalMemBytes;
  final int availMemBytes;
  final int thresholdBytes;
  final bool isLowMemory;
  final int appHeapAllocatedBytes;
  final int appHeapFreeBytes;
  final int appHeapMaxBytes;
  final int appUsedBytes;

  const MemoryInfoModel({
    required this.totalMemBytes,
    required this.availMemBytes,
    required this.thresholdBytes,
    required this.isLowMemory,
    required this.appHeapAllocatedBytes,
    required this.appHeapFreeBytes,
    required this.appHeapMaxBytes,
    required this.appUsedBytes,
  });

  int get usedMemBytes => totalMemBytes - availMemBytes;
  double get usedPercentage =>
      totalMemBytes > 0 ? (usedMemBytes / totalMemBytes) * 100 : 0.0;

  factory MemoryInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return MemoryInfoModel(
      totalMemBytes: map['totalMemBytes'] as int? ?? 0,
      availMemBytes: map['availMemBytes'] as int? ?? 0,
      thresholdBytes: map['thresholdBytes'] as int? ?? 0,
      isLowMemory: map['isLowMemory'] as bool? ?? false,
      appHeapAllocatedBytes: map['appHeapAllocatedBytes'] as int? ?? 0,
      appHeapFreeBytes: map['appHeapFreeBytes'] as int? ?? 0,
      appHeapMaxBytes: map['appHeapMaxBytes'] as int? ?? 0,
      appUsedBytes: map['appUsedBytes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMemBytes': totalMemBytes,
      'availMemBytes': availMemBytes,
      'usedMemBytes': usedMemBytes,
      'usedPercentage': usedPercentage,
      'isLowMemory': isLowMemory,
      'appHeapAllocatedBytes': appHeapAllocatedBytes,
      'appUsedBytes': appUsedBytes,
    };
  }
}

class StorageVolumeModel {
  final String path;
  final bool isRemovable;
  final bool isEmulated;
  final int totalBytes;
  final int availableBytes;
  final String type;

  const StorageVolumeModel({
    required this.path,
    required this.isRemovable,
    required this.isEmulated,
    required this.totalBytes,
    required this.availableBytes,
    required this.type,
  });

  int get usedBytes => totalBytes - availableBytes;
  double get usedPercentage =>
      totalBytes > 0 ? (usedBytes / totalBytes) * 100 : 0.0;

  factory StorageVolumeModel.fromMap(Map<dynamic, dynamic> map) {
    return StorageVolumeModel(
      path: map['path'] as String? ?? '',
      isRemovable: map['isRemovable'] as bool? ?? false,
      isEmulated: map['isEmulated'] as bool? ?? false,
      totalBytes: map['totalBytes'] as int? ?? 0,
      availableBytes: map['availableBytes'] as int? ?? 0,
      type: map['type'] as String? ?? 'Storage',
    );
  }
}

class StorageInfoModel {
  final int internalTotalBytes;
  final int internalAvailableBytes;
  final int internalFreeBytes;
  final List<StorageVolumeModel> externalVolumes;

  const StorageInfoModel({
    required this.internalTotalBytes,
    required this.internalAvailableBytes,
    required this.internalFreeBytes,
    required this.externalVolumes,
  });

  int get internalUsedBytes => internalTotalBytes - internalAvailableBytes;
  double get internalUsedPercentage => internalTotalBytes > 0
      ? (internalUsedBytes / internalTotalBytes) * 100
      : 0.0;

  factory StorageInfoModel.fromMap(Map<dynamic, dynamic> map) {
    final rawVolumes = map['externalVolumes'] as List? ?? [];
    return StorageInfoModel(
      internalTotalBytes: map['internalTotalBytes'] as int? ?? 0,
      internalAvailableBytes: map['internalAvailableBytes'] as int? ?? 0,
      internalFreeBytes: map['internalFreeBytes'] as int? ?? 0,
      externalVolumes: rawVolumes
          .map((e) => StorageVolumeModel.fromMap(e as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'internalTotalBytes': internalTotalBytes,
      'internalAvailableBytes': internalAvailableBytes,
      'internalUsedBytes': internalUsedBytes,
      'internalUsedPercentage': internalUsedPercentage,
      'externalVolumesCount': externalVolumes.length,
    };
  }
}
