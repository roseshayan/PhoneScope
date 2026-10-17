import 'package:flutter/material.dart';

import '../../system/models/system_info_model.dart';
import '../../soc/models/cpu_info_model.dart';
import '../../memory/models/memory_storage_model.dart';
import '../../battery/models/battery_info_model.dart';
import '../../thermal/models/thermal_info_model.dart';
import '../../network/models/network_info_model.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/utilities/formatters.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/status_badge.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  bool _isLoading = true;

  SystemInfoModel? _system;
  CpuInfoModel? _cpu;
  MemoryInfoModel? _memory;
  StorageInfoModel? _storage;
  BatteryInfoModel? _battery;
  ThermalInfoModel? _thermal;
  NetworkInfoModel? _network;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final s = await _service.getSystemInfo();
      final c = await _service.getCpuInfo();
      final m = await _service.getMemoryInfo();
      final st = await _service.getStorageInfo();
      final b = await _service.getBatteryInfo();
      final t = await _service.getThermalInfo();
      final n = await _service.getNetworkInfo();

      if (mounted) {
        setState(() {
          _system = s;
          _cpu = c;
          _memory = m;
          _storage = st;
          _battery = b;
          _thermal = t;
          _network = n;
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

    final s = _system;
    final c = _cpu;
    final m = _memory;
    final st = _storage;
    final b = _battery;
    final t = _thermal;
    final n = _network;

    return Scaffold(
      appBar: AppBar(
        title: const Text('فون‌اسکوپ • PhoneScope'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadDashboardData(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Hero Device Header Card
            if (s != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.brand.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF06B6D4),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 12,
                          ),
                        ),
                        StatusBadge(
                          label: 'Android ${s.androidVersion}',
                          type: BadgeType.success,
                          icon: Icons.android,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${s.manufacturer} ${s.model}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مدل فنی: ${s.device} • ساخت: ${s.board}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Quick Hardware Action Grid
            Row(
              children: [
                _buildQuickAction(
                  title: 'تست سخت‌افزار',
                  icon: Icons.fact_check,
                  color: const Color(0xFF06B6D4),
                  onTap: () => widget.onNavigateTab(3), // Tests tab
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  title: 'بنچمارک‌ها',
                  icon: Icons.speed,
                  color: const Color(0xFF10B981),
                  onTap: () => widget.onNavigateTab(4), // Tools tab
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  title: 'پایش زنده',
                  icon: Icons.monitor_heart,
                  color: const Color(0xFFF59E0B),
                  onTap: () => widget.onNavigateTab(2), // Monitor tab
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'وضعیت لحظه‌ای منابع سیستم',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            // RAM Usage Card
            if (m != null)
              _buildProgressCard(
                title: 'حافظه موقت (RAM)',
                valueStr: '${m.usedPercentage.toStringAsFixed(1)}% اشغال',
                progress: (m.usedPercentage / 100.0).clamp(0.0, 1.0),
                detailStr:
                    '${Formatters.formatBytes(m.usedMemBytes)} مصرف شده از ${Formatters.formatBytes(m.totalMemBytes)}',
                color: const Color(0xFF06B6D4),
                icon: Icons.memory,
              ),
            const SizedBox(height: 10),

            // Storage Usage Card
            if (st != null)
              _buildProgressCard(
                title: 'فضای ذخیره‌سازی داخلی',
                valueStr:
                    '${st.internalUsedPercentage.toStringAsFixed(1)}% مصرف',
                progress: (st.internalUsedPercentage / 100.0).clamp(0.0, 1.0),
                detailStr:
                    '${Formatters.formatBytes(st.internalUsedBytes)} پر از ${Formatters.formatBytes(st.internalTotalBytes)} (${Formatters.formatBytes(st.internalAvailableBytes)} آزاد)',
                color: const Color(0xFF10B981),
                icon: Icons.storage,
              ),
            const SizedBox(height: 10),

            // Battery & Thermal Cards in Row
            if (b != null && t != null)
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'سطح شارژ باتری',
                      value: '${b.level.toStringAsFixed(0)}%',
                      subtitle: b.status,
                      icon: b.isCharging
                          ? Icons.battery_charging_full
                          : Icons.battery_std,
                      iconColor: b.isCharging
                          ? const Color(0xFF10B981)
                          : const Color(0xFF06B6D4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricCard(
                      title: 'دمای باتری',
                      value: Formatters.formatTemperature(b.temperatureCelsius),
                      subtitle: t.thermalStatus,
                      icon: Icons.thermostat,
                      iconColor: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),

            // CPU & Network in Row
            if (c != null && n != null)
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'پردازنده',
                      value: '${c.coresCount} هسته',
                      subtitle: c.abi,
                      icon: Icons.developer_board,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricCard(
                      title: 'شبکه جاری',
                      value: n.networkType,
                      subtitle: n.isWifi
                          ? n.wifiSsid
                          : (n.isConnected ? "متصل" : "قطع"),
                      icon: n.isWifi ? Icons.wifi : Icons.signal_cellular_alt,
                      iconColor: n.isConnected
                          ? const Color(0xFF10B981)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required String valueStr,
    required double progress,
    required String detailStr,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  valueStr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFF334155),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detailStr,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
