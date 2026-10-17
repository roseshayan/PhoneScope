import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/platform/device_info_service.dart';

class AudioMicTestScreen extends StatefulWidget {
  const AudioMicTestScreen({super.key});

  @override
  State<AudioMicTestScreen> createState() => _AudioMicTestScreenState();
}

class _AudioMicTestScreenState extends State<AudioMicTestScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  bool _isPlayingTone = false;
  bool _isTestingMic = false;
  double _currentDb = 0.0;
  Timer? _micTimer;

  @override
  void dispose() {
    _stopMicTest();
    _service.stopTestTone();
    super.dispose();
  }

  void _toggleTone() async {
    if (_isPlayingTone) {
      await _service.stopTestTone();
      setState(() => _isPlayingTone = false);
    } else {
      setState(() => _isPlayingTone = true);
      await _service.playTestTone(frequency: 440.0, durationSeconds: 5.0);
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _isPlayingTone) {
          setState(() => _isPlayingTone = false);
        }
      });
    }
  }

  void _startMicTest() {
    setState(() => _isTestingMic = true);
    _micTimer?.cancel();
    _micTimer = Timer.periodic(const Duration(milliseconds: 150), (
      timer,
    ) async {
      final db = await _service.getMicAmplitude();
      if (mounted) {
        setState(() => _currentDb = db);
      }
    });
  }

  void _stopMicTest() {
    _micTimer?.cancel();
    _micTimer = null;
    if (mounted) {
      setState(() {
        _isTestingMic = false;
        _currentDb = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('تست صوت و میکروفون')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Speaker Test Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06B6D4)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            color: Color(0xFF06B6D4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تست بلندگو و خروجی صدا',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'تولید فرکانس سینوسی ۴۴۰ هرتز (نت لا)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'با فشردن دکمه زیر، یک صدای آزمایشی تمیز به مدت ۵ ثانیه پخش می‌شود. به وضوح صدا و عدم وجود نویز یا خش‌خش گوش دهید.',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPlayingTone
                              ? const Color(0xFFF43F5E)
                              : const Color(0xFF06B6D4),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _toggleTone,
                        icon: Icon(
                          _isPlayingTone ? Icons.stop : Icons.play_arrow,
                        ),
                        label: Text(
                          _isPlayingTone ? 'توقف پخش صدا' : 'شروع پخش صدای تست',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Microphone Test Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.mic,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تست ورودی میکروفون',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'پایش دامنه سیگنال و دسی‌بل زنده',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'برای آزمایش، دکمه تست را بزنید و در نزدیکی میکروفون صحبت کنید یا فوت کنید. سطح نوسان نوار باید تغییر کند.',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    // VU Meter Bar
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0B1120)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: (_currentDb / 100.0).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFFF59E0B),
                                    Color(0xFFF43F5E),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              _isTestingMic
                                  ? '${_currentDb.toStringAsFixed(1)} dB'
                                  : 'میکروفون غیرفعال است',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isTestingMic
                              ? const Color(0xFFF43F5E)
                              : const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isTestingMic ? _stopMicTest : _startMicTest,
                        icon: Icon(_isTestingMic ? Icons.mic_off : Icons.mic),
                        label: Text(
                          _isTestingMic
                              ? 'توقف تست میکروفون'
                              : 'آغاز تست زنده میکروفون',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
