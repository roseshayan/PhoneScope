import 'package:flutter_test/flutter_test.dart';
import 'package:phonescope/core/utilities/formatters.dart';
import 'package:phonescope/features/system/models/system_info_model.dart';
import 'package:phonescope/features/soc/models/cpu_info_model.dart';
import 'package:phonescope/features/gpu/models/gpu_info_model.dart';
import 'package:phonescope/features/memory/models/memory_storage_model.dart';
import 'package:phonescope/features/battery/models/battery_info_model.dart';
import 'package:phonescope/features/display/models/display_info_model.dart';
import 'package:phonescope/features/camera/models/camera_info_model.dart';
import 'package:phonescope/features/network/models/network_info_model.dart';
import 'package:phonescope/features/anomaly_detection/services/anomaly_service.dart';
import 'package:phonescope/features/reports/services/report_generator_service.dart';

void main() {
  group('Formatters Unit Tests', () {
    test(
      'formatBytes formats bytes into human readable binary and decimal',
      () {
        expect(Formatters.formatBytes(0), equals('0 B'));
        expect(Formatters.formatBytes(500), equals('500 B'));
        expect(Formatters.formatBytes(1000), equals('1.0 KB'));
        expect(
          Formatters.formatBytes(1024 * 1024, useBinary: true),
          equals('1.0 MiB'),
        );
        expect(
          Formatters.formatBytes(4 * 1024 * 1024 * 1024, useBinary: true),
          equals('4.0 GiB'),
        );
      },
    );

    test('formatFrequencyKHz formats kHz into MHz and GHz correctly', () {
      expect(Formatters.formatFrequencyKHz(null), equals('Unavailable'));
      expect(Formatters.formatFrequencyKHz(0), equals('Unavailable'));
      expect(Formatters.formatFrequencyKHz(1800000), equals('1.80 GHz'));
      expect(Formatters.formatFrequencyKHz(800000), equals('800 MHz'));
    });

    test('formatMilliVolts formats mV to V', () {
      expect(Formatters.formatMilliVolts(null), equals('Unavailable'));
      expect(Formatters.formatMilliVolts(4125), equals('4.13 V (4125 mV)'));
    });

    test('formatMicroAmps handles positive, negative, and zero current', () {
      expect(Formatters.formatMicroAmps(0), equals('0 mA'));
      expect(Formatters.formatMicroAmps(1500000), equals('+1500.0 mA'));
      expect(Formatters.formatMicroAmps(-450000), equals('-450.0 mA'));
    });

    test('formatTemperature returns celsius with degree symbol', () {
      expect(Formatters.formatTemperature(null), equals('Unavailable'));
      expect(Formatters.formatTemperature(32.45), equals('32.5 °C'));
    });

    test('formatUptime handles durations correctly', () {
      const millis = (2 * 86400 + 4 * 3600 + 15 * 60) * 1000;
      final formatted = Formatters.formatUptime(millis);
      expect(formatted, contains('2 روز'));
      expect(formatted, contains('4 ساعت'));
      expect(formatted, contains('15 دقیقه'));
    });
  });

  group('Domain Models & Null-Safety Unit Tests', () {
    test('SystemInfoModel handles null values safely with fallbacks', () {
      final model = SystemInfoModel.fromMap({});
      expect(model.manufacturer, equals('Unknown'));
      expect(model.androidVersion, equals('Unknown'));
      expect(model.apiLevel, equals(0));
      expect(model.is64Bit, isFalse);
      expect(model.isRootedHeuristic, isFalse);
      expect(model.supportedAbis, isEmpty);
    });

    test('MemoryInfoModel calculations of used and percentage', () {
      const total = 8 * 1024 * 1024 * 1024; // 8 GB
      const avail = 2 * 1024 * 1024 * 1024; // 2 GB
      final mem = MemoryInfoModel.fromMap({
        'totalMemBytes': total,
        'availMemBytes': avail,
        'thresholdBytes': 500000000,
        'isLowMemory': false,
      });

      expect(mem.usedMemBytes, equals(6 * 1024 * 1024 * 1024));
      expect(mem.usedPercentage, equals(75.0));
    });

    test('BatteryInfoModel parses from map correctly', () {
      final b = BatteryInfoModel.fromMap({
        'level': 85.5,
        'voltageMv': 4150,
        'temperatureCelsius': 33.2,
        'status': 'Charging',
        'isCharging': true,
        'plugged': 'AC Charger',
        'health': 'Good',
        'technology': 'Li-ion',
      });

      expect(b.level, equals(85.5));
      expect(b.isCharging, isTrue);
      expect(b.health, equals('Good'));
      expect(b.voltageMv, equals(4150));
    });
  });

  group('Anomaly Detection Unit Tests', () {
    test('Detects clean device with normal severity', () {
      final system = SystemInfoModel.fromMap({
        'manufacturer': 'Samsung',
        'model': 'Galaxy S24',
        'device': 'e1q',
        'is64Bit': true,
        'supported64BitAbis': ['arm64-v8a'],
        'supportedAbis': ['arm64-v8a'],
        'buildTags': 'release-keys',
        'isRootedHeuristic': false,
      });
      final cpu = CpuInfoModel.fromMap({
        'coresCount': 8,
        'architecture': 'aarch64',
        'abi': 'arm64-v8a',
        'cores': [],
        'clusters': [],
        'procCpuInfoAccessible': true,
      });
      final display = DisplayInfoModel.fromMap({
        'physicalWidthPixels': 1080,
        'physicalHeightPixels': 2340,
        'density': 2.625,
        'densityDpi': 420,
      });

      final result = AnomalyService.performCrossCheck(
        system: system,
        cpu: cpu,
        display: display,
      );
      expect(result.suspiciousChecks, equals(0));
      expect(result.summaryStatus, contains('بدون ناهماهنگی مشخص'));
    });

    test('Flags root and test-keys as warning and suspicious', () {
      final system = SystemInfoModel.fromMap({
        'manufacturer': 'FakeBrand',
        'model': 'FakeModel',
        'is64Bit': true,
        'supported64BitAbis': <String>[], // 64-bit with no 64-bit ABI!
        'buildTags': 'test-keys', // test-keys!
        'isRootedHeuristic': true, // Rooted!
        'rootCheckDetails': ['SU binary found at /system/xbin/su'],
      });
      final cpu = CpuInfoModel.fromMap({
        'coresCount': 40, // 40 cores is abnormal!
        'architecture': 'armv7l',
        'abi': 'armeabi-v7a',
        'cores': [],
        'clusters': [],
        'procCpuInfoAccessible': false,
      });
      final display = DisplayInfoModel.fromMap({
        'physicalWidthPixels': 100,
        'physicalHeightPixels': 1000,
      });

      final result = AnomalyService.performCrossCheck(
        system: system,
        cpu: cpu,
        display: display,
      );
      expect(result.suspiciousChecks, greaterThan(0));
      expect(result.warningChecks, greaterThan(0));
      expect(result.summaryStatus, contains('مشکوک'));
    });
  });

  group('Diagnostic Reports Unit Tests', () {
    test('generateTextReport contains expected device parameters', () {
      final system = SystemInfoModel.fromMap({
        'manufacturer': 'Google',
        'model': 'Pixel 8',
        'device': 'shiba',
        'androidVersion': '15',
        'apiLevel': 35,
        'securityPatch': '2026-10-01',
      });
      final cpu = CpuInfoModel.fromMap({
        'coresCount': 9,
        'architecture': 'arm64',
        'abi': 'arm64-v8a',
      });
      final gpu = GpuInfoModel.fromMap({
        'renderer': 'Mali-G715',
        'vendor': 'ARM',
        'version': 'OpenGL ES 3.2',
      });
      final mem = MemoryInfoModel.fromMap({
        'totalMemBytes': 8000000000,
        'availMemBytes': 4000000000,
      });
      final storage = StorageInfoModel.fromMap({
        'internalTotalBytes': 128000000000,
        'internalAvailableBytes': 64000000000,
      });
      final battery = BatteryInfoModel.fromMap({
        'level': 90.0,
        'status': 'Discharging',
        'voltageMv': 4100,
        'temperatureCelsius': 29.5,
        'health': 'Good',
      });
      final display = DisplayInfoModel.fromMap({
        'physicalWidthPixels': 1080,
        'physicalHeightPixels': 2400,
        'densityDpi': 428,
        'currentRefreshRate': 120.0,
      });
      final camera = CameraInfoModel.fromMap({
        'camerasCount': 2,
        'cameras': [],
      });
      final network = NetworkInfoModel.fromMap({
        'isConnected': true,
        'networkType': 'Wi-Fi',
        'isWifi': true,
        'wifiSsid': 'HomeNet',
      });

      final text = ReportGeneratorService.generateTextReport(
        system: system,
        cpu: cpu,
        gpu: gpu,
        memory: mem,
        storage: storage,
        battery: battery,
        display: display,
        camera: camera,
        sensors: [],
        network: network,
      );

      expect(text, contains('گزارش جامع تشخیصی سخت‌افزار PhoneScope'));
      expect(text, contains('Google Pixel 8'));
      expect(text, contains('Android 15'));
      expect(text, contains('Mali-G715'));
      expect(text, contains('HomeNet'));
    });

    test('generateJsonReport outputs valid structured JSON', () {
      final system = SystemInfoModel.fromMap({
        'manufacturer': 'Google',
        'model': 'Pixel 8',
      });
      final cpu = CpuInfoModel.fromMap({'coresCount': 9});
      final gpu = GpuInfoModel.fromMap({'renderer': 'Mali'});
      final mem = MemoryInfoModel.fromMap({'totalMemBytes': 1000});
      final storage = StorageInfoModel.fromMap({'internalTotalBytes': 2000});
      final battery = BatteryInfoModel.fromMap({'level': 100.0});
      final display = DisplayInfoModel.fromMap({'physicalWidthPixels': 1080});
      final camera = CameraInfoModel.fromMap({'camerasCount': 1});
      final network = NetworkInfoModel.fromMap({'isConnected': true});

      final json = ReportGeneratorService.generateJsonReport(
        system: system,
        cpu: cpu,
        gpu: gpu,
        memory: mem,
        storage: storage,
        battery: battery,
        display: display,
        camera: camera,
        sensors: [],
        network: network,
      );

      expect(json, contains('"generator": "PhoneScope Hardware Diagnostics"'));
      expect(json, contains('"manufacturer": "Google"'));
    });
  });
}
