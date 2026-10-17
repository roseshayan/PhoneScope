import 'package:flutter/material.dart';

import 'glossary_screen.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const SettingsScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات و درباره فون‌اسکوپ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance
          const Text(
            'شخصی‌سازی و ظاهر',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: const Color(0xFF06B6D4),
              ),
              title: const Text(
                'حالت تاریک (Dark Mode)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                isDark ? 'تم شب تیره فعال است' : 'تم روز روشن فعال است',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Switch(
                value: isDark,
                activeTrackColor: const Color(0xFF06B6D4),
                onChanged: (_) => onToggleTheme(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Glossary & Learning
          const Text(
            'یادگیری و اصطلاحات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Color(0xFF10B981)),
              title: const Text(
                'واژه‌نامه تخصصی اصطلاحات سخت‌افزار',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: const Text(
                'توضیح ساده و علمی مفاهیم فنی موبایل',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GlossaryScreen()),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Privacy & Policy
          const Text(
            'امنیت و حریم خصوصی',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'سیاست ۱۰۰٪ آفلاین (Zero-Telemetry)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'PhoneScope اطلاعات هویتی حساس مانند IMEI، شماره سریال سخت‌افزاری یا Android ID را به هیچ عنوان جمع‌آوری نمی‌کند. برنامه به هیچ سرور اختصاصی متصل نبوده و تمامی بنچمارک‌ها، مانیتورینگ‌ها و گزارش‌ها کاملاً روی پردازنده و حافظه داخلی گوشی شما اجرا می‌شوند.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // About App
          const Text(
            'درباره برنامه',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PhoneScope (فون‌اسکوپ)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF06B6D4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'نگارش ۱.۰.۰ - آماده انتشار و پایدار',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ابزار جامع و مستقل تحلیل مشخصات سخت‌افزاری، پایش لحظه‌ای منابع، تست قطعات و بنچمارک معتبر برای سیستم‌عامل اندروید.',
                    style: TextStyle(fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
