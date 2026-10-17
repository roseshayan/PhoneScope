import 'package:flutter/material.dart';

class UsedPhoneChecklistScreen extends StatefulWidget {
  const UsedPhoneChecklistScreen({super.key});

  @override
  State<UsedPhoneChecklistScreen> createState() =>
      _UsedPhoneChecklistScreenState();
}

class _UsedPhoneChecklistScreenState extends State<UsedPhoneChecklistScreen> {
  final Map<int, bool> _checkedItems = {};

  final List<Map<String, String>> _checklist = const [
    {
      'title': 'بررسی رجیستری و همتا',
      'desc': 'استعلام کد IMEI دستگاه از سامانه همتا و تطبیق آن با جعبه گوشی جهت اطمینان از اصالت گمرکی و عدم سرقتی بودن.',
    },
    {
      'title': 'تست تاچ و سلامت تاچ ال‌سی‌دی',
      'desc': 'اجرای تست چندلمسی PhoneScope جهت اطمینان از عدم وجود خطوط کور، پرش تصویر یا سوختگی پیکسل.',
    },
    {
      'title': 'بررسی ولتاژ و دمای باتری',
      'desc': 'بررسی وضعیت سلامت و شارژ شدن سریع بدون داغ شدن غیرعادی یا تخلیه ناگهانی درصد باتری.',
    },
    {
      'title': 'تست فوکوس و هر دو دوربین عقب و جلو',
      'desc': 'بررسی سلامت لنز، لرزش‌گیر اپتیکال (OIS)، فوکوس خودکار، فلش و شیشه محافظ لنزها در برابر خط و خش.',
    },
    {
      'title': 'تست بلندگوی مکالمه و بلندگوی اصلی',
      'desc': 'پخش صدای آزمایشی و برقراری تماس تستی جهت اطمینان از عدم وزوز، خش‌خش یا خفگی بلندگوها.',
    },
    {
      'title': 'تست میکروفون اصلی و میکروفون حذف نویز',
      'desc': 'ضبط صدا و فوت کردن ملایم به میکروفون جهت اطمینان از کارکرد هر دو مجرای صدا.',
    },
    {
      'title': 'تست سنسورهای مجاورت و نور',
      'desc': 'بررسی خاموش شدن صفحه حین نزدیک کردن گوشی به گوش هنگام تماس و تنظیم خودکار روشنایی.',
    },
    {
      'title': 'تست اتصال سیم‌کارت، آنتن‌دهی و Wi-Fi',
      'desc': 'تست اتصال به شبکه 4G/5G و اتصال به شبکه وای‌فای ۵ گیگاهرتز و ۲.۴ گیگاهرتز.',
    },
    {
      'title': 'بررسی یکپارچگی سیستمی و عدم دستکاری رام',
      'desc': 'بررسی تست روت و امضای رسمی سیستم‌عامل در صفحه «بررسی اصالت و سلامت» اپلیکیشن.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final passed = _checkedItems.values.where((v) => v).length;
    final total = _checklist.length;
    final percent = (passed / total * 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(title: const Text('چک‌لیست بررسی گوشی دست‌دوم')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: Color(0xFF06B6D4),
                  size: 36,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'راهنمای خریدار و فروشنده موبایل',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$passed مورد از $total مرحله بررسی شده ($percent%)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...List.generate(_checklist.length, (idx) {
            final item = _checklist[idx];
            final isDone = _checkedItems[idx] == true;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                title: Text(
                  item['title']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  item['desc']!,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Colors.grey,
                  ),
                ),
                value: isDone,
                activeColor: const Color(0xFF10B981),
                onChanged: (val) {
                  setState(() => _checkedItems[idx] = val ?? false);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
