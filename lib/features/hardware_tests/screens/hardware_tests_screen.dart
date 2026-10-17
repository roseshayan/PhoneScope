import 'package:flutter/material.dart';

import 'display_test_screen.dart';
import 'touch_test_screen.dart';
import 'audio_mic_test_screen.dart';
import 'vibration_test_screen.dart';
import 'flashlight_test_screen.dart';

class HardwareTestsScreen extends StatefulWidget {
  const HardwareTestsScreen({super.key});

  @override
  State<HardwareTestsScreen> createState() => _HardwareTestsScreenState();
}

class _HardwareTestsScreenState extends State<HardwareTestsScreen> {
  final Map<String, bool?> _testResults = {};

  void _recordResult(String testKey, bool passed) {
    setState(() {
      _testResults[testKey] = passed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final completedCount = _testResults.values.where((v) => v != null).length;
    final passedCount = _testResults.values.where((v) => v == true).length;

    return Scaffold(
      appBar: AppBar(title: const Text('آزمایشگاه تست سخت‌افزار')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Header Summary Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFF1F5F9), Colors.white],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fact_check,
                    color: Color(0xFF06B6D4),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'چک‌لیست سلامت قطعات',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$passedCount از $completedCount تست گذرانده شده با موفقیت',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 1. Display Test
          _buildTestTile(
            title: 'تست صفحه‌نمایش (Display & Pixels)',
            subtitle: 'بررسی پیکسل‌های سوخته، گرادیان و یکنواختی پنل',
            icon: Icons.smartphone,
            status: _testResults['display'],
            onStart: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DisplayTestScreen()),
              );
              _showConfirmResultDialog('display', 'صفحه‌نمایش');
            },
          ),

          // 2. Touch Test
          _buildTestTile(
            title: 'تست تاچ و لمس همزمان (Multi-Touch)',
            subtitle: 'بررسی نقاط کور، مسیر لمس و چندانگشتی',
            icon: Icons.fingerprint,
            status: _testResults['touch'],
            onStart: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TouchTestScreen()),
              );
              _showConfirmResultDialog('touch', 'تاچ و لمس');
            },
          ),

          // 3. Audio & Mic Test
          _buildTestTile(
            title: 'تست بلندگو و میکروفون (Audio & Mic)',
            subtitle: 'پخش صدای استاندارد و پایش دامنه سیگنال صدا',
            icon: Icons.volume_up,
            status: _testResults['audio'],
            onStart: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AudioMicTestScreen()),
              );
              _showConfirmResultDialog('audio', 'بلندگو و میکروفون');
            },
          ),

          // 4. Vibration Test
          _buildTestTile(
            title: 'تست موتور لرزش و Haptics',
            subtitle: 'بررسی پالس‌ها و الگوهای لرزشی هپتیک',
            icon: Icons.vibration,
            status: _testResults['vibration'],
            onStart: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VibrationTestScreen()),
              );
              _showConfirmResultDialog('vibration', 'موتور لرزش');
            },
          ),

          // 5. Flashlight Test
          _buildTestTile(
            title: 'تست فلاش دوربین (Flashlight)',
            subtitle: 'آزمایش سلامت دیود ال‌ای‌دی چراغ‌قوه',
            icon: Icons.flashlight_on,
            status: _testResults['flashlight'],
            onStart: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FlashlightTestScreen()),
              );
              _showConfirmResultDialog('flashlight', 'فلش دوربین');
            },
          ),

          // 6. Buttons Manual Guide Test
          _buildTestTile(
            title: 'تست دکمه‌های فیزیکی (Buttons)',
            subtitle: 'بررسی کلیدهای کم/زیاد صدا و پاور',
            icon: Icons.power_settings_new,
            status: _testResults['buttons'],
            onStart: () => _showButtonsTestDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool? status,
    required VoidCallback onStart,
  }) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;
    String statusText = 'آغاز تست';

    if (status == true) {
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle;
      statusText = 'سالم';
    } else if (status == false) {
      statusColor = const Color(0xFFF43F5E);
      statusIcon = Icons.cancel;
      statusText = 'ناسالم / ناموفق';
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF06B6D4), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: statusColor,
            side: BorderSide(color: statusColor),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: Size.zero,
          ),
          onPressed: onStart,
          icon: Icon(statusIcon, size: 16),
          label: Text(statusText, style: const TextStyle(fontSize: 11)),
        ),
      ),
    );
  }

  void _showConfirmResultDialog(String testKey, String testTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('نتیجه تست $testTitle'),
        content: Text(
          'آیا آزمایش سخت‌افزار $testTitle طبق انتظارات شما با موفقیت و بدون نقص انجام شد؟',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _recordResult(testKey, false);
            },
            child: const Text(
              'خیر (دارای نقص)',
              style: TextStyle(color: Color(0xFFF43F5E)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _recordResult(testKey, true);
            },
            child: const Text('بله (سالم)'),
          ),
        ],
      ),
    );
  }

  void _showButtonsTestDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('راهنمای بررسی دکمه‌های فیزیکی'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '۱. دکمه افزایش صدا (+) را فشار دهید و دقت کنید نوار صدای سیستم تغییر کند.',
            ),
            SizedBox(height: 8),
            Text('۲. دکمه کاهش صدا (-) را تست کنید.'),
            SizedBox(height: 8),
            Text('۳. دکمه پاور را به آرامی لمس و فشار دهید.'),
            SizedBox(height: 12),
            Text(
              'نکته مهندسی: به دلیل مسائل امنیتی اندروید، ثبت رویداد دکمه پاور توسط برنامه‌های غیرسیستمی مسدود است.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _recordResult('buttons', false);
            },
            child: const Text(
              'دارای گیر یا نقص',
              style: TextStyle(color: Color(0xFFF43F5E)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _recordResult('buttons', true);
            },
            child: const Text('کلیدها سالم هستند'),
          ),
        ],
      ),
    );
  }
}
