import 'dart:async';

import 'package:flutter/material.dart';

import '../models/battery_info_model.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/utilities/formatters.dart';
import '../../../core/widgets/metric_card.dart';

class BatteryDetailScreen extends StatefulWidget {
  const BatteryDetailScreen({super.key});

  @override
  State<BatteryDetailScreen> createState() => _BatteryDetailScreenState();
}

class _BatteryDetailScreenState extends State<BatteryDetailScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  BatteryInfoModel? _battery;
  StreamSubscription? _sub;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _sub = _service.batteryStream.listen((b) {
      if (mounted) setState(() => _battery = b);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _loadInitial() async {
    try {
      final b = await _service.getBatteryInfo();
      if (mounted) {
        setState(() {
          _battery = b;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _battery == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final b = _battery;
    if (b == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('باتری و تغذیه')),
        body: const Center(child: Text('اطلاعات باتری در دسترس نیست')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('وضعیت باتری و شارژ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Battery Circular Level Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 75,
                        height: 75,
                        child: CircularProgressIndicator(
                          value: (b.level / 100.0).clamp(0.0, 1.0),
                          strokeWidth: 8,
                          backgroundColor: const Color(0xFF334155),
                          valueColor: AlwaysStoppedAnimation(
                            b.isCharging
                                ? const Color(0xFF10B981)
                                : const Color(0xFF06B6D4),
                          ),
                        ),
                      ),
                      Text(
                        '${b.level.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              b.isCharging
                                  ? Icons.battery_charging_full
                                  : Icons.battery_std,
                              color: b.isCharging
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF06B6D4),
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              b.status,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'منبع اتصال: ${b.plugged}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'فناوری شیمیایی: ${b.technology}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          MetricCard(
            title: 'دمای باتری (سنسور فیزیکی)',
            value: Formatters.formatTemperature(b.temperatureCelsius),
            icon: Icons.thermostat,
            iconColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 10),

          MetricCard(
            title: 'ولتاژ لحظه‌ای',
            value: Formatters.formatMilliVolts(b.voltageMv),
            icon: Icons.electric_bolt,
            iconColor: const Color(0xFF38BDF8),
          ),
          const SizedBox(height: 10),

          MetricCard(
            title: 'جریان لحظه‌ای شارژ / دشارژ',
            value: Formatters.formatMicroAmps(b.currentNowMicroAmps),
            subtitle: b.currentNowMicroAmps != 0
                ? 'علامت مثبت نشان‌دهنده شارژ و علامت منفی نشان‌دهنده مصرف است.'
                : 'اندازه‌گیری توسط درایور چیپ‌ست پشتیبانی نمی‌شود.',
            icon: Icons.speed,
          ),
          const SizedBox(height: 10),

          MetricCard(
            title: 'سلامت گزارش‌شده توسط سیستم',
            value: b.health,
            subtitle: 'وضعیت رسمی ثبت‌شده در BatteryManager اندروید',
            icon: Icons.favorite,
            iconColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 10),

          if (b.chargeCounterMicroAmpHours > 0) ...[
            MetricCard(
              title: 'شمارنده بار الکتریکی (Charge Counter)',
              value:
                  '${(b.chargeCounterMicroAmpHours / 1000).toStringAsFixed(0)} mAh',
              icon: Icons.battery_saver,
            ),
            const SizedBox(height: 10),
          ],

          // Note about real battery capacity vs degradation
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: const Text(
              'نکته مهندسی: در نسخه‌های عمومی Android SDK بدون دسترسی روت، ظرفیت فرسودگی شیمیایی باتری ارائه نمی‌شود. سلامت فوق وضعیت ایمنی و سنسور داخلی گزارش‌شده توسط سیستم است.',
              style: TextStyle(fontSize: 11, height: 1.5, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
