import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../system/models/system_info_model.dart';
import '../../soc/models/cpu_info_model.dart';
import '../../gpu/models/gpu_info_model.dart';
import '../../memory/models/memory_storage_model.dart';
import '../../battery/models/battery_info_model.dart';
import '../../display/models/display_info_model.dart';
import '../../camera/models/camera_info_model.dart';
import '../../sensors/models/sensor_info_model.dart';
import '../../network/models/network_info_model.dart';
import '../../../core/utilities/formatters.dart';

class ReportGeneratorService {
  static String generateTextReport({
    required SystemInfoModel system,
    required CpuInfoModel cpu,
    required GpuInfoModel gpu,
    required MemoryInfoModel memory,
    required StorageInfoModel storage,
    required BatteryInfoModel battery,
    required DisplayInfoModel display,
    required CameraInfoModel camera,
    required List<SensorInfoModel> sensors,
    required NetworkInfoModel network,
  }) {
    final buffer = StringBuffer();
    final now = DateTime.now();

    buffer.writeln('======================================================');
    buffer.writeln('          گزارش جامع تشخیصی سخت‌افزار PhoneScope       ');
    buffer.writeln('======================================================');
    buffer.writeln('تاریخ تهیه گزارش: ${Formatters.formatDateTime(now)}');
    buffer.writeln(
      'نام دستگاه: ${system.manufacturer} ${system.model} (${system.device})',
    );
    buffer.writeln(
      'سیستم‌عامل: Android ${system.androidVersion} (API ${system.apiLevel})',
    );
    buffer.writeln('وصله امنیتی: ${system.securityPatch}');
    buffer.writeln('اثر انگشت ساخت: ${system.fingerprint}');
    buffer.writeln(
      'وضعیت روت (اکتشافی): ${system.isRootedHeuristic ? "ردپای مشکوک روت مشاهده شد" : "عادی (بدون دسترسی روت)"}',
    );
    buffer.writeln('------------------------------------------------------\n');

    buffer.writeln('[۱. مشخصات پردازنده و چیپ‌ست (SoC & CPU)]');
    buffer.writeln('تعداد هسته‌ها: ${cpu.coresCount}');
    buffer.writeln('معماری: ${cpu.architecture} (${cpu.abi})');
    buffer.writeln('مدل پردازنده: ${system.socModel}');
    for (final cluster in cpu.clusters) {
      buffer.writeln(
        '  - ${cluster.clusterName}: هسته‌های ${cluster.cores.join(", ")} | بیشینه فرکانس: ${Formatters.formatFrequencyKHz(cluster.maxFreqKHz)}',
      );
    }
    buffer.writeln('------------------------------------------------------\n');

    buffer.writeln('[۲. پردازنده گرافیکی (GPU)]');
    buffer.writeln('رندر گرافیک: ${gpu.renderer}');
    buffer.writeln('فروشنده: ${gpu.vendor}');
    buffer.writeln('نسخه OpenGL ES: ${gpu.version}');
    buffer.writeln('پشتیبانی از Vulkan: ${gpu.hasVulkan ? "بله" : "خیر"}');
    buffer.writeln('تعداد Extensionها: ${gpu.extensionsCount}');
    buffer.writeln('------------------------------------------------------\n');

    buffer.writeln('[۳. وضعیت حافظه رم و ذخیره‌سازی]');
    buffer.writeln(
      'کل حافظه رم: ${Formatters.formatBytes(memory.totalMemBytes)}',
    );
    buffer.writeln(
      'رم در دسترس: ${Formatters.formatBytes(memory.availMemBytes)}',
    );
    buffer.writeln('مصرف رم: ${memory.usedPercentage.toStringAsFixed(1)}%');
    buffer.writeln(
      'کل فضای داخلی: ${Formatters.formatBytes(storage.internalTotalBytes)}',
    );
    buffer.writeln(
      'فضای آزاد داخلی: ${Formatters.formatBytes(storage.internalAvailableBytes)}',
    );
    buffer.writeln('------------------------------------------------------\n');

    buffer.writeln('[۴. باتری و تغذیه]');
    buffer.writeln('سطح شارژ: ${battery.level.toStringAsFixed(1)}%');
    buffer.writeln('وضعیت: ${battery.status} (${battery.plugged})');
    buffer.writeln('ولتاژ: ${Formatters.formatMilliVolts(battery.voltageMv)}');
    buffer.writeln(
      'دما: ${Formatters.formatTemperature(battery.temperatureCelsius)}',
    );
    buffer.writeln('سلامت گزارش‌شده: ${battery.health}');
    buffer.writeln('فناوری: ${battery.technology}');
    buffer.writeln('------------------------------------------------------\n');

    buffer.writeln('[۵. صفحه‌نمایش]');
    buffer.writeln(
      'رزولوشن فیزیکی: ${display.physicalWidthPixels} x ${display.physicalHeightPixels}',
    );
    buffer.writeln('تراکم پیکسل: ${display.densityDpi} DPI');
    buffer.writeln('اندازه تخمینی قطر: ${display.diagonalInches} اینچ');
    buffer.writeln(
      'نرخ نوسازی: ${display.currentRefreshRate.toStringAsFixed(0)} Hz',
    );
    buffer.writeln(
      'پشتیبانی HDR: ${display.isHdrSupported ? display.hdrTypes.join(", ") : "خیر"}',
    );
    buffer.writeln('------------------------------------------------------\n');

    buffer.writeln('[۶. دوربین‌ها]');
    buffer.writeln('تعداد لنزهای شناسایی‌شده: ${camera.camerasCount}');
    for (final c in camera.cameras) {
      buffer.writeln(
        '  - شناسه ${c.id}: ${c.facing} | ${c.megapixels} MP | سطح سخت‌افزاری: ${c.hardwareLevel} | دیافراگم: ${c.apertures.join(", ")}',
      );
    }
    buffer.writeln('------------------------------------------------------\n');

    buffer.writeln('[۷. سنسورها]');
    buffer.writeln('تعداد سنسورهای فیزیکی و نرم‌افزاری: ${sensors.length}');
    for (final s in sensors.take(15)) {
      buffer.writeln('  - ${s.name} (${s.vendor}) - حالت: ${s.reportingMode}');
    }
    if (sensors.length > 15) {
      buffer.writeln('  ... و ${sensors.length - 15} سنسور دیگر');
    }
    buffer.writeln('------------------------------------------------------\n');

    buffer.writeln('[۸. شبکه و ارتباطات]');
    buffer.writeln(
      'وضعیت اتصال: ${network.isConnected ? "متصل" : "قطع"} (${network.networkType})',
    );
    if (network.isWifi) {
      buffer.writeln('نام وای‌فای: ${network.wifiSsid}');
      buffer.writeln(
        'سرعت لینک: ${network.linkSpeedMbps} Mbps | سیگنال: ${network.rssiDbm} dBm',
      );
      buffer.writeln(
        'استاندارد: ${network.wifiStandard} (${network.frequencyBand})',
      );
    }
    buffer.writeln('IP محلی: ${network.localIpv4}');
    buffer.writeln('------------------------------------------------------\n');

    buffer.writeln(
      'این گزارش به صورت کاملاً آفلاین توسط اپلیکیشن PhoneScope تولید شده است.',
    );
    return buffer.toString();
  }

  static String generateJsonReport({
    required SystemInfoModel system,
    required CpuInfoModel cpu,
    required GpuInfoModel gpu,
    required MemoryInfoModel memory,
    required StorageInfoModel storage,
    required BatteryInfoModel battery,
    required DisplayInfoModel display,
    required CameraInfoModel camera,
    required List<SensorInfoModel> sensors,
    required NetworkInfoModel network,
  }) {
    final map = {
      'reportInfo': {
        'generator': 'PhoneScope Hardware Diagnostics',
        'generatedAt': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
      },
      'system': system.toMap(),
      'cpu': cpu.toMap(),
      'gpu': gpu.toMap(),
      'memory': memory.toMap(),
      'storage': storage.toMap(),
      'battery': battery.toMap(),
      'display': display.toMap(),
      'camera': camera.toMap(),
      'sensors': sensors.map((s) => s.toMap()).toList(),
      'network': network.toMap(),
    };

    return const JsonEncoder.withIndent('  ').convert(map);
  }

  static Future<File> saveReportFile(String content, String fileName) async {
    final cacheDir = await getTemporaryDirectory();
    final reportsDir = Directory('${cacheDir.path}/reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    final file = File('${reportsDir.path}/$fileName');
    return await file.writeAsString(content, encoding: utf8);
  }

  static Future<File> generatePdfReportFile({
    required SystemInfoModel system,
    required CpuInfoModel cpu,
    required GpuInfoModel gpu,
    required MemoryInfoModel memory,
    required StorageInfoModel storage,
    required BatteryInfoModel battery,
    required DisplayInfoModel display,
    required CameraInfoModel camera,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'PhoneScope Diagnostics Report',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    Formatters.formatDateTime(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Device: ${system.manufacturer} ${system.model} (${system.device})',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Android Version: ${system.androidVersion} (API ${system.apiLevel}) | Security Patch: ${system.securityPatch}',
            ),
            pw.Text(
              'Build Fingerprint: ${system.fingerprint}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
            pw.Divider(thickness: 1),

            pw.SizedBox(height: 10),
            pw.Text(
              '1. Processor & SoC',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.Bullet(
              text:
                  'Cores: ${cpu.coresCount} | Architecture: ${cpu.architecture} (${cpu.abi})',
            ),
            pw.Bullet(text: 'SoC Model: ${system.socModel}'),

            pw.SizedBox(height: 10),
            pw.Text(
              '2. Graphics (GPU)',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.Bullet(text: 'Renderer: ${gpu.renderer}'),
            pw.Bullet(text: 'Vendor: ${gpu.vendor} | OpenGL: ${gpu.version}'),
            pw.Bullet(text: 'Vulkan Support: ${gpu.hasVulkan ? "Yes" : "No"}'),

            pw.SizedBox(height: 10),
            pw.Text(
              '3. Memory & Storage',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.Bullet(
              text:
                  'Total RAM: ${Formatters.formatBytes(memory.totalMemBytes)} | Available: ${Formatters.formatBytes(memory.availMemBytes)} (${memory.usedPercentage.toStringAsFixed(1)}% Used)',
            ),
            pw.Bullet(
              text:
                  'Internal Storage: ${Formatters.formatBytes(storage.internalTotalBytes)} | Free: ${Formatters.formatBytes(storage.internalAvailableBytes)}',
            ),

            pw.SizedBox(height: 10),
            pw.Text(
              '4. Battery & Power',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.Bullet(
              text:
                  'Level: ${battery.level.toStringAsFixed(1)}% | Status: ${battery.status} (${battery.plugged})',
            ),
            pw.Bullet(
              text:
                  'Voltage: ${Formatters.formatMilliVolts(battery.voltageMv)} | Temperature: ${Formatters.formatTemperature(battery.temperatureCelsius)}',
            ),
            pw.Bullet(
              text:
                  'Health: ${battery.health} | Technology: ${battery.technology}',
            ),

            pw.SizedBox(height: 10),
            pw.Text(
              '5. Display',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.Bullet(
              text:
                  'Resolution: ${display.physicalWidthPixels} x ${display.physicalHeightPixels} (${display.densityDpi} DPI)',
            ),
            pw.Bullet(
              text:
                  'Refresh Rate: ${display.currentRefreshRate.toStringAsFixed(0)} Hz | HDR: ${display.isHdrSupported ? "Yes" : "No"}',
            ),

            pw.SizedBox(height: 10),
            pw.Text(
              '6. Cameras',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.Bullet(text: 'Total Cameras: ${camera.camerasCount}'),
            for (final c in camera.cameras)
              pw.Bullet(
                text:
                    'Camera ID ${c.id}: ${c.facing} - ${c.megapixels} MP (Hardware: ${c.hardwareLevel})',
              ),

            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Text(
              'Generated offline on device using PhoneScope - Verified Hardware Diagnostics',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ];
        },
      ),
    );

    final cacheDir = await getTemporaryDirectory();
    final reportsDir = Directory('${cacheDir.path}/reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    final file = File('${reportsDir.path}/PhoneScope_Report.pdf');
    final bytes = await pdf.save();
    return await file.writeAsBytes(bytes);
  }
}
