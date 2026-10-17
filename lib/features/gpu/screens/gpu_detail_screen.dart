import 'package:flutter/material.dart';

import '../models/gpu_info_model.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/widgets/metric_card.dart';

class GpuDetailScreen extends StatefulWidget {
  const GpuDetailScreen({super.key});

  @override
  State<GpuDetailScreen> createState() => _GpuDetailScreenState();
}

class _GpuDetailScreenState extends State<GpuDetailScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  GpuInfoModel? _gpu;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() => _isLoading = true);
    try {
      final g = await _service.getGpuInfo();
      if (mounted)
        setState(() {
          _gpu = g;
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
    if (_gpu == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('پردازنده گرافیکی')),
        body: Center(
          child: ElevatedButton(
            onPressed: _load,
            child: const Text('تلاش مجدد'),
          ),
        ),
      );
    }

    final gpu = _gpu!;

    return Scaffold(
      appBar: AppBar(title: const Text('مشخصات پردازنده گرافیکی و رندر')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MetricCard(
            title: 'مدل پردازنده گرافیکی (GPU Renderer)',
            value: gpu.renderer,
            subtitle: 'فروشنده: ${gpu.vendor}',
            icon: Icons.games,
            iconColor: const Color(0xFF06B6D4),
          ),
          const SizedBox(height: 10),
          MetricCard(
            title: 'نسخه رابط OpenGL ES',
            value: gpu.version,
            icon: Icons.layers,
          ),
          const SizedBox(height: 10),
          MetricCard(
            title: 'پشتیبانی از رابط مدرن Vulkan',
            value: gpu.hasVulkan ? 'پشتیبانی می‌شود' : 'پشتیبانی نمی‌شود',
            subtitle: 'کد نسخه: ${gpu.vulkanVersionCode}',
            icon: Icons.hub,
            iconColor: gpu.hasVulkan ? const Color(0xFF10B981) : Colors.grey,
          ),
          const SizedBox(height: 10),
          MetricCard(
            title: 'پسوندهای گرافیکی (GL Extensions)',
            value: '${gpu.extensionsCount} افزونه فعال',
            icon: Icons.extension,
          ),
          const SizedBox(height: 16),
          const Text(
            'فهرست افزونه‌های سخت‌افزاری OpenGL ES:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              itemCount: gpu.extensions.length,
              itemBuilder: (context, idx) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    gpu.extensions[idx],
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
