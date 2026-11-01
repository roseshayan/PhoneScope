import 'package:flutter/material.dart';

import '../../../core/platform/device_info_service.dart';
import '../../../core/ads/adivery_service.dart';
import '../../../core/ads/widgets/adivery_banner_widget.dart';
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
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
                                'نسخه ۱.۰.۰ (آماده انتشار در مایکت و بازار)',
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
                    title: const Text('پوسته تاریک (Dark Mode)', style: TextStyle(fontSize: 14)),
                    subtitle: Text(
                      isDark ? 'پوسته تیره فعال است' : 'پوسته روشن فعال است',
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

                // Glossary
                const Text(
                  'آموزش و مراجع تخصصی',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.menu_book, color: Color(0xFF8B5CF6)),
                    title: const Text(
                      'واژه‌نامه تخصصی سخت‌افزار (Glossary)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'توضیح مفهومی اصطلاحات SoC، رم LPDDR، سنسورها و معماری پردازنده',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GlossaryScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Adivery Ads & Monetization Settings
                const Text(
                  'تبلیغات و کسب درآمد (Adivery)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.campaign, color: Color(0xFF10B981)),
                        title: const Text(
                          'تنظیمات شناسه تبلیغات ادیوری',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'مشاهده و شخصی‌سازی شناسه‌های App ID و Placements ادیوری',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () => _showAdiveryConfigDialog(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.volunteer_activism, color: Color(0xFFF43F5E)),
                        title: const Text(
                          'حمایت از توسعه با مشاهده تبلیغ اختیاری',
                          style: TextStyle(fontSize: 14),
                        ),
                        subtitle: const Text(
                          'نمایش یک تبلیغ ویدیویی کوتاه جهت حمایت رایگان از برنامه',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.play_circle_outline, color: Color(0xFFF43F5E)),
                        onTap: () {
                          AdiveryService().showRewardedAd(
                            onRewardResult: (isRewarded) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isRewarded
                                          ? 'از حمایت ارزشمند شما از فون‌اسکوپ بسیار سپاسگزاریم! ❤️'
                                          : 'تبلیغ به طور کامل پخش نشد.',
                                    ),
                                    backgroundColor: isRewarded
                                        ? const Color(0xFF10B981)
                                        : Colors.grey,
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Developer & Contact Card
                const Text(
                  'سازنده و ارتباط',
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
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.code, color: Color(0xFF06B6D4)),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'شایان نماینده',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    'توسعه‌دهنده فلاتر و اندروید',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                        SizedBox(height: 8),
                        Text(
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
          ),
          const AdiveryBannerWidget(),
        ],
      ),
    );
  }

  void _showAdiveryConfigDialog(BuildContext context) {
    final adivery = AdiveryService();
    final appCtrl = TextEditingController(text: adivery.appId);
    final bannerCtrl = TextEditingController(text: adivery.bannerPlacement);
    final interstitialCtrl = TextEditingController(text: adivery.interstitialPlacement);
    final rewardedCtrl = TextEditingController(text: adivery.rewardedPlacement);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.tune, color: Color(0xFF06B6D4)),
            SizedBox(width: 8),
            Text('مدیریت تبلیغات ادیوری'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'شناسه‌های دریافتی از پنل panel.adivery.com را می‌توانید در این بخش مشاهده و ویرایش کنید:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: appCtrl,
                decoration: const InputDecoration(
                  labelText: 'شناسه اپلیکیشن (App ID)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bannerCtrl,
                decoration: const InputDecoration(
                  labelText: 'شناسه بنر (Banner Placement)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: interstitialCtrl,
                decoration: const InputDecoration(
                  labelText: 'شناسه میان‌صفحه‌ای (Interstitial)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: rewardedCtrl,
                decoration: const InputDecoration(
                  labelText: 'شناسه جایزه‌ای (Rewarded)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 14),
              const Text(
                'تست سریع نمایش:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        AdiveryService().showInterstitialAd(force: true);
                      },
                      child: const Text('تست میان‌صفحه‌ای', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        AdiveryService().showRewardedAd(
                          onRewardResult: (granted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(granted ? 'پاداش تستی ثبت شد!' : 'تبلیغ لود نشد.'),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('تست ویدیویی', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              adivery.updatePlacements(
                appId: appCtrl.text,
                bannerPlacement: bannerCtrl.text,
                interstitialPlacement: interstitialCtrl.text,
                rewardedPlacement: rewardedCtrl.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('شناسه‌های تبلیغاتی ادیوری به‌روزرسانی شد.'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }
}
