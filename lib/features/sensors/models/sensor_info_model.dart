class SensorInfoModel {
  final String name;
  final String vendor;
  final int version;
  final int type;
  final String stringType;
  final double maxRange;
  final double resolution;
  final double powerMa;
  final int minDelayMicros;
  final int maxDelayMicros;
  final bool isWakeUp;
  final String reportingMode;

  const SensorInfoModel({
    required this.name,
    required this.vendor,
    required this.version,
    required this.type,
    required this.stringType,
    required this.maxRange,
    required this.resolution,
    required this.powerMa,
    required this.minDelayMicros,
    required this.maxDelayMicros,
    required this.isWakeUp,
    required this.reportingMode,
  });

  factory SensorInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return SensorInfoModel(
      name: map['name'] as String? ?? 'Sensor',
      vendor: map['vendor'] as String? ?? 'Unknown',
      version: map['version'] as int? ?? 1,
      type: map['type'] as int? ?? 0,
      stringType: map['stringType'] as String? ?? '',
      maxRange: (map['maxRange'] as num?)?.toDouble() ?? 0.0,
      resolution: (map['resolution'] as num?)?.toDouble() ?? 0.0,
      powerMa: (map['powerMa'] as num?)?.toDouble() ?? 0.0,
      minDelayMicros: map['minDelayMicros'] as int? ?? 0,
      maxDelayMicros: map['maxDelayMicros'] as int? ?? 0,
      isWakeUp: map['isWakeUp'] as bool? ?? false,
      reportingMode: map['reportingMode'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'vendor': vendor,
      'type': type,
      'stringType': stringType,
      'maxRange': maxRange,
      'resolution': resolution,
      'powerMa': powerMa,
      'reportingMode': reportingMode,
    };
  }
}

class SensorEventData {
  final int sensorType;
  final int accuracy;
  final int timestamp;
  final List<double> values;

  const SensorEventData({
    required this.sensorType,
    required this.accuracy,
    required this.timestamp,
    required this.values,
  });

  factory SensorEventData.fromMap(Map<dynamic, dynamic> map) {
    return SensorEventData(
      sensorType: map['sensorType'] as int? ?? 0,
      accuracy: map['accuracy'] as int? ?? 0,
      timestamp: map['timestamp'] as int? ?? 0,
      values:
          (map['values'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }
}
