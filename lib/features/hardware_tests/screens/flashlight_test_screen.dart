import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/platform/device_info_service.dart';

class FlashlightTestScreen extends StatefulWidget {
  const FlashlightTestScreen({super.key});

  @override
  State<FlashlightTestScreen> createState() => _FlashlightTestScreenState();
}

class _FlashlightTestScreenState extends State<FlashlightTestScreen> {
  final DeviceInfoService _service = DeviceInfoService();
  bool _isOn = false;
  Timer? _autoOffTimer;

  @override
  void dispose() {
    _turnOff();
    super.dispose();
  }

  void _turnOff() {
    _autoOffTimer?.cancel();
    if (_isOn) {
      _service.setFlashlight(false);
      if (mounted) setState(() => _isOn = false);
    }
  }

  void _toggleFlash() async {
    final nextState = !_isOn;
    final success = await _service.setFlashlight(nextState);
    if (success && mounted) {
      setState(() => _isOn = nextState);
      if (_isOn) {
        // Auto off after 30 seconds to prevent LED overheating
        _autoOffTimer?.cancel();
        _autoOffTimer = Timer(const Duration(seconds: 30), () {
          _turnOff();
        });
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'روشن کردن فلش با خطا مواجه شد یا سخت‌افزار فلش وجود ندارد.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تست فلش‌لایت (Flashlight)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _toggleFlash,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isOn
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF1E293B),
                    boxShadow: _isOn
                        ? [
                            BoxShadow(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ]
                        : [],
                    border: Border.all(
                      color: _isOn ? Colors.white : const Color(0xFF334155),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _isOn ? Icons.flashlight_on : Icons.flashlight_off,
                    size: 60,
                    color: _isOn ? Colors.white : const Color(0xFF94A3B8),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                _isOn ? 'چراغ‌قوه روشن است' : 'چراغ‌قوه خاموش است',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'جهت محافظت از دیود نوری و کاهش مصرف باتری، فلش به صورت خودکار پس از ۳۰ ثانیه خاموش می‌شود.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isOn
                      ? const Color(0xFFF43F5E)
                      : const Color(0xFF06B6D4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                onPressed: _toggleFlash,
                child: Text(_isOn ? 'خاموش کردن فلش' : 'روشن کردن فلش'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
