import 'dart:async';

import 'package:flutter/material.dart';

import '../models/thermal_info_model.dart';
import '../../battery/models/battery_info_model.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/widgets/metric_card.dart';

class ThermalMonitorScreen extends StatefulWidget {
  const ThermalMonitorScreen({super.key});

  @override
  State<ThermalMonitorScreen> createState() => _ThermalMonitorScreenState();
}

class _ThermalMonitorScreenState extends State<ThermalMonitorScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  ThermalInfoModel? _thermal;
  BatteryInfoModel? _battery;
  StreamSubscription? _batterySub;
  StreamSubscription? _thermalSub;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _startStreams();
  }

  @override
  void dispose() {
    _batterySub?.cancel();
    _thermalSub?.cancel();
    super.dispose();
  }

  void _loadInitialData() async {
    try {
      final t = await _service.getThermalInfo();
      final b = await _service.getBatteryInfo();
      if (mounted) {
        setState(() {
          _thermal = t;
          _battery = b;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startStreams() {
    _batterySub = _service.batteryStream.listen((b) {
      if (mounted) setState(() => _battery = b);
    });

    _thermalSub = _service.thermalStream.listen((event) {
      if (mounted) {
        final status = event['thermalStatus'] as String? ?? 'Normal';
        final code = event['thermalStatusCode'] as int? ?? 0;
        if (_thermal != null) {
          setState(() {
            _thermal = ThermalInfoModel(
              thermalStatus: status,
              thermalStatusCode: code,
              thermalHeadroom: _thermal!.thermalHeadroom,
              batteryTemperatureCelsius: _battery?.temperatureCelsius,
              isThermalApiSupported: _thermal!.isThermalApiSupported,
              socTemperatureNote: _thermal!.socTemperatureNote,
            );
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final batteryTemp =
        _battery?.temperatureCelsius ?? _thermal?.batteryTemperatureCelsius;
    final statusStr = _thermal?.thermalStatus ?? 'Normal';
    final isThrottled = (_thermal?.thermalStatusCode ?? 0) > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('پایش حرارتی و Thermal Headroom')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thermal Status Alert Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isThrottled
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                  : const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isThrottled
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF10B981),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isThrottled
                      ? Icons.local_fire_department
                      : Icons.check_circle_outline,
                  color: isThrottled
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF10B981),
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'وضعیت حرارتی سیستم: $statusStr',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isThrottled
                            ? 'کاهش فرکانس به دلیل بالا رفتن دمای دستگاه فعال شده است.'
                            : 'سیستم در بازه دمایی ایمن و پایدار کار می‌کند.',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          MetricCard(
            title: 'دمای باتری (سنسور فیزیکی واقعی)',
            value: batteryTemp != null
                ? '${batteryTemp.toStringAsFixed(1)} °C'
                : 'Unavailable',
            subtitle: 'داده زنده از سنسور حرارتی تراشه باتری',
            icon: Icons.thermostat,
            iconColor: const Color(0xFF06B6D4),
          ),
          const SizedBox(height: 12),

          MetricCard(
            title: 'حاشیه حرارتی (Thermal Headroom)',
            value: _thermal?.thermalHeadroom != null
                ? '${((_thermal!.thermalHeadroom! * 100)).toStringAsFixed(0)}%'
                : 'در دسترس نیست (نیازمند اندروید ۱۱ به بالا)',
            subtitle: 'میزان ظرفیت پردازشی قبل از آغاز Throttling',
            icon: Icons.speed,
            iconColor: const Color(0xFF38BDF8),
          ),
          const SizedBox(height: 12),

          MetricCard(
            title: 'سرویس سخت‌افزاری Thermal HAL',
            value: _thermal?.isThermalApiSupported == true
                ? 'پشتیبانی می‌شود (Android 10+)'
                : 'پشتیبانی نمی‌شود',
            subtitle: 'API رسمی مدیریت توان و دفع حرارت اندروید',
            icon: Icons.developer_mode,
            iconColor: const Color(0xFF10B981),
          ),
          const SizedBox(height: 20),

          // Technical Transparency Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield, size: 18, color: Color(0xFF06B6D4)),
                    SizedBox(width: 8),
                    Text(
                      'شفافیت فنی PhoneScope:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _thermal?.socTemperatureNote ?? 'در نسخه‌های جدید اندروید، دسترسی برنامه‌های شخص ثالث به سنسورهای دمایی داخلی هسته‌های CPU/GPU توسط سیاست‌های SELinux مسدود است. PhoneScope از نمایش اعداد جعلی خودداری کرده و وضعیت را بر اساس سرویس رسمی Thermal HAL و سنسور فیزیکی باتری نمایش می‌دهد.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
