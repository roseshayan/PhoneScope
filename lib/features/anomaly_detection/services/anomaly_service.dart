import '../models/anomaly_model.dart';
import '../../system/models/system_info_model.dart';
import '../../soc/models/cpu_info_model.dart';
import '../../display/models/display_info_model.dart';

class AnomalyService {
  static AnomalyCheckResult performCrossCheck({
    required SystemInfoModel system,
    required CpuInfoModel cpu,
    required DisplayInfoModel display,
  }) {
    final findings = <AnomalyItem>[];
    int passed = 0;
    int warning = 0;
    int suspicious = 0;

    // 1. Root & SU Check
    if (system.isRootedHeuristic) {
      suspicious++;
      findings.add(
        AnomalyItem(
          title: 'ردپای روت یا باینری‌های سیستمی مشکوک',
          description: system.rootCheckDetails.join(' | '),
          severity: AnomalySeverity.suspicious,
          category: 'امنیت و سیستم',
        ),
      );
    } else {
      passed++;
      findings.add(
        const AnomalyItem(
          title: 'بررسی روت و یکپارچگی سیستمی',
          description: 'هیچ فایل اجرایی su یا دسترسی روت بدون مجوز مشاهده نشد.',
          severity: AnomalySeverity.normal,
          category: 'امنیت و سیستم',
        ),
      );
    }

    // 2. Build Tags & Test-Keys Check
    final tags = system.buildTags ?? '';
    if (tags.contains('test-keys')) {
      warning++;
      findings.add(
        const AnomalyItem(
          title: 'امضای ساخت غیررسمی (test-keys)',
          description: 'سیستم‌عامل با کلیدهای آزمایشی کامپایل شده است (احتمال رام سفارشی یا دستکاری شده).',
          severity: AnomalySeverity.warning,
          category: 'سیستم‌عامل',
        ),
      );
    } else {
      passed++;
      findings.add(
        const AnomalyItem(
          title: 'امضای رسمی سیستم‌عامل (release-keys)',
          description: 'سیستم با کلیدهای رسمی تجاری سازنده امضا شده است.',
          severity: AnomalySeverity.normal,
          category: 'سیستم‌عامل',
        ),
      );
    }

    // 3. ABI vs 64-bit Architecture Check
    if (system.is64Bit && system.supported64BitAbis.isEmpty) {
      suspicious++;
      findings.add(
        const AnomalyItem(
          title: 'ناهماهنگی معماری ۶۴ بیتی',
          description: 'پردازه به عنوان ۶۴ بیتی اعلام شده اما هیچ ABI ۶۴ بیتی پشتیبانی نمی‌شود.',
          severity: AnomalySeverity.suspicious,
          category: 'پردازنده و معماری',
        ),
      );
    } else {
      passed++;
      findings.add(
        AnomalyItem(
          title: 'تطبیق معماری و کتابخانه‌های بومی',
          description:
              'سازگاری ABI با پردازنده: ${system.supportedAbis.join(", ")}',
          severity: AnomalySeverity.normal,
          category: 'پردازنده و معماری',
        ),
      );
    }

    // 4. CPU Cores count consistency
    if (cpu.coresCount < 1 || cpu.coresCount > 32) {
      warning++;
      findings.add(
        AnomalyItem(
          title: 'تعداد غیرمعمول هسته‌های پردازنده',
          description:
              'سیستم تعداد ${cpu.coresCount} هسته را گزارش می‌دهد که نامتعارف است.',
          severity: AnomalySeverity.warning,
          category: 'پردازنده',
        ),
      );
    } else {
      passed++;
      findings.add(
        AnomalyItem(
          title: 'تعداد هسته‌های پردازنده',
          description: 'تعداد ${cpu.coresCount} هسته فعال فیزیکی شناسایی شد.',
          severity: AnomalySeverity.normal,
          category: 'پردازنده',
        ),
      );
    }

    // 5. Display Density vs Physical Resolution Ratio
    if (display.physicalWidthPixels > 0 && display.physicalHeightPixels > 0) {
      final ratio = display.physicalHeightPixels / display.physicalWidthPixels;
      if (ratio < 1.0 || ratio > 2.8) {
        warning++;
        findings.add(
          AnomalyItem(
            title: 'نسبت ابعاد نمایشگر نامتعارف',
            description:
                'نسبت طول به عرض $ratio گزارش شده که با استانداردهای موبایل فاصله دارد.',
            severity: AnomalySeverity.warning,
            category: 'نمایشگر',
          ),
        );
      } else {
        passed++;
        findings.add(
          const AnomalyItem(
            title: 'نسبت ابعاد و وضوح صفحه‌نمایش',
            description:
                'رزولوشن فیزیکی و نسبت ابعاد پنل با تراکم پیکسلی مطابقت دارد.',
            severity: AnomalySeverity.normal,
            category: 'نمایشگر',
          ),
        );
      }
    }

    final total = passed + warning + suspicious;
    final summary = suspicious > 0
        ? 'مشاهده موارد مشکوک یا تغییرات سیستمی'
        : (warning > 0
              ? 'هشدارهای جزئی بررسی شود'
              : 'بدون ناهماهنگی مشخص سخت‌افزاری');

    return AnomalyCheckResult(
      totalChecks: total,
      passedChecks: passed,
      warningChecks: warning,
      suspiciousChecks: suspicious,
      findings: findings,
      summaryStatus: summary,
    );
  }
}
