import 'dart:math';

class Formatters {
  static String formatBytes(int? bytes, {bool useBinary = false}) {
    if (bytes == null || bytes <= 0) return '0 B';
    final unit = useBinary ? 1024 : 1000;
    if (bytes < unit) return '$bytes B';
    final exp = (log(bytes) / log(unit)).floor();
    final suffixes = useBinary
        ? ['B', 'KiB', 'MiB', 'GiB', 'TiB']
        : ['B', 'KB', 'MB', 'GB', 'TB'];
    final clampedExp = min(exp, suffixes.length - 1);
    final value = bytes / pow(unit, clampedExp);
    return '${value.toStringAsFixed(value >= 100 ? 0 : 1)} ${suffixes[clampedExp]}';
  }

  static String formatFrequencyKHz(int? kHz) {
    if (kHz == null || kHz <= 0) return 'Unavailable';
    if (kHz >= 1000000) {
      final ghz = kHz / 1000000.0;
      return '${ghz.toStringAsFixed(2)} GHz';
    } else {
      final mhz = kHz / 1000.0;
      return '${mhz.toStringAsFixed(0)} MHz';
    }
  }

  static String formatMilliVolts(int? mv) {
    if (mv == null || mv <= 0) return 'Unavailable';
    final volts = mv / 1000.0;
    return '${volts.toStringAsFixed(2)} V ($mv mV)';
  }

  static String formatMicroAmps(int? ua) {
    if (ua == null || ua == 0) return '0 mA';
    final ma = ua / 1000.0;
    final sign = ma > 0 ? '+' : '';
    return '$sign${ma.toStringAsFixed(1)} mA';
  }

  static String formatTemperature(double? celsius) {
    if (celsius == null) return 'Unavailable';
    return '${celsius.toStringAsFixed(1)} °C';
  }

  static String formatPercentage(double? percent) {
    if (percent == null || percent < 0) return '0%';
    return '${percent.toStringAsFixed(1)}%';
  }

  static String formatUptime(int? millis) {
    if (millis == null || millis <= 0) return 'Unknown';
    final duration = Duration(milliseconds: millis);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days روز');
    if (hours > 0) parts.add('$hours ساعت');
    if (minutes > 0) parts.add('$minutes دقیقه');
    if (parts.isEmpty || seconds > 0) parts.add('$seconds ثانیه');

    return parts.join(' و ');
  }

  static String formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:$s';
  }
}
