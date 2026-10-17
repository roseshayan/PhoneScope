import 'package:flutter/material.dart';

import '../models/anomaly_model.dart';
import '../services/anomaly_service.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/widgets/status_badge.dart';

class AnomalyDetectionScreen extends StatefulWidget {
  const AnomalyDetectionScreen({super.key});

  @override
  State<AnomalyDetectionScreen> createState() => _AnomalyDetectionScreenState();
}

class _AnomalyDetectionScreenState extends State<AnomalyDetectionScreen> {
  final DeviceInfoService _deviceService = DeviceInfoService();
  bool _isLoading = true;
  AnomalyCheckResult? _result;

  @override
  void initState() {
    super.initState();
    _runCheck();
  }

  void _runCheck() async {
    setState(() => _isLoading = true);
    try {
      final system = await _deviceService.getSystemInfo();
      final cpu = await _deviceService.getCpuInfo();
      final display = await _deviceService.getDisplayInfo();

      final res = AnomalyService.performCrossCheck(
        system: system,
        cpu: cpu,
        display: display,
      );

      if (mounted) {
        setState(() {
          _result = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بررسی اصالت و ناهماهنگی سخت‌افزار')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_result == null
                ? const Center(child: Text('خطا در تحلیل اطلاعات دستگاه'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Summary Card
                      _buildSummaryCard(_result!),
                      const SizedBox(height: 16),

                      const Text(
                        'یافته‌ها و تطبیق‌های متقابل',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ..._result!.findings.map(
                        (finding) => _buildFindingCard(finding),
                      ),
                      const SizedBox(height: 16),

                      // Technical Caveat Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ملاحظات فنی و امنیتی:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'این تحلیل صرفاً بر اساس مقایسه اکتشافی (Heuristic) مشخصات اعلام‌شده توسط سیستمعامل و تطبیق معماری ABI با هسته‌ها صورت می‌پذیرد. در گوشی‌های بسیار تغییریافته یا روت‌شده ممکن است شناسه‌ها شبیه‌سازی شوند؛ بنابراین خروجی فوق به منزله تضمین مطلق اصالت آزمایشگاهی دستگاه تلقی نمی‌شود.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.5,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
    );
  }

  Widget _buildSummaryCard(AnomalyCheckResult res) {
    final isGood = res.suspiciousChecks == 0 && res.warningChecks == 0;
    final color = isGood
        ? const Color(0xFF10B981)
        : (res.suspiciousChecks > 0
              ? const Color(0xFFF43F5E)
              : const Color(0xFFF59E0B));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isGood
                ? Icons.verified
                : (res.suspiciousChecks > 0
                      ? Icons.gpp_bad
                      : Icons.warning_amber),
            color: color,
            size: 44,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  res.summaryStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${res.passedChecks} تست سالم | ${res.warningChecks} هشدار | ${res.suspiciousChecks} مورد مشکوک',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindingCard(AnomalyItem item) {
    BadgeType badgeType = BadgeType.success;
    String badgeText = 'تایید';

    if (item.severity == AnomalySeverity.warning) {
      badgeType = BadgeType.warning;
      badgeText = 'هشدار';
    } else if (item.severity == AnomalySeverity.suspicious) {
      badgeType = BadgeType.error;
      badgeText = 'مشکوک';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                StatusBadge(label: badgeText, type: badgeType),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
