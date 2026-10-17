import 'package:flutter/material.dart';

import '../models/display_info_model.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/widgets/metric_card.dart';

class DisplayDetailScreen extends StatefulWidget {
  const DisplayDetailScreen({super.key});

  @override
  State<DisplayDetailScreen> createState() => _DisplayDetailScreenState();
}

class _DisplayDetailScreenState extends State<DisplayDetailScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  DisplayInfoModel? _display;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() => _isLoading = true);
    try {
      final d = await _service.getDisplayInfo();
      if (mounted) {
        setState(() {
          _display = d;
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

    final d = _display;
    if (d == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('صفحه‌نمایش')),
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
        title: const Text('مشخصات صفحه‌نمایش'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MetricCard(
            title: 'رزولوشن فیزیکی پنل',
            value: '${d.physicalWidthPixels} × ${d.physicalHeightPixels} پیکسل',
            subtitle:
                'رزولوشن منطقی نرم‌افزار: ${d.logicalWidthDp} × ${d.logicalHeightDp} dp',
            icon: Icons.aspect_ratio,
            iconColor: const Color(0xFF06B6D4),
          ),
          const SizedBox(height: 10),

          MetricCard(
            title: 'تراکم پیکسلی (Density)',
            value: '${d.densityDpi} DPI',
            subtitle:
                'ضریب مقیاس: ${d.density.toStringAsFixed(2)}x (xdpi: ${d.xdpi.toStringAsFixed(0)}, ydpi: ${d.ydpi.toStringAsFixed(0)})',
            icon: Icons.grid_4x4,
          ),
          const SizedBox(height: 10),

          MetricCard(
            title: 'اندازه تخمینی قطر صفحه‌نمایش',
            value: '${d.diagonalInches.toStringAsFixed(1)} اینچ',
            subtitle: 'محاسبه‌شده بر اساس ابعاد فیزیکی و مقادیر xdpi/ydpi',
            icon: Icons.photo_size_select_small,
          ),
          const SizedBox(height: 10),

          MetricCard(
            title: 'نرخ نوسازی تصویر (Refresh Rate)',
            value: '${d.currentRefreshRate.toStringAsFixed(0)} Hz',
            subtitle: d.supportedRefreshRates.isNotEmpty
                ? 'نرخ‌های پشتیبانی‌شده: ${d.supportedRefreshRates.map((r) => "${r.toStringAsFixed(0)}Hz").join(", ")}'
                : null,
            icon: Icons.speed,
            iconColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 10),

          MetricCard(
            title: 'دامنه دینامیکی بالا (HDR)',
            value: d.isHdrSupported ? 'پشتیبانی می‌شود' : 'پشتیبانی نمی‌شود',
            subtitle: d.hdrTypes.isNotEmpty
                ? 'فرمت‌ها: ${d.hdrTypes.join(", ")}'
                : null,
            icon: Icons.hdr_on,
            iconColor: d.isHdrSupported ? const Color(0xFF10B981) : Colors.grey,
          ),
          const SizedBox(height: 10),

          MetricCard(
            title: 'وسعت رنگ گسترده (Wide Color Gamut)',
            value: d.isWideColorGamut ? 'بله (DCI-P3 / sRGB)' : 'خیر',
            icon: Icons.palette,
          ),
          const SizedBox(height: 10),

          MetricCard(
            title: 'جهت چرخش جاری صفحه',
            value: d.orientation,
            icon: Icons.screen_rotation,
          ),
        ],
      ),
    );
  }
}
