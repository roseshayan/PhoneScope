import 'package:flutter/material.dart';

import '../../../core/platform/device_info_service.dart';
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
    final service = DeviceInfoService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات و درباره فون‌اسکوپ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Header with Logo
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/icons/phonescope_logo.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 64,
                        height: 64,
                        color: const Color(0xFF06B6D4),
                        child: const Icon(Icons.memory, color: Colors.white, size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PhoneScope',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'فون‌اسکوپ • تحلیلگر جامع سخت‌افزار',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF06B6D4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'نسخه ۱.۰.۰ (انتشار پایدار)',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

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

          // Developer Profile Card
          const Text(
            'توسعه‌دهنده و سازنده',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF06B6D4), width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.code,
                          color: Color(0xFF06B6D4),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'شایان نماینده',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Shayan Namayandeh • توسعه‌دهنده نرم‌افزار',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // Website Link
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language, color: Color(0xFF06B6D4), size: 20),
                    title: const Text('وب‌سایت شخصی', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('https://devshayan.ir', style: TextStyle(fontSize: 12, color: Color(0xFF06B6D4))),
                    trailing: const Icon(Icons.open_in_new, size: 16),
                    onTap: () => service.openUrl('https://devshayan.ir'),
                  ),

                  // GitHub Link
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.terminal, color: Color(0xFF10B981), size: 20),
                    title: const Text('گیت‌هاب (GitHub)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('https://github.com/roseshayan', style: TextStyle(fontSize: 12, color: Color(0xFF10B981))),
                    trailing: const Icon(Icons.open_in_new, size: 16),
                    onTap: () => service.openUrl('https://github.com/roseshayan'),
                  ),

                  // Email Contact
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.email_outlined, color: Color(0xFFF59E0B), size: 20),
                    title: const Text('ارتباط و پشتیبانی', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('namayandeshayan@gmail.com', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.send, size: 16),
                    onTap: () => service.openUrl('mailto:namayandeshayan@gmail.com'),
                  ),
                ],
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
                        Icons.shield_outlined,
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
                    'PhoneScope اطلاعات هویتی حساس مانند IMEI، شماره سریال سخت‌افزاری یا شناسه کاربری را جمع‌آوری نمی‌کند. برنامه فاقد هرگونه سرور اختصاصی و سیستم تحلیل رفتار کاربر (Analytics) بوده و تمامی تست‌ها و بنچمارک‌ها به صورت محلی بر روی دستگاه شما اجرا می‌شوند.',
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

          // Share App
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF06B6D4)),
              title: const Text(
                'معرفی PhoneScope به دیگران',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: const Text(
                'اشتراک‌گذاری این ابزار با دوستان و همکاران',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {
                service.shareText(
                  '📱 اپلیکیشن PhoneScope (فون‌اسکوپ) - ابزار جامع تست سخت‌افزار، بنچمارک و پایش سیستم اندروید\nتوسعه‌دهنده: شایان نماینده\nhttps://github.com/roseshayan/PhoneScope',
                  title: 'معرفی اپلیکیشن PhoneScope',
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
