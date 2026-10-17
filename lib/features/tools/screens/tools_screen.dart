import 'package:flutter/material.dart';

import '../../benchmarks/screens/benchmarks_screen.dart';
import '../../anomaly_detection/screens/anomaly_detection_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../../settings/screens/settings_screen.dart';
import 'used_phone_checklist_screen.dart';

class ToolsScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const ToolsScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ابزارها و قابلیت‌های پیشرفته')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildToolTile(
            context: context,
            title: 'بنچمارک و سنجش کارایی (Benchmarks)',
            subtitle:
                'تست تک‌هسته‌ای و چندهسته‌ای CPU و آزمون I/O حافظه با متد علمی',
            icon: Icons.speed,
            color: const Color(0xFF06B6D4),
            destination: const BenchmarksScreen(),
          ),
          const SizedBox(height: 10),

          _buildToolTile(
            context: context,
            title: 'بررسی اصالت و سلامت دستگاه (Authenticity Check)',
            subtitle: 'تطبیق متقابل ABI، روت، کرنل و کشف تغییرات غیرعادی ساخت',
            icon: Icons.verified_user,
            color: const Color(0xFF10B981),
            destination: const AnomalyDetectionScreen(),
          ),
          const SizedBox(height: 10),

          _buildToolTile(
            context: context,
            title: 'صدور و اشتراک‌گذاری گزارش (Export Reports)',
            subtitle: 'تهیه خروجی تشخیصی در قالب فایل‌های رسمی PDF، JSON و TXT',
            icon: Icons.picture_as_pdf,
            color: const Color(0xFFF59E0B),
            destination: const ReportsScreen(),
          ),
          const SizedBox(height: 10),

          _buildToolTile(
            context: context,
            title: 'چک‌لیست بررسی گوشی دست‌دوم (Buyer Guide)',
            subtitle:
                'فهرست گام‌به‌گام بررسی قطعات و رجیستری جهت خرید و فروش مطمئن',
            icon: Icons.checklist,
            color: const Color(0xFF8B5CF6),
            destination: const UsedPhoneChecklistScreen(),
          ),
          const SizedBox(height: 10),

          _buildToolTile(
            context: context,
            title: 'تنظیمات، واژه‌نامه و درباره (Settings)',
            subtitle:
                'تغییر تم تاریک/روشن، واژه‌نامه تخصصی اصطلاحات و حریم خصوصی',
            icon: Icons.settings,
            color: const Color(0xFF64748B),
            destination: SettingsScreen(
              onToggleTheme: onToggleTheme,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          maxLines: 2,
        ),
        trailing: const Icon(Icons.chevron_left, size: 20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        ),
      ),
    );
  }
}
