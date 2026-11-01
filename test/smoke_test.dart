import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phonescope/main.dart';
import 'package:phonescope/core/ads/adivery_service.dart';
import 'package:phonescope/core/ads/widgets/adivery_banner_widget.dart';
import 'package:phonescope/core/ads/widgets/adivery_native_card.dart';
import 'package:phonescope/features/hardware_tests/screens/speaker_cleaner_screen.dart';
import 'package:phonescope/features/hardware_tests/screens/hardware_tests_screen.dart';
import 'package:phonescope/features/system/models/system_info_model.dart';
import 'package:phonescope/features/soc/models/cpu_info_model.dart';
import 'package:phonescope/features/memory/models/memory_storage_model.dart';
import 'package:phonescope/features/battery/models/battery_info_model.dart';
import 'package:phonescope/features/thermal/models/thermal_info_model.dart';
import 'package:phonescope/features/network/models/network_info_model.dart';
import 'package:phonescope/features/settings/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Smoke Tests - App & Navigation', () {
    testWidgets('Smoke test: PhoneScopeApp launches and renders MainScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PhoneScopeApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('داشبورد'), findsOneWidget);
      expect(find.text('سخت‌افزار'), findsOneWidget);
      expect(find.text('پایش زنده'), findsOneWidget);
      expect(find.text('تست‌ها'), findsOneWidget);
      expect(find.text('ابزارها'), findsOneWidget);
    });

    testWidgets('Smoke test: Bottom navigation tab switching', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PhoneScopeApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Switch to Hardware/Device tab
      await tester.tap(find.text('سخت‌افزار'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('سخت‌افزار'), findsWidgets);

      // Switch to Live Monitor tab
      await tester.tap(find.text('پایش زنده'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('پایش زنده'), findsWidgets);

      // Switch to Tests tab
      await tester.tap(find.text('تست‌ها'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('آزمایشگاه تست سخت‌افزار'), findsOneWidget);

      // Switch to Tools tab
      await tester.tap(find.text('ابزارها'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('ابزارها و قابلیت‌های پیشرفته'), findsOneWidget);
    });
  });

  group('Smoke Tests - Speaker Cleaner & Water Eject', () {
    testWidgets('Smoke test: SpeakerCleanerScreen renders and switches modes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: SpeakerCleanerScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Check title and hero
      expect(find.text('پاک‌کننده جرم و آب اسپیکر'), findsOneWidget);
      expect(find.text('شروع عملیات تخلیه و پاک‌سازی'), findsOneWidget);
      expect(find.text('خروج قطرات آب'), findsOneWidget);
      expect(find.text('پاک‌سازی جرم و گرد و خاک'), findsOneWidget);
      expect(find.text('چرخه کامل خودکار'), findsOneWidget);
      expect(find.text('تنظیم فرکانس دستی'), findsOneWidget);

      // Scroll and Tap on Manual Mode to reveal slider
      await tester.scrollUntilVisible(find.text('تنظیم فرکانس دستی'), 100);
      await tester.tap(find.text('تنظیم فرکانس دستی'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('فرکانس صدای خروجی:'), findsOneWidget);

      // Scroll back up and toggle Target Speaker from Main to Earpiece
      await tester.scrollUntilVisible(find.text('اسپیکر مکالمه (بالا)'), -100);
      expect(find.text('اسپیکر مکالمه (بالا)'), findsOneWidget);
      await tester.tap(find.text('اسپیکر مکالمه (بالا)'));
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll to Action Button and Start Cleaning cycle
      await tester.scrollUntilVisible(find.text('شروع عملیات تخلیه و پاک‌سازی'), 100);
      await tester.tap(find.text('شروع عملیات تخلیه و پاک‌سازی'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('توقف پاک‌سازی اسپیکر'), findsOneWidget);

      // Stop Cleaning cycle
      await tester.tap(find.text('توقف پاک‌سازی اسپیکر'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('شروع عملیات تخلیه و پاک‌سازی'), findsOneWidget);
    });

    testWidgets('Smoke test: Speaker cleaner shortcut in HardwareTestsScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: HardwareTestsScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('پاک‌کننده جرم و خروج آب اسپیکر'), findsOneWidget);
      expect(find.text('جدید'), findsOneWidget);
    });
  });

  group('Smoke Tests - Adivery Ads Architecture', () {
    test('AdiveryService singleton and default values', () {
      final service = AdiveryService();
      expect(service.appId, isNotEmpty);
      expect(service.bannerPlacement, isNotEmpty);
      expect(service.interstitialPlacement, isNotEmpty);
      expect(service.rewardedPlacement, isNotEmpty);
      expect(service.canShowInterstitial(), isTrue);
    });

    test('AdiveryService placement update', () {
      final service = AdiveryService();
      service.updatePlacements(
        appId: 'custom-app-123',
        bannerPlacement: 'custom-banner-456',
      );
      expect(service.appId, equals('custom-app-123'));
      expect(service.bannerPlacement, equals('custom-banner-456'));
    });

    testWidgets('Smoke test: AdiveryBannerWidget renders safely in test mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdiveryBannerWidget(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AdiveryBannerWidget), findsOneWidget);
      expect(find.byIcon(Icons.campaign), findsOneWidget);
    });

    testWidgets('Smoke test: AdiveryNativeCard renders safely in test mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdiveryNativeCard(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AdiveryNativeCard), findsOneWidget);
      expect(find.text('پیشنهاد ویژه کاربران فون‌اسکوپ'), findsOneWidget);
      expect(find.text('آگهی'), findsOneWidget);
    });

    testWidgets('Smoke test: SettingsScreen Adivery configuration dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: SettingsScreen(
              onToggleTheme: () {},
              isDark: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('تنظیمات شناسه تبلیغات ادیوری'), findsOneWidget);
      await tester.tap(find.text('تنظیمات شناسه تبلیغات ادیوری'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('مدیریت تبلیغات ادیوری'), findsOneWidget);
      expect(find.text('شناسه اپلیکیشن (App ID)'), findsOneWidget);
      expect(find.text('شناسه بنر (Banner Placement)'), findsOneWidget);
      expect(find.text('شناسه میان‌صفحه‌ای (Interstitial)'), findsOneWidget);
      expect(find.text('شناسه جایزه‌ای (Rewarded)'), findsOneWidget);
    });
  });

  group('Smoke Tests - Legacy & Extreme Device Null-Safety', () {
    test('All domain models handle completely empty maps without crashing', () {
      final sys = SystemInfoModel.fromMap({});
      expect(sys.deviceDisplayName, isNotEmpty);
      expect(sys.apiLevel, equals(0));

      final cpu = CpuInfoModel.fromMap({});
      expect(cpu.coresCount, equals(0));
      expect(cpu.cores, isEmpty);
      expect(cpu.clusters, isEmpty);

      final mem = MemoryInfoModel.fromMap({});
      expect(mem.totalMemBytes, equals(0));
      expect(mem.usedPercentage, equals(0.0));

      final st = StorageInfoModel.fromMap({});
      expect(st.internalTotalBytes, equals(0));
      expect(st.internalUsedPercentage, equals(0.0));

      final bat = BatteryInfoModel.fromMap({});
      expect(bat.level, equals(0.0));
      expect(bat.isCharging, isFalse);

      final therm = ThermalInfoModel.fromMap({});
      expect(therm.thermalStatus, equals('Normal'));
      expect(therm.thermalStatusCode, equals(0));

      final net = NetworkInfoModel.fromMap({});
      expect(net.isConnected, isFalse);
      expect(net.networkType, equals('Disconnected'));
    });
  });
}
