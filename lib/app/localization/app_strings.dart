class AppStrings {
  static bool isPersian = true;

  // Navigation
  static String get appName => isPersian ? 'فون‌اسکوپ' : 'PhoneScope';
  static String get navHome => isPersian ? 'داشبورد' : 'Dashboard';
  static String get navDevice => isPersian ? 'سخت‌افزار' : 'Hardware';
  static String get navMonitor => isPersian ? 'پایش زنده' : 'Monitor';
  static String get navTests => isPersian ? 'تست‌ها' : 'Tests';
  static String get navTools => isPersian ? 'ابزارها' : 'Tools';

  // Common Statuses
  static String get available => isPersian ? 'در دسترس' : 'Available';
  static String get unavailable => isPersian ? 'غیرقابل دسترس' : 'Unavailable';
  static String get restricted =>
      isPersian ? 'محدود شده توسط اندروید' : 'Restricted by Android';
  static String get unknown => isPersian ? 'نامشخص' : 'Unknown';
  static String get notSupported =>
      isPersian ? 'پشتیبانی نمی‌شود' : 'Not Supported';
  static String get loading =>
      isPersian ? 'در حال بارگذاری اطلاعات...' : 'Loading system data...';
  static String get error =>
      isPersian ? 'خطا در دریافت اطلاعات' : 'Error retrieving data';
  static String get retry => isPersian ? 'تلاش مجدد' : 'Retry';
  static String get refresh => isPersian ? 'بروزرسانی' : 'Refresh';
  static String get share => isPersian ? 'اشتراک‌گذاری' : 'Share';
  static String get exportReport => isPersian ? 'خروجی گزارش' : 'Export Report';

  // Dashboard Items
  static String get quickHealthTitle =>
      isPersian ? 'خلاصه وضعیت سیستم' : 'System Overview';
  static String get batteryLevel => isPersian ? 'سطح شارژ' : 'Battery Level';
  static String get batteryTemp => isPersian ? 'دمای باتری' : 'Battery Temp';
  static String get ramUsage => isPersian ? 'مصرف رم' : 'RAM Usage';
  static String get storageUsage =>
      isPersian ? 'فضای ذخیره‌سازی' : 'Storage Usage';
  static String get cpuCores => isPersian ? 'هسته‌های پردازنده' : 'CPU Cores';
  static String get thermalState =>
      isPersian ? 'وضعیت حرارتی' : 'Thermal State';

  // Sections
  static String get systemInfo =>
      isPersian ? 'سیستم‌عامل و ساخت' : 'OS & Build';
  static String get socCpuInfo => isPersian ? 'پردازنده و چیپ‌ست' : 'SoC & CPU';
  static String get gpuInfo => isPersian ? 'گرافیک و رندر' : 'GPU & Graphics';
  static String get memoryStorageInfo =>
      isPersian ? 'رم و حافظه' : 'Memory & Storage';
  static String get batteryInfo =>
      isPersian ? 'باتری و شارژ' : 'Battery & Power';
  static String get displayInfo => isPersian ? 'صفحه‌نمایش' : 'Display';
  static String get cameraInfo => isPersian ? 'دوربین‌ها' : 'Cameras';
  static String get sensorsInfo => isPersian ? 'سنسورها' : 'Sensors';
  static String get networkInfo =>
      isPersian ? 'شبکه و وای‌فای' : 'Network & Wi-Fi';
  static String get appsInfo =>
      isPersian ? 'برنامه‌های نصب‌شده' : 'Installed Apps';
  static String get anomalyTitle =>
      isPersian ? 'بررسی اصالت و سلامت' : 'Authenticity & Health';
  static String get benchmarksTitle => isPersian ? 'بنچمارک‌ها' : 'Benchmarks';
}
