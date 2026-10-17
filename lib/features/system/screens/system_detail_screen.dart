import 'package:flutter/material.dart';

import '../models/system_info_model.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/utilities/formatters.dart';
import '../../../core/widgets/metric_card.dart';

class SystemDetailScreen extends StatefulWidget {
  const SystemDetailScreen({super.key});

  @override
  State<SystemDetailScreen> createState() => _SystemDetailScreenState();
}

class _SystemDetailScreenState extends State<SystemDetailScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  SystemInfoModel? _system;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() => _isLoading = true);
    try {
      final s = await _service.getSystemInfo();
      if (mounted) {
        setState(() {
          _system = s;
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
    if (_system == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('سیستم‌عامل و ساخت')),
        body: Center(
          child: ElevatedButton(
            onPressed: _load,
            child: const Text('تلاش مجدد'),
          ),
        ),
      );
    }

    final s = _system!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مشخصات سیستم‌عامل و دستگاه'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MetricCard(
            title: 'نام مدل تجاری و فنی',
            value: '${s.manufacturer} ${s.model}',
            subtitle: 'شناسه مدل: ${s.device} (${s.product})',
            icon: Icons.smartphone,
          ),
          const SizedBox(height: 10),
          MetricCard(
            title: 'نسخه اندروید و سطح API',
            value: 'Android ${s.androidVersion} (API ${s.apiLevel})',
            subtitle: 'وصله امنیتی: ${s.securityPatch}',
            icon: Icons.android,
            iconColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 10),
          MetricCard(
            title: 'معماری پردازه و سازگاری',
            value: s.is64Bit ? '۶۴ بیتی (64-Bit OS)' : '۳۲ بیتی (32-Bit OS)',
            subtitle: 'ABI اصلی: ${s.supportedAbis.firstOrNull ?? "Unknown"}',
            icon: Icons.settings_system_daydream,
          ),
          const SizedBox(height: 10),
          MetricCard(
            title: 'نسخه کرنل لینوکس',
            value: s.kernelVersion,
            icon: Icons.terminal,
          ),
          const SizedBox(height: 10),
          MetricCard(
            title: 'شناسه برد و سخت‌افزار',
            value: '${s.board} / ${s.hardware}',
            subtitle: 'بوت‌لودر: ${s.bootloader}',
            icon: Icons.developer_board,
          ),
          const SizedBox(height: 10),
          MetricCard(
            title: 'شناسه ساخت (Build Display ID)',
            value: s.buildId,
            subtitle: 'نوع ساخت: ${s.buildType}',
            icon: Icons.fingerprint,
          ),
          const SizedBox(height: 10),
          MetricCard(
            title: 'اثر انگشت ساخت (Fingerprint)',
            value: s.fingerprint,
            icon: Icons.verified_user,
          ),
          const SizedBox(height: 10),
          MetricCard(
            title: 'مدت زمان روشن بودن (Uptime)',
            value: Formatters.formatUptime(s.uptimeMillis),
            icon: Icons.timer,
          ),
          const SizedBox(height: 10),
          MetricCard(
            title: 'وضعیت روت و دسترسی سیستمی (اکتشافی)',
            value: s.isRootedHeuristic
                ? 'ردپای مشکوک روت یا Superuser'
                : 'سیستم فاقد روت و بدون تغییر است',
            subtitle: s.rootCheckDetails.isNotEmpty
                ? s.rootCheckDetails.join(' | ')
                : null,
            icon: s.isRootedHeuristic ? Icons.warning : Icons.security,
            iconColor: s.isRootedHeuristic
                ? const Color(0xFFF43F5E)
                : const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }
}
