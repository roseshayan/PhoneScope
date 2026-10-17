import 'package:flutter/material.dart';

import '../models/camera_info_model.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/widgets/status_badge.dart';

class CameraDetailScreen extends StatefulWidget {
  const CameraDetailScreen({super.key});

  @override
  State<CameraDetailScreen> createState() => _CameraDetailScreenState();
}

class _CameraDetailScreenState extends State<CameraDetailScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  CameraInfoModel? _cameraInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() => _isLoading = true);
    try {
      final c = await _service.getCameraInfo();
      if (mounted)
        setState(() {
          _cameraInfo = c;
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

    final info = _cameraInfo;
    if (info == null || info.cameras.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('دوربین‌ها')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('دوربین قابل شناسایی یافت نشد یا دسترسی مسدود است.'),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('تلاش مجدد')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('مشخصات دوربین‌ها (${info.camerasCount} لنز)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: info.cameras.length,
        itemBuilder: (context, idx) {
          final c = info.cameras[idx];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
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
                          Icon(
                            c.facing.contains('Front')
                                ? Icons.camera_front
                                : Icons.camera_rear,
                            color: const Color(0xFF06B6D4),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'دوربین شناسه ${c.id}: ${c.facing}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      StatusBadge(
                        label: '${c.megapixels} MP',
                        type: BadgeType.info,
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  _buildRow('سطح سخت‌افزاری Camera2:', c.hardwareLevel),
                  _buildRow(
                    'ابعاد فعال سنسور:',
                    '${c.sensorWidth} × ${c.sensorHeight} پیکسل',
                  ),
                  _buildRow('اندازه فیزیکی سنسور:', c.physicalSensorSize),
                  _buildRow(
                    'فاصله کانونی:',
                    c.focalLengths.isNotEmpty
                        ? c.focalLengths
                              .map((f) => '${f.toStringAsFixed(1)}mm')
                              .join(', ')
                        : 'Unavailable',
                  ),
                  _buildRow(
                    'گشودگی دیافراگم (Aperture):',
                    c.apertures.isNotEmpty
                        ? c.apertures
                              .map((a) => "f/${a.toStringAsFixed(1)}")
                              .join(", ")
                        : 'Unavailable',
                  ),
                  _buildRow(
                    'محدوده حساسیت ISO:',
                    c.isoMax > 0 ? '${c.isoMin} - ${c.isoMax}' : 'Unavailable',
                  ),
                  _buildRow('دارای فلاش ال‌ای‌دی:', c.hasFlash ? 'بله' : 'خیر'),
                  _buildRow(
                    'لرزش‌گیر اپتیکال (OIS):',
                    c.hasOis ? 'بله' : 'خیر',
                  ),
                  _buildRow(
                    'پشتیبانی از عکاسی خام (RAW):',
                    c.supportsRaw ? 'پشتیبانی می‌شود' : 'خیر',
                  ),
                  if (c.supportedResolutions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'برخی وضوح‌های خروجی JPEG:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.supportedResolutions.take(6).join(' | '),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
