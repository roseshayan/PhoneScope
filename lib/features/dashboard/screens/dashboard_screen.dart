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
import '../../../core/ads/widgets/adivery_native_card.dart';

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
      // اجرای همزمان و موازی کوئری‌های نیتیو جهت افزایش چشم‌گیر سرعت بارگذاری در تمام گوشی‌ها
      final results = await Future.wait([
        _service.getSystemInfo().catchError((_) => SystemInfoModel.fromMap({})),
        _service.getCpuInfo().catchError((_) => CpuInfoModel.fromMap({})),
        _service.getMemoryInfo().catchError((_) => MemoryInfoModel.fromMap({})),
        _service.getStorageInfo().catchError((_) => StorageInfoModel.fromMap({})),
        _service.getBatteryInfo().catchError((_) => BatteryInfoModel.fromMap({})),
        _service.getThermalInfo().catchError((_) => ThermalInfoModel.fromMap({})),
        _service.getNetworkInfo().catchError((_) => NetworkInfoModel.fromMap({})),
      ]);

      if (mounted) {
        setState(() {
          _system = results[0] as SystemInfoModel;
          _cpu = results[1] as CpuInfoModel;
          _memory = results[2] as MemoryInfoModel;
          _storage = results[3] as StorageInfoModel;
          _battery = results[4] as BatteryInfoModel;
          _thermal = results[5] as ThermalInfoModel;
          _network = results[6] as NetworkInfoModel;
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
        title: const Text('مرکز کنترل و مشخصات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'تازه‌سازی اطلاعات',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadDashboardData(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Top Hero Device Card
            if (s != null)
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    color: Color(0xFF06B6D4),
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF06B6D4,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.phone_android,
                                  color: Color(0xFF06B6D4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.deviceDisplayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    s.manufacturer.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF06B6D4),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          StatusBadge(
                            label: s.isRootedHeuristic
                                ? 'روت شده (ناامن)'
                                : 'امن و اصلی',
                            type: s.isRootedHeuristic
                                ? BadgeType.error
                                : BadgeType.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailChip('اندروید', s.androidVersion),
                          _buildDetailChip('سطح API', s.apiLevel.toString()),
                          _buildDetailChip(
                            'معماری',
                            s.is64Bit ? '64-Bit' : '32-Bit',
                          ),
                          _buildDetailChip(
                            'وصله امنیتی',
                            s.securityPatch.split('-').take(2).join('-'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Quick Access Actions
            Row(
              children: [
                _buildQuickAction(
                  title: 'تست‌ها',
                  icon: Icons.fact_check,
                  color: const Color(0xFF06B6D4),
                  onTap: () => widget.onNavigateTab(3),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  title: 'سخت‌افزار',
                  icon: Icons.devices_other,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => widget.onNavigateTab(1),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  title: 'پایش حرارتی',
                  icon: Icons.thermostat,
                  color: const Color(0xFFF59E0B),
                  onTap: () => widget.onNavigateTab(2),
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  title: 'ابزارها',
                  icon: Icons.construction,
                  color: const Color(0xFF10B981),
                  onTap: () => widget.onNavigateTab(4),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // RAM Usage Card
            if (m != null)
              _buildProgressCard(
                title: 'حافظه رم (RAM)',
                valueStr: '${m.usedPercentage.toStringAsFixed(1)}% مصرف',
                progress: (m.usedPercentage / 100.0).clamp(0.0, 1.0),
                detailStr:
                    '${Formatters.formatBytes(m.usedMemBytes, useBinary: true)} پر از ${Formatters.formatBytes(m.totalMemBytes, useBinary: true)} (${Formatters.formatBytes(m.availMemBytes, useBinary: true)} آزاد)',
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
            const SizedBox(height: 12),

            // Native Ad Card
            const AdiveryNativeCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
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
