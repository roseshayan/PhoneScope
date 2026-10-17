import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cpu_info_model.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/utilities/formatters.dart';
import '../../../core/widgets/metric_card.dart';

class SocDetailScreen extends StatefulWidget {
  const SocDetailScreen({super.key});

  @override
  State<SocDetailScreen> createState() => _SocDetailScreenState();
}

class _SocDetailScreenState extends State<SocDetailScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  CpuInfoModel? _cpu;
  List<Map<String, dynamic>> _liveFreqs = [];
  Timer? _freqTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _freqTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) => _pollFreqs(),
    );
  }

  @override
  void dispose() {
    _freqTimer?.cancel();
    super.dispose();
  }

  void _load() async {
    setState(() => _isLoading = true);
    try {
      final c = await _service.getCpuInfo();
      final f = await _service.getCpuLiveFrequencies();
      if (mounted) {
        setState(() {
          _cpu = c;
          _liveFreqs = f;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _pollFreqs() async {
    try {
      final f = await _service.getCpuLiveFrequencies();
      if (mounted) setState(() => _liveFreqs = f);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_cpu == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('پردازنده و چیپ‌ست')),
        body: Center(
          child: ElevatedButton(
            onPressed: _load,
            child: const Text('تلاش مجدد'),
          ),
        ),
      );
    }

    final cpu = _cpu!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مشخصات پردازنده و هسته‌ها'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MetricCard(
            title: 'تعداد کل هسته‌های پردازنده',
            value: '${cpu.coresCount} هسته فعال',
            subtitle: 'معماری: ${cpu.architecture} (${cpu.abi})',
            icon: Icons.memory,
            iconColor: const Color(0xFF06B6D4),
          ),
          const SizedBox(height: 10),
          if (cpu.hardware != null && cpu.hardware!.isNotEmpty) ...[
            MetricCard(
              title: 'سخت‌افزار / پلتفرم گزارش‌شده',
              value: cpu.hardware!,
              icon: Icons.developer_board,
            ),
            const SizedBox(height: 10),
          ],
          if (cpu.modelName != null && cpu.modelName!.isNotEmpty) ...[
            MetricCard(
              title: 'مدل پردازنده',
              value: cpu.modelName!,
              icon: Icons.speed,
            ),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 10),
          const Text(
            'دسته‌بندی خوشه‌ای هسته‌ها (Clusters)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),

          ...cpu.clusters.map((cluster) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cluster.clusterName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'هسته‌های: ${cluster.cores.join(", ")}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      Formatters.formatFrequencyKHz(cluster.maxFreqKHz),
                      style: const TextStyle(
                        color: Color(0xFF06B6D4),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),
          const Text(
            'فرکانس لحظه‌ای هسته‌ها (پایش زنده)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),

          ...List.generate(cpu.coresCount, (i) {
            final core = cpu.cores.length > i ? cpu.cores[i] : null;
            final live = _liveFreqs.length > i ? _liveFreqs[i] : null;
            final curFreq = live?['curFreqKHz'] as int? ?? core?.curFreqKHz;
            final isRestricted = live?['isRestricted'] as bool? ?? false;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF06B6D4)
                      .withValues(alpha: 0.15),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Color(0xFF06B6D4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  'هسته $i',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  'محدوده: ${Formatters.formatFrequencyKHz(core?.minFreqKHz)} - ${Formatters.formatFrequencyKHz(core?.maxFreqKHz)}',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Text(
                  isRestricted || curFreq == null
                      ? 'محدود شده'
                      : Formatters.formatFrequencyKHz(curFreq),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isRestricted ? Colors.grey : const Color(0xFF10B981),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
