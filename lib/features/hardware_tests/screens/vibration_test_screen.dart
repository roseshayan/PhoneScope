import 'package:flutter/material.dart';

import '../../../core/platform/device_info_service.dart';

class VibrationTestScreen extends StatefulWidget {
  const VibrationTestScreen({super.key});

  @override
  State<VibrationTestScreen> createState() => _VibrationTestScreenState();
}

class _VibrationTestScreenState extends State<VibrationTestScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  String _status = 'آماده تست لرزش و Haptics';

  void _testVibration(String type, int durationMs, String label) async {
    setState(() => _status = 'در حال اجرای: $label...');
    final ok = await _service.vibrate(type: type, durationMs: durationMs);
    if (!ok && mounted) {
      setState(
        () => _status = 'موتور ویبره در دستگاه یافت نشد یا غیرفعال است.',
      );
    }
  }

  void _cancel() async {
    await _service.cancelVibration();
    if (mounted) setState(() => _status = 'ویبره متوقف شد.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تست موتور لرزش و هپتیک')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.vibration,
                        color: Color(0xFF06B6D4),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTestButton(
              title: 'لرزش کوتاه (Short Pulse)',
              subtitle: 'پالس ۲۰۰ میلی‌ثانیه‌ای بازخورد لمسی',
              icon: Icons.touch_app,
              onTap: () => _testVibration('short', 200, 'پالس کوتاه'),
            ),
            const SizedBox(height: 12),
            _buildTestButton(
              title: 'لرزش دوگانه (Double Pulse)',
              subtitle: 'دو پالس متوالی با فاصله کوتاه',
              icon: Icons.notifications_active,
              onTap: () => _testVibration('double', 400, 'پالس دوگانه'),
            ),
            const SizedBox(height: 12),
            _buildTestButton(
              title: 'الگوی SOS (Morse Code)',
              subtitle: 'الگوی استاندارد ۳ کوتاه، ۳ بلند، ۳ کوتاه',
              icon: Icons.warning,
              onTap: () => _testVibration('sos', 1500, 'الگوی SOS'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF43F5E),
                  side: const BorderSide(color: Color(0xFFF43F5E)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _cancel,
                icon: const Icon(Icons.stop),
                label: const Text('توقف فوری لرزش'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF06B6D4)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.play_arrow, size: 20),
        onTap: onTap,
      ),
    );
  }
}
