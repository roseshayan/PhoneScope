import 'package:flutter/material.dart';

import '../models/memory_storage_model.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/utilities/formatters.dart';
import '../../../core/widgets/metric_card.dart';

class MemoryDetailScreen extends StatefulWidget {
  const MemoryDetailScreen({super.key});

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  MemoryInfoModel? _memory;
  StorageInfoModel? _storage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() => _isLoading = true);
    try {
      final m = await _service.getMemoryInfo();
      final s = await _service.getStorageInfo();
      if (mounted) {
        setState(() {
          _memory = m;
          _storage = s;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final m = _memory;
    final s = _storage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حافظه رم و ذخیره‌سازی'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (m != null) ...[
            const Text(
              'وضعیت حافظه موقت (RAM)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // RAM Progress Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${m.usedPercentage.toStringAsFixed(1)}% اشغال شده',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${Formatters.formatBytes(m.usedMemBytes)} از ${Formatters.formatBytes(m.totalMemBytes)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (m.usedPercentage / 100.0).clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF06B6D4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            MetricCard(
              title: 'رم در دسترس سیستم',
              value: Formatters.formatBytes(m.availMemBytes),
              subtitle:
                  'آستانه هشدار کمبود حافظه: ${Formatters.formatBytes(m.thresholdBytes)}',
              icon: Icons.memory,
            ),
            const SizedBox(height: 10),

            MetricCard(
              title: 'حافظه پردازه PhoneScope',
              value: Formatters.formatBytes(m.appUsedBytes),
              subtitle:
                  'سقف مجاز حافظه هیپ اپلیکیشن: ${Formatters.formatBytes(m.appHeapMaxBytes)}',
              icon: Icons.bubble_chart,
            ),
          ],

          const SizedBox(height: 24),
          if (s != null) ...[
            const Text(
              'فضای ذخیره‌سازی داخلی (Internal Storage)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${s.internalUsedPercentage.toStringAsFixed(1)}% مصرف شده',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${Formatters.formatBytes(s.internalUsedBytes)} از ${Formatters.formatBytes(s.internalTotalBytes)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (s.internalUsedPercentage / 100.0).clamp(
                          0.0,
                          1.0,
                        ),
                        minHeight: 10,
                        backgroundColor: const Color(0xFF334155),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'فضای آزاد باقی‌مانده: ${Formatters.formatBytes(s.internalAvailableBytes)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            if (s.externalVolumes.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'پارتیشن‌ها و حافظه‌های خارجی (SD Cards)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...s.externalVolumes.map((vol) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      vol.isRemovable ? Icons.sd_card : Icons.storage,
                      color: const Color(0xFF06B6D4),
                    ),
                    title: Text(
                      vol.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      'کل: ${Formatters.formatBytes(vol.totalBytes)} | در دسترس: ${Formatters.formatBytes(vol.availableBytes)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }
}
