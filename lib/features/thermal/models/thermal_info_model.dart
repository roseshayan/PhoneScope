class ThermalInfoModel {
  final String thermalStatus;
  final int thermalStatusCode;
  final double? thermalHeadroom;
  final double? batteryTemperatureCelsius;
  final bool isThermalApiSupported;
  final String socTemperatureNote;

  const ThermalInfoModel({
    required this.thermalStatus,
    required this.thermalStatusCode,
    this.thermalHeadroom,
    this.batteryTemperatureCelsius,
    required this.isThermalApiSupported,
    required this.socTemperatureNote,
  });

  factory ThermalInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return ThermalInfoModel(
      thermalStatus: map['thermalStatus'] as String? ?? 'Normal',
      thermalStatusCode: map['thermalStatusCode'] as int? ?? 0,
      thermalHeadroom: (map['thermalHeadroom'] as num?)?.toDouble(),
      batteryTemperatureCelsius: (map['batteryTemperatureCelsius'] as num?)
          ?.toDouble(),
      isThermalApiSupported: map['isThermalApiSupported'] as bool? ?? false,
      socTemperatureNote: map['socTemperatureNote'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'thermalStatus': thermalStatus,
      'thermalStatusCode': thermalStatusCode,
      'thermalHeadroom': thermalHeadroom,
      'batteryTemperatureCelsius': batteryTemperatureCelsius,
      'isThermalApiSupported': isThermalApiSupported,
      'socTemperatureNote': socTemperatureNote,
    };
  }
}
