import 'package:flutter/material.dart';

class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key});

  final List<Map<String, String>> _terms = const [
    {
      'term': 'چیپ‌ست و پردازنده (SoC - System on a Chip)',
      'desc': 'تراشه مدار مجتمع کاملی است که پردازنده مرکزی (CPU)، پردازنده گرافیک (GPU)، مودم، پردازشگر تصویر (ISP) و حافظه رم را روی یک سیلیکون واحد تجمیع می‌کند.',
    },
    {
      'term': 'معماری هسته‌های big.LITTLE و Tri-Cluster',
      'desc': 'رویکردی مهندسی که هسته‌های پرمصرف و قدرتمند (Performance/Prime) را برای بارهای سنگین و هسته‌های کم‌مصرف (Efficiency) را برای امور عادی و پس‌زمینه به کار می‌گیرد.',
    },
    {
      'term': 'واسط برنامه نویسی Vulkan و OpenGL ES',
      'desc': 'رابط‌های گرافیکی سطح پایین و استاندارد برای ارتباط مستقیم با GPU. ولکان (Vulkan) با کاهش بار پردازنده (Overhead)، بازدهی بازی‌ها و رندرهای سه‌بعدی را تا حد چشمگیری افزایش می‌دهد.',
    },
    {
      'term': 'افت عملکرد حرارتی (Thermal Throttling)',
      'desc': 'سازوکار محافظتی خودکار پردازنده که به محض رسیدن دما به آستانه بحرانی، فرکانس هسته‌ها را کاهش می‌دهد تا مانع آسیب فیزیکی به باتری و مدارهای دستگاه شود.',
    },
    {
      'term': 'حاشیه حرارتی (Thermal Headroom)',
      'desc': 'شاخصی رسمی در اندروید ۱۱ به بعد که نشان می‌دهد پردازنده پیش از آغاز روند خفگی حرارتی، چند درصد دیگر ظرفیت جذب حرارت دارد.',
    },
    {
      'term': 'نرخ نوسازی (Refresh Rate)',
      'desc': 'تعداد دفعاتی که صفحه‌نمایش در هر ثانیه تصویر را بروزرسانی می‌کند (مثلاً 60Hz، 90Hz، 120Hz). نرخ‌های بالاتر به معنای انیمیشن‌ها و اسکرول روان‌تر است.',
    },
    {
      'term': 'تراکم پیکسلی (DPI / PPI)',
      'desc': 'تعداد نقاط یا پیکسل‌ها در هر اینچ مربع از نمایشگر. ارقام بالاتر از ۳۵۰ پیکسل در اینچ تصویری فوق‌العاده شفاف و بدون مشاهده خطوط پیکسلی ارائه می‌دهند.',
    },
    {
      'term': 'لرزش‌گیر اپتیکال دوربین (OIS)',
      'desc': 'مکانیسمی فیزیکی در ماژول دوربین که با حرکت دادن لنز یا سنسور در جهت عکس لرزش دست، عکس‌های شارپ‌تر در نور شب و ویدیوهای بدون لرزش ثبت می‌کند.',
    },
    {
      'term': 'رابط باینری کاربردی (ABI)',
      'desc': 'استاندارد ارتباطی سطح ماشین میان کدهای بومی کامپایل‌شده (C/C++) و پردازنده. مانند arm64-v8a برای پردازنده‌های مدرن ۶۴ بیتی.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('واژه‌نامه تخصصی سخت‌افزار')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _terms.length,
        itemBuilder: (context, idx) {
          final t = _terms[idx];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['term']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF06B6D4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t['desc']!,
                    style: const TextStyle(fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
