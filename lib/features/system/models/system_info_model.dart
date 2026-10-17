class SystemInfoModel {
  final String manufacturer;
  final String brand;
  final String model;
  final String device;
  final String product;
  final String board;
  final String hardware;
  final String androidVersion;
  final int apiLevel;
  final String securityPatch;
  final String buildId;
  final String fingerprint;
  final String bootloader;
  final List<String> supportedAbis;
  final List<String> supported32BitAbis;
  final List<String> supported64BitAbis;
  final bool is64Bit;
  final String kernelVersion;
  final String socModel;
  final String socManufacturer;
  final String buildType;
  final String? buildTags;
  final int uptimeMillis;
  final bool isRootedHeuristic;
  final List<String> rootCheckDetails;

  const SystemInfoModel({
    required this.manufacturer,
    required this.brand,
    required this.model,
    required this.device,
    required this.product,
    required this.board,
    required this.hardware,
    required this.androidVersion,
    required this.apiLevel,
    required this.securityPatch,
    required this.buildId,
    required this.fingerprint,
    required this.bootloader,
    required this.supportedAbis,
    required this.supported32BitAbis,
    required this.supported64BitAbis,
    required this.is64Bit,
    required this.kernelVersion,
    required this.socModel,
    required this.socManufacturer,
    required this.buildType,
    this.buildTags,
    required this.uptimeMillis,
    required this.isRootedHeuristic,
    required this.rootCheckDetails,
  });

  factory SystemInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return SystemInfoModel(
      manufacturer: map['manufacturer'] as String? ?? 'Unknown',
      brand: map['brand'] as String? ?? 'Unknown',
      model: map['model'] as String? ?? 'Unknown',
      device: map['device'] as String? ?? 'Unknown',
      product: map['product'] as String? ?? 'Unknown',
      board: map['board'] as String? ?? 'Unknown',
      hardware: map['hardware'] as String? ?? 'Unknown',
      androidVersion: map['androidVersion'] as String? ?? 'Unknown',
      apiLevel: map['apiLevel'] as int? ?? 0,
      securityPatch: map['securityPatch'] as String? ?? 'Unavailable',
      buildId: map['buildId'] as String? ?? 'Unknown',
      fingerprint: map['fingerprint'] as String? ?? 'Unknown',
      bootloader: map['bootloader'] as String? ?? 'Unknown',
      supportedAbis:
          (map['supportedAbis'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      supported32BitAbis:
          (map['supported32BitAbis'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      supported64BitAbis:
          (map['supported64BitAbis'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      is64Bit: map['is64Bit'] as bool? ?? false,
      kernelVersion: map['kernelVersion'] as String? ?? 'Unknown',
      socModel: map['socModel'] as String? ?? 'Unavailable',
      socManufacturer: map['socManufacturer'] as String? ?? 'Unavailable',
      buildType: map['buildType'] as String? ?? 'Unknown',
      buildTags: map['buildTags'] as String?,
      uptimeMillis: map['uptimeMillis'] as int? ?? 0,
      isRootedHeuristic: map['isRootedHeuristic'] as bool? ?? false,
      rootCheckDetails:
          (map['rootCheckDetails'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'manufacturer': manufacturer,
      'brand': brand,
      'model': model,
      'device': device,
      'product': product,
      'board': board,
      'hardware': hardware,
      'androidVersion': androidVersion,
      'apiLevel': apiLevel,
      'securityPatch': securityPatch,
      'buildId': buildId,
      'fingerprint': fingerprint,
      'bootloader': bootloader,
      'supportedAbis': supportedAbis,
      'is64Bit': is64Bit,
      'kernelVersion': kernelVersion,
      'socModel': socModel,
      'socManufacturer': socManufacturer,
      'uptimeMillis': uptimeMillis,
      'isRootedHeuristic': isRootedHeuristic,
      'rootCheckDetails': rootCheckDetails,
    };
  }
}
