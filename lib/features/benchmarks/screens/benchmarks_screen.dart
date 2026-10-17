import 'package:flutter/material.dart';

import '../models/benchmark_model.dart';
import '../services/benchmark_service.dart';
import '../../../core/platform/device_info_service.dart';

class BenchmarksScreen extends StatefulWidget {
  const BenchmarksScreen({super.key});

  @override
  State<BenchmarksScreen> createState() => _BenchmarksScreenState();
}

class _BenchmarksScreenState extends State<BenchmarksScreen> {
  final DeviceInfoService _deviceService = DeviceInfoService();
  bool _isRunning = false;
  String _currentRunningLabel = '';
  final List<BenchmarkResult> _history = [];
  String _deviceModel = 'Android Device';
  int _coresCount = 8;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  void _loadDeviceInfo() async {
    try {
      final sys = await _deviceService.getSystemInfo();
      final cpu = await _deviceService.getCpuInfo();
      if (mounted) {
        setState(() {
          _deviceModel = '${sys.manufacturer} ${sys.model}';
          _coresCount = cpu.coresCount;
        });
      }
    } catch (_) {}
  }

  void _runSingleCore() async {
    setState(() {
      _isRunning = true;
      _currentRunningLabel = 'در حال اجرای بنچمارک تک‌هسته‌ای...';
    });
    try {
      final res = await BenchmarkService.runSingleCoreCpu(
        deviceModel: _deviceModel,
      );
      if (mounted) {
        setState(() {
          _history.insert(0, res);
          _isRunning = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  void _runMultiCore() async {
    setState(() {
      _isRunning = true;
      _currentRunningLabel =
          'در حال اجرای بنچمارک چندهسته‌ای روی $_coresCount هسته...';
    });
    try {
      final res = await BenchmarkService.runMultiCoreCpu(
        coresCount: _coresCount,
        deviceModel: _deviceModel,
      );
      if (mounted) {
        setState(() {
          _history.insert(0, res);
          _isRunning = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  void _runStorage() async {
    setState(() {
      _isRunning = true;
      _currentRunningLabel = 'در حال تست سرعت خواندن و نوشتن دیسک...';
    });
    try {
      final res = await BenchmarkService.runStorageIo(
        deviceModel: _deviceModel,
      );
      if (mounted) {
        setState(() {
          _history.insert(0, res);
          _isRunning = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('بنچمارک و سنجش کارایی')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF06B6D4), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'بنچمارک‌های PhoneScope از عملیات ریاضی واقعی، محاسبات ماتریسی، هشینگ SHA-256 و I/O متوالی استفاده می‌کنند.',
                    style: TextStyle(fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_isRunning)
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF06B6D4)),
              ),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _currentRunningLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Test Cards
          _buildBenchmarkActionCard(
            title: 'بنچمارک تک‌هسته‌ای پردازنده (Single-Core)',
            subtitle: 'سنجش عملکرد خام یک هسته با الگوریتم غربال اراتستن و ضرب ماتریس‌های ممیز شناور',
            icon: Icons.memory,
            onRun: _isRunning ? null : _runSingleCore,
          ),
          const SizedBox(height: 12),
          _buildBenchmarkActionCard(
            title: 'بنچمارک چندهسته‌ای پردازنده (Multi-Core)',
            subtitle:
                'توزیع پردازش موازی روی تمام $_coresCount هسته با ترکیب محاسبات و هشینگ داده',
            icon: Icons.developer_board,
            onRun: _isRunning ? null : _runMultiCore,
          ),
          const SizedBox(height: 12),
          _buildBenchmarkActionCard(
            title: 'بنچمارک سرعت حافظه داخلی (Storage I/O)',
            subtitle: 'اندازه‌گیری سرعت خواندن و نوشتن بلوک‌های متوالی فایل موقت ۱۶ مگابایتی',
            icon: Icons.storage,
            onRun: _isRunning ? null : _runStorage,
          ),
          const SizedBox(height: 24),

          // History Section
          const Text(
            'تاریخچه نتایج بنچمارک',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          if (_history.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                'هنوز تستی در این نشست اجرا نشده است.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else
            ..._history.map((item) => _buildResultCard(item)),
        ],
      ),
    );
  }

  Widget _buildBenchmarkActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onRun,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF06B6D4), size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06B6D4),
                  foregroundColor: const Color(0xFF0B1120),
                ),
                onPressed: onRun,
                icon: const Icon(Icons.speed, size: 18),
                label: const Text('اجرای آزمون'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BenchmarkResult item) {
    final typeName = item.testType == 'CPU_SINGLE'
        ? 'تک‌هسته‌ای CPU'
        : (item.testType == 'CPU_MULTI' ? 'چندهسته‌ای CPU' : 'سرعت حافظه دیسک');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Color(0xFF10B981),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'زمان اجرا: ${item.executionTimeMs} میلی‌ثانیه',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.score}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF06B6D4),
                  ),
                ),
                const Text(
                  'امتیاز',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
