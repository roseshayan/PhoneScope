import 'package:flutter/material.dart';

import '../models/network_info_model.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/widgets/metric_card.dart';

class NetworkDetailScreen extends StatefulWidget {
  const NetworkDetailScreen({super.key});

  @override
  State<NetworkDetailScreen> createState() => _NetworkDetailScreenState();
}

class _NetworkDetailScreenState extends State<NetworkDetailScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  NetworkInfoModel? _network;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() => _isLoading = true);
    try {
      final n = await _service.getNetworkInfo();
      if (mounted)
        setState(() {
          _network = n;
          _isLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final n = _network;
    if (n == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('شبکه و ارتباطات')),
        body: Center(
          child: ElevatedButton(
            onPressed: _load,
            child: const Text('تلاش مجدد'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('وضعیت شبکه و اتصال اینترنت'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MetricCard(
            title: 'وضعیت اتصال اینترنت',
            value: n.isConnected
                ? 'متصل به شبکه (${n.networkType})'
                : 'اینترنت متصل نیست',
            subtitle: 'نوع رابط: ${n.networkType}',
            icon: n.isConnected ? Icons.wifi : Icons.wifi_off,
            iconColor: n.isConnected
                ? const Color(0xFF10B981)
                : const Color(0xFFF43F5E),
          ),
          const SizedBox(height: 10),

          if (n.isWifi) ...[
            MetricCard(
              title: 'نام شبکه وای‌فای (SSID)',
              value: n.wifiSsid,
              subtitle: 'مک آدرس اکسس‌پوینت (BSSID): ${n.wifiBssid}',
              icon: Icons.router,
              iconColor: const Color(0xFF06B6D4),
            ),
            const SizedBox(height: 10),

            MetricCard(
              title: 'سرعت پیوند وای‌فای (Link Speed)',
              value: n.linkSpeedMbps > 0
                  ? '${n.linkSpeedMbps} Mbps'
                  : 'Unavailable',
              subtitle: 'توان سیگنال دریافت (RSSI): ${n.rssiDbm} dBm',
              icon: Icons.speed,
            ),
            const SizedBox(height: 10),

            MetricCard(
              title: 'باند فرکانسی و استاندارد شبکه',
              value: n.wifiStandard,
              subtitle:
                  'فرکانس حامل: ${n.frequencyMhz} MHz (${n.frequencyBand})',
              icon: Icons.settings_input_antenna,
            ),
            const SizedBox(height: 10),
          ],

          MetricCard(
            title: 'آدرس IP محلی کارت شبکه (IPv4)',
            value: n.localIpv4,
            icon: Icons.lan,
          ),
          const SizedBox(height: 10),

          if (n.dnsServers.isNotEmpty) ...[
            MetricCard(
              title: 'سرورهای DNS شبکه',
              value: n.dnsServers.join(' , '),
              icon: Icons.dns,
            ),
            const SizedBox(height: 10),
          ],

          // Note about Wi-Fi SSID
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: const Text(
              'شفافیت دسترسی: بر اساس قوانین حریم خصوصی Android 10 و بالاتر، استخراج نام وای‌فای (SSID) نیازمند روشن بودن GPS و اعطای مجوز Location به درخواست کاربر است.',
              style: TextStyle(fontSize: 11, height: 1.5, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
