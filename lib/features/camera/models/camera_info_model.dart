class CameraDetailModel {
  final String id;
  final String facing;
  final String hardwareLevel;
  final double megapixels;
  final int sensorWidth;
  final int sensorHeight;
  final String physicalSensorSize;
  final List<double> focalLengths;
  final List<double> apertures;
  final int isoMin;
  final int isoMax;
  final bool hasFlash;
  final bool hasOis;
  final bool supportsRaw;
  final int resolutionsCount;
  final List<String> supportedResolutions;

  const CameraDetailModel({
    required this.id,
    required this.facing,
    required this.hardwareLevel,
    required this.megapixels,
    required this.sensorWidth,
    required this.sensorHeight,
    required this.physicalSensorSize,
    required this.focalLengths,
    required this.apertures,
    required this.isoMin,
    required this.isoMax,
    required this.hasFlash,
    required this.hasOis,
    required this.supportsRaw,
    required this.resolutionsCount,
    required this.supportedResolutions,
  });

  factory CameraDetailModel.fromMap(Map<dynamic, dynamic> map) {
    return CameraDetailModel(
      id: map['id'] as String? ?? '0',
      facing: map['facing'] as String? ?? 'Unknown',
      hardwareLevel: map['hardwareLevel'] as String? ?? 'Unknown',
      megapixels: (map['megapixels'] as num?)?.toDouble() ?? 0.0,
      sensorWidth: map['sensorWidth'] as int? ?? 0,
      sensorHeight: map['sensorHeight'] as int? ?? 0,
      physicalSensorSize: map['physicalSensorSize'] as String? ?? 'Unavailable',
      focalLengths:
          (map['focalLengths'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      apertures:
          (map['apertures'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      isoMin: map['isoMin'] as int? ?? 0,
      isoMax: map['isoMax'] as int? ?? 0,
      hasFlash: map['hasFlash'] as bool? ?? false,
      hasOis: map['hasOis'] as bool? ?? false,
      supportsRaw: map['supportsRaw'] as bool? ?? false,
      resolutionsCount: map['resolutionsCount'] as int? ?? 0,
      supportedResolutions:
          (map['supportedResolutions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facing': facing,
      'hardwareLevel': hardwareLevel,
      'megapixels': megapixels,
      'sensorWidth': sensorWidth,
      'sensorHeight': sensorHeight,
      'physicalSensorSize': physicalSensorSize,
      'focalLengths': focalLengths,
      'apertures': apertures,
      'isoRange': '$isoMin - $isoMax',
      'hasFlash': hasFlash,
      'hasOis': hasOis,
      'supportsRaw': supportsRaw,
      'supportedResolutions': supportedResolutions,
    };
  }
}

class CameraInfoModel {
  final int camerasCount;
  final List<CameraDetailModel> cameras;

  const CameraInfoModel({required this.camerasCount, required this.cameras});

  factory CameraInfoModel.fromMap(Map<dynamic, dynamic> map) {
    final rawCameras = map['cameras'] as List? ?? [];
    return CameraInfoModel(
      camerasCount: map['camerasCount'] as int? ?? 0,
      cameras: rawCameras
          .map((e) => CameraDetailModel.fromMap(e as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'camerasCount': camerasCount,
      'cameras': cameras.map((c) => c.toMap()).toList(),
    };
  }
}
