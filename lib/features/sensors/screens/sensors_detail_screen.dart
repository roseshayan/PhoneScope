import 'dart:async';

import 'package:flutter/material.dart';

import '../models/sensor_info_model.dart';
import '../../../core/platform/device_info_service.dart';

class SensorsDetailScreen extends StatefulWidget {
  const SensorsDetailScreen({super.key});

  @override
  State<SensorsDetailScreen> createState() => _SensorsDetailScreenState();
}

class _SensorsDetailScreenState extends State<SensorsDetailScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  List<SensorInfoModel> _sensors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    setState(() => _isLoading = true);
    try {
      final s = await _service.getSensorsList();
      if (mounted)
        setState(() {
          _sensors = s;
          _isLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openLiveSensorDialog(SensorInfoModel sensor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LiveSensorSheet(sensor: sensor, service: _service),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('سنسورهای دستگاه (${_sensors.length})'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _sensors.isEmpty
          ? const Center(child: Text('هیچ حسگری یافت نشد.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sensors.length,
              itemBuilder: (context, idx) {
                final s = _sensors[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.sensors,
                        color: Color(0xFF06B6D4),
                      ),
                    ),
                    title: Text(
                      s.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'سازنده: ${s.vendor} | نگارش: ${s.version}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'حالت گزارش: ${s.reportingMode} | مصرف توان: ${s.powerMa.toStringAsFixed(2)} mA',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'بیشینه دامنه: ${s.maxRange.toStringAsFixed(1)} | دقت: ${s.resolution.toStringAsFixed(4)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                      ),
                      onPressed: () => _openLiveSensorDialog(s),
                      child: const Text(
                        'پایش زنده',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _LiveSensorSheet extends StatefulWidget {
  final SensorInfoModel sensor;
  final DeviceInfoService service;

  const _LiveSensorSheet({required this.sensor, required this.service});

  @override
  State<_LiveSensorSheet> createState() => _LiveSensorSheetState();
}

class _LiveSensorSheetState extends State<_LiveSensorSheet> {
  StreamSubscription<SensorEventData>? _sub;
  SensorEventData? _lastData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    try {
      _sub = widget.service
          .getLiveSensorStream(widget.sensor.type)
          .listen(
            (data) {
              if (mounted) setState(() => _lastData = data);
            },
            onError: (e) {
              if (mounted) setState(() => _error = e.toString());
            },
          );
    } catch (e) {
      _error = e.toString();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'داده زنده: ${widget.sensor.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          if (_error != null)
            Text(
              'خطا در دریافت استریم سنسور: $_error',
              style: const TextStyle(color: Colors.red),
            )
          else if (_lastData == null)
            const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('در انتظار دریافت نمونه از سنسور...'),
              ],
            )
          else ...[
            Text(
              'دقت سنسور: ${_lastData!.accuracy}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ..._lastData!.values.asMap().entries.map((entry) {
              final axis = entry.key == 0
                  ? 'X / Value 1'
                  : (entry.key == 1
                        ? 'Y / Value 2'
                        : (entry.key == 2
                              ? 'Z / Value 3'
                              : 'Value ${entry.key + 1}'));
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      axis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      entry.value.toStringAsFixed(4),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF06B6D4),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
