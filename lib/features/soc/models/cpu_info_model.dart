class CpuCoreModel {
  final int coreIndex;
  final int? minFreqKHz;
  final int? maxFreqKHz;
  final int? curFreqKHz;
  final String governor;

  const CpuCoreModel({
    required this.coreIndex,
    this.minFreqKHz,
    this.maxFreqKHz,
    this.curFreqKHz,
    required this.governor,
  });

  factory CpuCoreModel.fromMap(Map<dynamic, dynamic> map) {
    return CpuCoreModel(
      coreIndex: map['coreIndex'] as int? ?? 0,
      minFreqKHz: map['minFreqKHz'] as int?,
      maxFreqKHz: map['maxFreqKHz'] as int?,
      curFreqKHz: map['curFreqKHz'] as int?,
      governor: map['governor'] as String? ?? 'Unavailable',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coreIndex': coreIndex,
      'minFreqKHz': minFreqKHz,
      'maxFreqKHz': maxFreqKHz,
      'curFreqKHz': curFreqKHz,
      'governor': governor,
    };
  }
}

class CpuClusterModel {
  final String clusterName;
  final int maxFreqKHz;
  final List<int> cores;

  const CpuClusterModel({
    required this.clusterName,
    required this.maxFreqKHz,
    required this.cores,
  });

  factory CpuClusterModel.fromMap(Map<dynamic, dynamic> map) {
    return CpuClusterModel(
      clusterName: map['clusterName'] as String? ?? 'Cluster',
      maxFreqKHz: map['maxFreqKHz'] as int? ?? 0,
      cores: (map['cores'] as List?)?.map((e) => e as int).toList() ?? [],
    );
  }
}

class CpuInfoModel {
  final int coresCount;
  final String architecture;
  final String abi;
  final List<CpuCoreModel> cores;
  final List<CpuClusterModel> clusters;
  final String? hardware;
  final String? features;
  final String? modelName;
  final bool procCpuInfoAccessible;

  const CpuInfoModel({
    required this.coresCount,
    required this.architecture,
    required this.abi,
    required this.cores,
    required this.clusters,
    this.hardware,
    this.features,
    this.modelName,
    required this.procCpuInfoAccessible,
  });

  factory CpuInfoModel.fromMap(Map<dynamic, dynamic> map) {
    final rawCores = map['cores'] as List? ?? [];
    final rawClusters = map['clusters'] as List? ?? [];

    return CpuInfoModel(
      coresCount: map['coresCount'] as int? ?? 0,
      architecture: map['architecture'] as String? ?? 'Unknown',
      abi: map['abi'] as String? ?? 'Unknown',
      cores: rawCores.map((e) => CpuCoreModel.fromMap(e as Map)).toList(),
      clusters: rawClusters
          .map((e) => CpuClusterModel.fromMap(e as Map))
          .toList(),
      hardware: map['hardware'] as String?,
      features: map['features'] as String?,
      modelName: map['modelName'] as String?,
      procCpuInfoAccessible: map['procCpuInfoAccessible'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coresCount': coresCount,
      'architecture': architecture,
      'abi': abi,
      'hardware': hardware,
      'features': features,
      'modelName': modelName,
      'cores': cores.map((c) => c.toMap()).toList(),
    };
  }
}
