class DisplayInfoModel {
  final int physicalWidthPixels;
  final int physicalHeightPixels;
  final int logicalWidthDp;
  final int logicalHeightDp;
  final double density;
  final int densityDpi;
  final double xdpi;
  final double ydpi;
  final double diagonalInches;
  final double currentRefreshRate;
  final List<double> supportedRefreshRates;
  final bool isHdrSupported;
  final List<String> hdrTypes;
  final bool isWideColorGamut;
  final String orientation;

  const DisplayInfoModel({
    required this.physicalWidthPixels,
    required this.physicalHeightPixels,
    required this.logicalWidthDp,
    required this.logicalHeightDp,
    required this.density,
    required this.densityDpi,
    required this.xdpi,
    required this.ydpi,
    required this.diagonalInches,
    required this.currentRefreshRate,
    required this.supportedRefreshRates,
    required this.isHdrSupported,
    required this.hdrTypes,
    required this.isWideColorGamut,
    required this.orientation,
  });

  factory DisplayInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return DisplayInfoModel(
      physicalWidthPixels: map['physicalWidthPixels'] as int? ?? 0,
      physicalHeightPixels: map['physicalHeightPixels'] as int? ?? 0,
      logicalWidthDp: map['logicalWidthDp'] as int? ?? 0,
      logicalHeightDp: map['logicalHeightDp'] as int? ?? 0,
      density: (map['density'] as num?)?.toDouble() ?? 1.0,
      densityDpi: map['densityDpi'] as int? ?? 160,
      xdpi: (map['xdpi'] as num?)?.toDouble() ?? 160.0,
      ydpi: (map['ydpi'] as num?)?.toDouble() ?? 160.0,
      diagonalInches: (map['diagonalInches'] as num?)?.toDouble() ?? 0.0,
      currentRefreshRate:
          (map['currentRefreshRate'] as num?)?.toDouble() ?? 60.0,
      supportedRefreshRates:
          (map['supportedRefreshRates'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      isHdrSupported: map['isHdrSupported'] as bool? ?? false,
      hdrTypes:
          (map['hdrTypes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isWideColorGamut: map['isWideColorGamut'] as bool? ?? false,
      orientation: map['orientation'] as String? ?? 'Portrait',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'physicalWidthPixels': physicalWidthPixels,
      'physicalHeightPixels': physicalHeightPixels,
      'logicalWidthDp': logicalWidthDp,
      'logicalHeightDp': logicalHeightDp,
      'density': density,
      'densityDpi': densityDpi,
      'diagonalInches': diagonalInches,
      'currentRefreshRate': currentRefreshRate,
      'supportedRefreshRates': supportedRefreshRates,
      'isHdrSupported': isHdrSupported,
      'hdrTypes': hdrTypes,
      'isWideColorGamut': isWideColorGamut,
      'orientation': orientation,
    };
  }
}
