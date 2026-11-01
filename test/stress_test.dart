import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phonescope/main.dart';
import 'package:phonescope/features/system/models/system_info_model.dart';
import 'package:phonescope/features/soc/models/cpu_info_model.dart';
import 'package:phonescope/features/gpu/models/gpu_info_model.dart';
import 'package:phonescope/features/memory/models/memory_storage_model.dart';
import 'package:phonescope/features/battery/models/battery_info_model.dart';
import 'package:phonescope/features/display/models/display_info_model.dart';
import 'package:phonescope/features/camera/models/camera_info_model.dart';
import 'package:phonescope/features/network/models/network_info_model.dart';
import 'package:phonescope/features/sensors/models/sensor_info_model.dart';
import 'package:phonescope/features/benchmarks/services/benchmark_service.dart';
import 'package:phonescope/features/anomaly_detection/services/anomaly_service.dart';
import 'package:phonescope/features/reports/services/report_generator_service.dart';
import 'package:phonescope/features/hardware_tests/screens/speaker_cleaner_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Stress Tests - High Load & Stability', () {
    // 1. Rapid UI Tab Switching Stress
    testWidgets('Stress test 1: Rapid 50x bottom navigation tab switching', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PhoneScopeApp());
      await tester.pump(const Duration(milliseconds: 300));

      final tabs = ['داشبورد', 'سخت‌افزار', 'پایش زنده', 'تست‌ها', 'ابزارها'];

      for (int i = 0; i < 50; i++) {
        final targetTab = tabs[i % tabs.length];
        await tester.tap(find.text(targetTab));
        await tester.pump(const Duration(milliseconds: 20));
      }

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    // 2. High-Volume Model Deserialization Stress (1,000 iterations)
    test('Stress test 2: 1,000 concurrent domain models deserialization', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        final mockSys = SystemInfoModel.fromMap({
          'manufacturer': 'Manufacturer_$i',
          'brand': 'Brand_$i',
          'model': 'Model_$i',
          'device': 'device_$i',
          'product': 'product_$i',
          'board': 'board_$i',
          'hardware': 'qcom',
          'androidVersion': '14',
          'apiLevel': 34,
          'securityPatch': '2026-05-01',
          'buildId': 'UKQ1.$i',
          'fingerprint': 'brand/model/device:14/UKQ1/user:release-keys',
          'bootloader': 'unknown',
          'supportedAbis': ['arm64-v8a', 'armeabi-v7a'],
          'is64Bit': true,
          'kernelVersion': '5.15.0-android14',
          'uptimeMillis': 86400000 + i * 1000,
          'isRootedHeuristic': i % 10 == 0,
        });
        expect(mockSys.is64Bit, isTrue);

        final mockBat = BatteryInfoModel.fromMap({
          'level': (i % 100).toDouble(),
          'voltageMv': 3800 + (i % 500),
          'temperatureCelsius': 28.0 + (i % 20),
          'status': i % 2 == 0 ? 'Charging' : 'Discharging',
          'isCharging': i % 2 == 0,
          'health': 'Good',
        });
        expect(mockBat.level, equals((i % 100).toDouble()));

        final mockCpu = CpuInfoModel.fromMap({
          'coresCount': 8,
          'architecture': 'aarch64',
          'abi': 'arm64-v8a',
          'cores': List.generate(8, (c) => {
            'coreIndex': c,
            'curFreqKHz': 1800000 + (c * 100000),
            'maxFreqKHz': 2800000,
          }),
        });
        expect(mockCpu.coresCount, equals(8));

        final mockMem = MemoryInfoModel.fromMap({
          'totalMemBytes': 8589934592,
          'availMemBytes': 3221225472,
          'thresholdBytes': 500000000,
          'isLowMemory': false,
        });
        expect(mockMem.usedPercentage, greaterThan(0));

        final mockDisplay = DisplayInfoModel.fromMap({
          'physicalWidthPixels': 1080,
          'physicalHeightPixels': 2400,
          'density': 2.75,
          'densityDpi': 440,
          'currentRefreshRate': 120.0,
          'supportedRefreshRates': [60.0, 90.0, 120.0],
          'isHdrSupported': true,
          'hdrTypes': ['HDR10', 'Dolby Vision'],
        });
        expect(mockDisplay.currentRefreshRate, equals(120.0));
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    // 3. Mathematical Benchmark Engine Stress Test
    test('Stress test 3: Intensive Sieve & Matrix Multi-Core Benchmark loop', () async {
      final singleResult = await BenchmarkService.runSingleCoreCpu(
        deviceModel: 'StressTester-Device',
      );
      expect(singleResult.score, greaterThan(0));
      expect(singleResult.executionTimeMs, greaterThan(0));

      final multiResult = await BenchmarkService.runMultiCoreCpu(
        coresCount: 4,
        deviceModel: 'StressTester-Device',
      );
      expect(multiResult.score, greaterThan(0));
      expect(multiResult.metrics['coresUtilized'], equals(4));
    });

    // 4. High-Frequency Sensor Stream Flood (10,000 events)
    test('Stress test 4: 10,000 high-frequency sensor events flood processing', () {
      final random = Random(42);
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 10000; i++) {
        final mockEvent = SensorEventData.fromMap({
          'sensorType': 1, // TYPE_ACCELEROMETER
          'accuracy': 3,
          'timestamp': DateTime.now().microsecondsSinceEpoch,
          'values': [
            random.nextDouble() * 19.6 - 9.8,
            random.nextDouble() * 19.6 - 9.8,
            random.nextDouble() * 19.6 - 9.8,
          ],
        });

        expect(mockEvent.sensorType, equals(1));
        expect(mockEvent.values.length, equals(3));
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    // 5. Anomaly Detection Engine Extreme Input Stress
    test('Stress test 5: 200 extreme device configurations in Anomaly Engine', () {
      final random = Random(123);

      for (int i = 0; i < 200; i++) {
        final isRooted = i % 2 == 0;
        final sys = SystemInfoModel(
          manufacturer: i % 3 == 0 ? 'Samsung' : 'Google',
          brand: 'Brand',
          model: 'Model_$i',
          device: 'device',
          product: 'product',
          board: 'board',
          hardware: 'hardware',
          androidVersion: '${10 + (i % 6)}',
          apiLevel: 29 + (i % 6),
          securityPatch: i % 5 == 0 ? '2019-01-01' : '2026-06-01',
          buildId: 'ID_$i',
          fingerprint: i % 4 == 0 ? 'test-keys' : 'release-keys',
          bootloader: 'locked',
          supportedAbis: ['arm64-v8a'],
          supported32BitAbis: [],
          supported64BitAbis: ['arm64-v8a'],
          is64Bit: true,
          kernelVersion: 'kernel',
          socModel: 'soc',
          socManufacturer: 'mfg',
          buildType: i % 4 == 0 ? 'userdebug' : 'user',
          buildTags: i % 4 == 0 ? 'test-keys' : 'release-keys',
          uptimeMillis: random.nextInt(100000000),
          isRootedHeuristic: isRooted,
          rootCheckDetails: isRooted ? ['su binary found'] : [],
        );

        final cpu = CpuInfoModel.fromMap({});
        final display = DisplayInfoModel.fromMap({});

        final result = AnomalyService.performCrossCheck(
          system: sys,
          cpu: cpu,
          display: display,
        );

        expect(result.summaryStatus, isNotNull);
        expect(result.findings, isNotNull);
      }
    });

    // 6. Diagnostic Reports Generation Stress
    test('Stress test 6: 100 consecutive structured PDF/JSON/Text reports generation', () {
      final sys = SystemInfoModel.fromMap({});
      final cpu = CpuInfoModel.fromMap({});
      final gpu = GpuInfoModel.fromMap({});
      final mem = MemoryInfoModel.fromMap({});
      final st = StorageInfoModel.fromMap({});
      final bat = BatteryInfoModel.fromMap({});
      final dis = DisplayInfoModel.fromMap({});
      final cam = CameraInfoModel.fromMap({});
      final net = NetworkInfoModel.fromMap({});

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        final textReport = ReportGeneratorService.generateTextReport(
          system: sys,
          cpu: cpu,
          gpu: gpu,
          memory: mem,
          storage: st,
          battery: bat,
          display: dis,
          camera: cam,
          network: net,
          sensors: const [],
        );
        expect(textReport.length, greaterThan(100));

        final jsonReport = ReportGeneratorService.generateJsonReport(
          system: sys,
          cpu: cpu,
          gpu: gpu,
          memory: mem,
          storage: st,
          battery: bat,
          display: dis,
          camera: cam,
          network: net,
          sensors: const [],
        );
        expect(jsonReport.length, greaterThan(100));
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1200));
    });

    // 7. Speaker Cleaner State Machine Rapid Cycling
    testWidgets('Stress test 7: Rapid 30x speaker cleaner mode and state cycling', (
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

      // Rapidly toggle target speaker 30 times
      for (int i = 0; i < 30; i++) {
        final targetText = i % 2 == 0 ? 'اسپیکر مکالمه (بالا)' : 'بلندگوی اصلی (پایین)';
        await tester.tap(find.text(targetText));
        await tester.pump(const Duration(milliseconds: 10));
      }

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('پاک‌کننده جرم و آب اسپیکر'), findsOneWidget);
    });
  });
}
