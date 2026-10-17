class GpuInfoModel {
  final String renderer;
  final String vendor;
  final String version;
  final int extensionsCount;
  final List<String> extensions;
  final bool hasVulkan;
  final int vulkanVersionCode;
  final bool hasOpenGlEsExtensionPack;

  const GpuInfoModel({
    required this.renderer,
    required this.vendor,
    required this.version,
    required this.extensionsCount,
    required this.extensions,
    required this.hasVulkan,
    required this.vulkanVersionCode,
    required this.hasOpenGlEsExtensionPack,
  });

  factory GpuInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return GpuInfoModel(
      renderer: map['renderer'] as String? ?? 'Unavailable',
      vendor: map['vendor'] as String? ?? 'Unavailable',
      version: map['version'] as String? ?? 'Unavailable',
      extensionsCount: map['extensionsCount'] as int? ?? 0,
      extensions:
          (map['extensions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      hasVulkan: map['hasVulkan'] as bool? ?? false,
      vulkanVersionCode: map['vulkanVersionCode'] as int? ?? 0,
      hasOpenGlEsExtensionPack:
          map['hasOpenGlEsExtensionPack'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'renderer': renderer,
      'vendor': vendor,
      'version': version,
      'extensionsCount': extensionsCount,
      'hasVulkan': hasVulkan,
      'vulkanVersionCode': vulkanVersionCode,
      'hasOpenGlEsExtensionPack': hasOpenGlEsExtensionPack,
    };
  }
}
