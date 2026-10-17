class BenchmarkResult {
  final String testType; // 'CPU_SINGLE', 'CPU_MULTI', 'STORAGE_IO'
  final DateTime timestamp;
  final int executionTimeMs;
  final int score;
  final Map<String, dynamic> metrics;
  final String deviceModel;

  const BenchmarkResult({
    required this.testType,
    required this.timestamp,
    required this.executionTimeMs,
    required this.score,
    required this.metrics,
    required this.deviceModel,
  });

  Map<String, dynamic> toMap() {
    return {
      'testType': testType,
      'timestamp': timestamp.toIso8601String(),
      'executionTimeMs': executionTimeMs,
      'score': score,
      'metrics': metrics,
      'deviceModel': deviceModel,
    };
  }

  factory BenchmarkResult.fromMap(Map<String, dynamic> map) {
    return BenchmarkResult(
      testType: map['testType'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      executionTimeMs: map['executionTimeMs'] as int,
      score: map['score'] as int,
      metrics: map['metrics'] as Map<String, dynamic>? ?? {},
      deviceModel: map['deviceModel'] as String? ?? 'Device',
    );
  }
}
