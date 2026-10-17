class BatteryInfoModel {
  final double level;
  final int voltageMv;
  final double? temperatureCelsius;
  final String status;
  final bool isCharging;
  final String plugged;
  final String health;
  final String technology;
  final int currentNowMicroAmps;
  final int currentAverageMicroAmps;
  final int chargeCounterMicroAmpHours;
  final int capacity;

  const BatteryInfoModel({
    required this.level,
    required this.voltageMv,
    this.temperatureCelsius,
    required this.status,
    required this.isCharging,
    required this.plugged,
    required this.health,
    required this.technology,
    required this.currentNowMicroAmps,
    required this.currentAverageMicroAmps,
    required this.chargeCounterMicroAmpHours,
    required this.capacity,
  });

  factory BatteryInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return BatteryInfoModel(
      level: (map['level'] as num?)?.toDouble() ?? 0.0,
      voltageMv: map['voltageMv'] as int? ?? 0,
      temperatureCelsius: (map['temperatureCelsius'] as num?)?.toDouble(),
      status: map['status'] as String? ?? 'Unknown',
      isCharging: map['isCharging'] as bool? ?? false,
      plugged: map['plugged'] as String? ?? 'Unplugged',
      health: map['health'] as String? ?? 'Unknown',
      technology: map['technology'] as String? ?? 'Unknown',
      currentNowMicroAmps: map['currentNowMicroAmps'] as int? ?? 0,
      currentAverageMicroAmps: map['currentAverageMicroAmps'] as int? ?? 0,
      chargeCounterMicroAmpHours:
          map['chargeCounterMicroAmpHours'] as int? ?? 0,
      capacity: map['capacity'] as int? ?? -1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'voltageMv': voltageMv,
      'temperatureCelsius': temperatureCelsius,
      'status': status,
      'isCharging': isCharging,
      'plugged': plugged,
      'health': health,
      'technology': technology,
      'currentNowMicroAmps': currentNowMicroAmps,
      'capacity': capacity,
    };
  }
}
