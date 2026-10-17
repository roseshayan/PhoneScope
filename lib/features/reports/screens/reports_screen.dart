import 'package:flutter/material.dart';

import '../services/report_generator_service.dart';
import '../../../core/platform/device_info_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DeviceInfoService _deviceService = DeviceInfoService();
  bool _isGenerating = false;
  String _selectedFormat = 'PDF'; // 'PDF', 'TXT', 'JSON'
  String? _previewText;
  String? _lastGeneratedPath;

  void _generateReport() async {
    setState(() {
      _isGenerating = true;
      _previewText = null;
    });

    try {
      final system = await _deviceService.getSystemInfo();
      final cpu = await _deviceService.getCpuInfo();
      final gpu = await _deviceService.getGpuInfo();
      final memory = await _deviceService.getMemoryInfo();
      final storage = await _deviceService.getStorageInfo();
      final battery = await _deviceService.getBatteryInfo();
      final display = await _deviceService.getDisplayInfo();
      final camera = await _deviceService.getCameraInfo();
      final sensors = await _deviceService.getSensorsList();
      final network = await _deviceService.getNetworkInfo();

      if (_selectedFormat == 'TXT') {
        final txt = ReportGeneratorService.generateTextReport(
          system: system,
          cpu: cpu,
          gpu: gpu,
          memory: memory,
          storage: storage,
          battery: battery,
          display: display,
          camera: camera,
          sensors: sensors,
          network: network,
        );
        final file = await ReportGeneratorService.saveReportFile(
          txt,
          'PhoneScope_Report.txt',
        );
        if (mounted) {
          setState(() {
            _lastGeneratedPath = file.path;
            _previewText = txt;
            _isGenerating = false;
          });
        }
      } else if (_selectedFormat == 'JSON') {
        final jsonStr = ReportGeneratorService.generateJsonReport(
          system: system,
          cpu: cpu,
          gpu: gpu,
          memory: memory,
          storage: storage,
          battery: battery,
          display: display,
          camera: camera,
          sensors: sensors,
          network: network,
        );
        final file = await ReportGeneratorService.saveReportFile(
          jsonStr,
          'PhoneScope_Report.json',
        );
        if (mounted) {
          setState(() {
            _lastGeneratedPath = file.path;
            _previewText = jsonStr;
            _isGenerating = false;
          });
        }
      } else {
        // PDF
        final file = await ReportGeneratorService.generatePdfReportFile(
          system: system,
          cpu: cpu,
          gpu: gpu,
          memory: memory,
          storage: storage,
          battery: battery,
          display: display,
          camera: camera,
        );
        if (mounted) {
          setState(() {
            _lastGeneratedPath = file.path;
            _previewText =
                'سند PDF با موفقیت آماده شد.\nمسیر فایل: ${file.path}\n\nجهت مشاهده یا ارسال برای خریدار یا تعمیرکار، دکمه اشتراک‌گذاری را فشار دهید.';
            _isGenerating = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _previewText = 'خطا در ایجاد گزارش: $e';
        });
      }
    }
  }

  void _shareReport() async {
    if (_lastGeneratedPath == null) return;
    final mime = _selectedFormat == 'PDF'
        ? 'application/pdf'
        : (_selectedFormat == 'JSON' ? 'application/json' : 'text/plain');

    await _deviceService.shareFile(
      _lastGeneratedPath!,
      mimeType: mime,
      title: 'اشتراک‌گذاری گزارش PhoneScope',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مرکز صدور گزارش تشخیصی')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Format Selector Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'انتخاب فرمت خروجی:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFormatChoice(
                        'PDF',
                        'سند رسمی (PDF)',
                        Icons.picture_as_pdf,
                      ),
                      const SizedBox(width: 8),
                      _buildFormatChoice(
                        'TXT',
                        'متن ساده (TXT)',
                        Icons.text_snippet,
                      ),
                      const SizedBox(width: 8),
                      _buildFormatChoice(
                        'JSON',
                        'داده (JSON)',
                        Icons.data_object,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06B6D4),
              foregroundColor: const Color(0xFF0B1120),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _isGenerating ? null : _generateReport,
            icon: _isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.build_circle),
            label: Text(
              _isGenerating ? 'در حال تهیه گزارش...' : 'تولید گزارش دستگاه',
            ),
          ),

          if (_lastGeneratedPath != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                side: const BorderSide(color: Color(0xFF10B981)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _shareReport,
              icon: const Icon(Icons.share),
              label: const Text('اشتراک‌گذاری فایل گزارش'),
            ),
          ],

          if (_previewText != null) ...[
            const SizedBox(height: 20),
            const Text(
              'پیش‌نمایش گزارش:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              constraints: const BoxConstraints(maxHeight: 350),
              child: SingleChildScrollView(
                child: SelectableText(
                  _previewText!,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormatChoice(String format, String label, IconData icon) {
    final isSelected = _selectedFormat == format;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFormat = format),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF06B6D4).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF06B6D4)
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF06B6D4) : Colors.grey,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF06B6D4) : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
