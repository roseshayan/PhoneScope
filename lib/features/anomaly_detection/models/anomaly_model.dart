enum AnomalySeverity { normal, warning, suspicious }

class AnomalyItem {
  final String title;
  final String description;
  final AnomalySeverity severity;
  final String category;

  const AnomalyItem({
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'severity': severity.name,
      'category': category,
    };
  }
}

class AnomalyCheckResult {
  final int totalChecks;
  final int passedChecks;
  final int warningChecks;
  final int suspiciousChecks;
  final List<AnomalyItem> findings;
  final String summaryStatus;

  const AnomalyCheckResult({
    required this.totalChecks,
    required this.passedChecks,
    required this.warningChecks,
    required this.suspiciousChecks,
    required this.findings,
    required this.summaryStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalChecks': totalChecks,
      'passedChecks': passedChecks,
      'warningChecks': warningChecks,
      'suspiciousChecks': suspiciousChecks,
      'summaryStatus': summaryStatus,
      'findings': findings.map((f) => f.toMap()).toList(),
    };
  }
}
