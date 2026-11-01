import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/platform/device_info_service.dart';
import '../../../core/ads/adivery_service.dart';
import '../../../core/ads/widgets/adivery_banner_widget.dart';

/// صفحه پاک‌کننده جرم و خروج آب از اسپیکر گوشی (Speaker Cleaner & Water Eject)
class SpeakerCleanerScreen extends StatefulWidget {
  const SpeakerCleanerScreen({super.key});

  @override
  State<SpeakerCleanerScreen> createState() => _SpeakerCleanerScreenState();
}

class _SpeakerCleanerScreenState extends State<SpeakerCleanerScreen>
    with SingleTickerProviderStateMixin {
  final DeviceInfoService _deviceService = DeviceInfoService();

  // Mode: 'auto', 'water_eject', 'dust_cleaner', 'manual'
  String _selectedMode = 'water_eject';
  bool _isEarpiece = false;
  bool _enableVibration = true;
  double _manualFrequency = 165.0;

  bool _isRunning = false;
  int _totalDurationSeconds = 30;
  int _remainingSeconds = 30;
  Timer? _countdownTimer;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _stopCleaning();
    _waveController.dispose();
    super.dispose();
  }

  void _startCleaning({int? customDuration}) async {
    final duration = customDuration ?? _totalDurationSeconds;

    setState(() {
      _isRunning = true;
      _totalDurationSeconds = duration;
      _remainingSeconds = duration;
    });

    _waveController.repeat();

    await _deviceService.startSpeakerCleaner(
      mode: _selectedMode,
      frequency: _manualFrequency,
      durationSeconds: duration,
      isEarpiece: _isEarpiece,
      enableVibration: _enableVibration,
    );

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        _stopCleaning();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _stopCleaning() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _waveController.stop();

    if (_isRunning) {
      if (mounted) {
        setState(() {
          _isRunning = false;
          _remainingSeconds = _totalDurationSeconds;
        });
      }
      await _deviceService.stopSpeakerCleaner();
    }
  }

  void _unlockTurboCleaning() {
    // باز کردن حالت توربو با تماشای تبلیغ جایزه‌ای ادیوری
    AdiveryService().showRewardedAd(
      onRewardResult: (isRewarded) {
        if (isRewarded) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('حالت پاک‌سازی عمیق توربو با موفقیت فعال شد!'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
            setState(() {
              _selectedMode = 'auto';
            });
            _startCleaning(customDuration: 60);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('مشاهده کامل ویدیو برای دریافت پاک‌سازی توربو الزامی است.'),
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = _isRunning
        ? (1.0 - (_remainingSeconds / _totalDurationSeconds)).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('پاک‌کننده جرم و آب اسپیکر'),
        actions: [
          IconButton(
            tooltip: 'راهنمای استفاده',
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Visual Animation and Timer Gauge
                  _buildAnimatedHero(isDark, progress),
                  const SizedBox(height: 20),

                  // Speaker Target Selection (Main Speaker vs Earpiece)
                  _buildTargetSelector(isDark),
                  const SizedBox(height: 16),

                  // Cleaning Modes Grid
                  _buildModeSelector(isDark),
                  const SizedBox(height: 16),

                  // Manual Slider if Manual Mode Selected
                  if (_selectedMode == 'manual') ...[
                    _buildManualFrequencySlider(isDark),
                    const SizedBox(height: 16),
                  ],

                  // Options: Vibration Switch
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: SwitchListTile(
                        title: const Text(
                          'ارتعاش مکانیکی هماهنگ (Haptic Vibration)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'لرزش موتور گوشی جهت جدا شدن سریع‌تر جرم و مایعات',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        value: _enableVibration,
                        activeTrackColor: const Color(0xFF06B6D4),
                        onChanged: _isRunning
                            ? null
                            : (val) => setState(() => _enableVibration = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons: Start / Stop
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRunning
                            ? const Color(0xFFF43F5E)
                            : const Color(0xFF06B6D4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      onPressed: _isRunning ? _stopCleaning : () => _startCleaning(),
                      icon: Icon(_isRunning ? Icons.stop_circle : Icons.play_circle_fill),
                      label: Text(
                        _isRunning
                            ? 'توقف پاک‌سازی اسپیکر'
                            : 'شروع عملیات تخلیه و پاک‌سازی',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Turbo Mode Card (Rewarded Ad integration)
                  if (!_isRunning)
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _unlockTurboCleaning,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                                : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.bolt, color: Color(0xFF6366F1)),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'پاک‌سازی فوق‌سریع توربو (Turbo Boost)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                  Text(
                                    'چرخه ۶۰ ثانیه‌ای عمیق با تماشای رایگان یک ویدیو',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF6366F1)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Banner Ad at Bottom
          const AdiveryBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildAnimatedHero(bool isDark, double progress) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final waveVal = _isRunning ? _waveController.value : 0.0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isRunning
                  ? const Color(0xFF06B6D4).withValues(alpha: 0.5)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Animated Wave Rings
                  if (_isRunning) ...[
                    Container(
                      width: 130 + (waveVal * 40),
                      height: 130 + (waveVal * 40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF06B6D4).withValues(alpha: (1.0 - waveVal) * 0.6),
                          width: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 110 + (waveVal * 25),
                      height: 110 + (waveVal * 25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF06B6D4).withValues(alpha: (1.0 - waveVal) * 0.15),
                      ),
                    ),
                  ],

                  // Circular Progress Indicator
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _isRunning ? progress : 0.0,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06B6D4)),
                    ),
                  ),

                  // Center Icon / Counter
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedMode == 'water_eject'
                            ? Icons.water_drop
                            : (_selectedMode == 'dust_cleaner' ? Icons.cleaning_services : Icons.volume_up),
                        color: const Color(0xFF06B6D4),
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isRunning ? '$_remainingSeconds ثانیه' : '${_totalDurationSeconds}s',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _isRunning
                    ? (_selectedMode == 'water_eject'
                        ? 'امواج رزونانس خروج قطرات آب (۱۶۵ هرتز)...'
                        : (_selectedMode == 'dust_cleaner'
                            ? 'پالس‌های ضربه‌ای تکاندن ذرات گرد و غبار...'
                            : 'چرخه چندمرحله‌ای جاروب فرکانسی پویا...'))
                    : 'ولوم گوشی را روی ۱۰۰٪ بگذارید و گوشی را به سمت پایین بگیرید',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: _isRunning ? FontWeight.bold : FontWeight.normal,
                  color: _isRunning ? const Color(0xFF06B6D4) : Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTargetSelector(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              title: 'بلندگوی اصلی (پایین)',
              icon: Icons.speaker,
              isSelected: !_isEarpiece,
              onTap: _isRunning ? null : () => setState(() => _isEarpiece = false),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSegmentButton(
              title: 'اسپیکر مکالمه (بالا)',
              icon: Icons.phone_in_talk,
              isSelected: _isEarpiece,
              onTap: _isRunning ? null : () => setState(() => _isEarpiece = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF06B6D4) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(bool isDark) {
    final modes = [
      {
        'key': 'water_eject',
        'title': 'خروج قطرات آب',
        'desc': 'امواج رزونانس ۱۶۵ هرتز با بیشترین لرزش دیافراگم',
        'icon': Icons.water_drop,
        'duration': 30,
      },
      {
        'key': 'dust_cleaner',
        'title': 'پاک‌سازی جرم و گرد و خاک',
        'desc': 'شوک‌های فرکانس بالا (۲۶۰ تا ۸۸۰ هرتز) جهت تمیزکاری توری',
        'icon': Icons.air,
        'duration': 30,
      },
      {
        'key': 'auto',
        'title': 'چرخه کامل خودکار',
        'desc': 'ترکیب هوشمند سه فاز تخلیه آب، غبارزدایی و سوییپ صوتی',
        'icon': Icons.auto_awesome,
        'duration': 45,
      },
      {
        'key': 'manual',
        'title': 'تنظیم فرکانس دستی',
        'desc': 'انتخاب دستی فرکانس صوت با اسلایدر (۵۰ تا ۱۲۰۰ هرتز)',
        'icon': Icons.tune,
        'duration': 30,
      },
    ];

    return Column(
      children: modes.map((m) {
        final isSelected = _selectedMode == m['key'];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF06B6D4)
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              enabled: !_isRunning,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                setState(() {
                  _selectedMode = m['key'] as String;
                  _totalDurationSeconds = m['duration'] as int;
                  _remainingSeconds = _totalDurationSeconds;
                });
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isSelected ? const Color(0xFF06B6D4) : Colors.grey)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  m['icon'] as IconData,
                  color: isSelected ? const Color(0xFF06B6D4) : Colors.grey,
                ),
              ),
              title: Text(
                m['title'] as String,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                m['desc'] as String,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFF06B6D4), size: 20)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildManualFrequencySlider(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'فرکانس صدای خروجی:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '${_manualFrequency.round()} Hz',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF06B6D4),
                ),
              ),
            ],
          ),
          Slider(
            value: _manualFrequency,
            min: 50.0,
            max: 1200.0,
            divisions: 115,
            activeColor: const Color(0xFF06B6D4),
            onChanged: _isRunning
                ? null
                : (val) => setState(() => _manualFrequency = val),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('۵۰ هرتز (بم عمیق)', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('۱۶۵ هرتز (آب)', style: TextStyle(fontSize: 10, color: Color(0xFF06B6D4))),
              Text('۱۲۰۰ هرتز (زیر)', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFF06B6D4)),
            SizedBox(width: 8),
            Text('نکات طلایی پاک‌سازی اسپیکر'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'مکانیزم کارکرد چگونه است؟',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 6),
              Text(
                'این قابلیت با تولید امواج صوتی در فرکانس رزونانس دیافراگم صوتی گوشی (۱۶۵ هرتز) و پالس‌های مکانیکی با بیشترین نوسان فیزیکی هوا، جرم‌های توری و قطرات آب گیر افتاده را به بیرون پرتاب می‌کند.',
                style: TextStyle(fontSize: 12, height: 1.5),
              ),
              SizedBox(height: 12),
              Text(
                'توصیه‌ها برای بهترین نتیجه:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 6),
              Text('• بلندی صدای گوشی (Media Volume) را روی ۱۰۰٪ قرار دهید.'),
              Text('• گوشی را به صورت عمودی با بلندگو رو به زمین نگه دارید.'),
              Text('• در صورت نفوذ آب زیاد، چرخه را ۲ تا ۳ مرتبه تکرار کنید.'),
              Text('• قاب محافظ گوشی را ترجیحاً جدا کنید تا خروجی منافذ باز باشد.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('متوجه شدم'),
          ),
        ],
      ),
    );
  }
}
