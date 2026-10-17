import 'package:flutter/material.dart';

import '../../system/screens/system_detail_screen.dart';
import '../../soc/screens/soc_detail_screen.dart';
import '../../gpu/screens/gpu_detail_screen.dart';
import '../../memory/screens/memory_detail_screen.dart';
import '../../battery/screens/battery_detail_screen.dart';
import '../../display/screens/display_detail_screen.dart';
import '../../camera/screens/camera_detail_screen.dart';
import '../../sensors/screens/sensors_detail_screen.dart';
import '../../network/screens/network_detail_screen.dart';
import '../../apps/screens/apps_list_screen.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مشخصات قطعات و سخت‌افزار')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildCategoryCard(
            context: context,
            title: 'سیستم‌عامل و ساخت (OS & System)',
            subtitle:
                'نسخه اندروید، کرنل، وصله امنیتی، شناسه دستگاه و بوت‌لودر',
            icon: Icons.android,
            color: const Color(0xFF10B981),
            destination: const SystemDetailScreen(),
          ),
          const SizedBox(height: 10),

          _buildCategoryCard(
            context: context,
            title: 'پردازنده و چیپ‌ست (SoC & CPU)',
            subtitle: 'تعداد هسته‌ها، خوشه‌ها، فرکانس‌های کاری و معماری',
            icon: Icons.memory,
            color: const Color(0xFF06B6D4),
            destination: const SocDetailScreen(),
          ),
          const SizedBox(height: 10),

          _buildCategoryCard(
            context: context,
            title: 'پردازنده گرافیکی (GPU & Render)',
            subtitle: 'مدل رندر، نسخه OpenGL ES، پسوندها و پشتیبانی از Vulkan',
            icon: Icons.games,
            color: const Color(0xFF8B5CF6),
            destination: const GpuDetailScreen(),
          ),
          const SizedBox(height: 10),

          _buildCategoryCard(
            context: context,
            title: 'حافظه موقت و ذخیره‌سازی (RAM & Storage)',
            subtitle: 'فضای اشغال‌شده، رم در دسترس، حافظه داخلی و کارت حافظه',
            icon: Icons.storage,
            color: const Color(0xFF38BDF8),
            destination: const MemoryDetailScreen(),
          ),
          const SizedBox(height: 10),

          _buildCategoryCard(
            context: context,
            title: 'باتری و شارژ (Battery & Power)',
            subtitle: 'درصد شارژ، دمای باتری، ولتاژ، جریان لحظه‌ای و سلامت',
            icon: Icons.battery_charging_full,
            color: const Color(0xFFF59E0B),
            destination: const BatteryDetailScreen(),
          ),
          const SizedBox(height: 10),

          _buildCategoryCard(
            context: context,
            title: 'صفحه‌نمایش (Display & Screen)',
            subtitle: 'رزولوشن فیزیکی و منطقی، تراکم پیکسل، رفرش‌ریت و HDR',
            icon: Icons.smartphone,
            color: const Color(0xFF06B6D4),
            destination: const DisplayDetailScreen(),
          ),
          const SizedBox(height: 10),

          _buildCategoryCard(
            context: context,
            title: 'مشخصات دوربین‌ها (Cameras)',
            subtitle:
                'تعداد لنزها، مگاپیکسل، دیافراگم، فاصله کانونی، OIS و RAW',
            icon: Icons.camera_alt,
            color: const Color(0xFFEC4899),
            destination: const CameraDetailScreen(),
          ),
          const SizedBox(height: 10),

          _buildCategoryCard(
            context: context,
            title: 'فهرست سنسورها (Sensors)',
            subtitle: 'شتاب‌سنج، ژیروسکوپ، نور، مجاورت، قطب‌نما و پایش زنده',
            icon: Icons.sensors,
            color: const Color(0xFF14B8A6),
            destination: const SensorsDetailScreen(),
          ),
          const SizedBox(height: 10),

          _buildCategoryCard(
            context: context,
            title: 'شبکه و وای‌فای (Network & Wi-Fi)',
            subtitle: 'نوع اتصال، سرعت لینک، باند فرکانسی، IP محلی و DNS',
            icon: Icons.wifi,
            color: const Color(0xFF3B82F6),
            destination: const NetworkDetailScreen(),
          ),
          const SizedBox(height: 10),

          _buildCategoryCard(
            context: context,
            title: 'برنامه‌های نصب‌شده (Installed Apps)',
            subtitle: 'بررسی Target SDK، تاریخ نصب و مجوزهای برنامه‌ها',
            icon: Icons.apps,
            color: const Color(0xFF64748B),
            destination: const AppsListScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
