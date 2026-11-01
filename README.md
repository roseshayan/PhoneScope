# 📱 PhoneScope (فون‌اسکوپ)

<div align="center">

<img src="assets/icons/phonescope_logo.png" alt="PhoneScope Logo" width="140" height="140" style="border-radius: 28px;" />

### ابزار جامع و حرفه‌ای پایش سخت‌افزار، پاک‌کننده اسپیکر، تست سلامت قطعات، بنچمارک و گزارش‌گیری اندروید
### Professional Android Hardware Diagnostics, Speaker Cleaner, Benchmarking & System Monitor

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.1.0-7F52FF?logo=kotlin&logoColor=white)](https://kotlinlang.org)
[![Android](https://img.shields.io/badge/Android-7.0%2B%20(API%2024--35)-3DDC84?logo=android&logoColor=white)](https://developer.android.com)
[![Adivery Ads](https://img.shields.io/badge/Adivery-4.9.0-orange?logo=google-ads&logoColor=white)](https://adivery.com)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Platform%20Channels-blueviolet)](#)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

[**توضیحات فارسی**](#-درباره-برنامه-فارسی) • [**English Description**](#-about-phonescope-english) • [**ویژگی‌ها**](#-قابلیت‌های-کلیدی) • [**معماری**](#-معماری-پروژه) • [**نصب و اجرا**](#-راهنمای-بیلد-و-اجرا) • [**توسعه‌دهنده**](#-توسعهدهنده--developer)

</div>

---

## 📖 درباره برنامه (فارسی)

**PhoneScope (فون‌اسکوپ)** یک اپلیکیشن بومی، مهندسی‌شده و فوق‌العاده پایدار برای اندروید است که برای شناسایی دقیق مشخصات فنی سخت‌افزار، مانیتورینگ لحظه‌ای منابع، تخلیه آب و پاک‌سازی جرم اسپیکر، تست قطعات فیزیکی، بنچمارک استاندارد و تهیه گزارش تشخیصی توسعه یافته است.

برخلاف برنامه‌های متداول که صرفاً داده‌های شبیه‌سازی‌شده یا استاتیک نمایش می‌دهند، PhoneScope بر پایه **صداقت کامل در نمایش داده‌ها** طراحی شده است؛ به این معنا که تمامی پارامترها مستقیماً از سنسورها، کرنل لینوکس و فریم‌ورک اندروید استخراج می‌شوند و سازگاری کامل با تمامی دستگاه‌های جدید (Android 14 و 15، API 34 و 35) و دستگاه‌های قدیمی‌تر (تا Android 7.0 Nougat) تضمین شده است.

این ابزار برای **کاربران عمومی، خریداران گوشی کارکرده/دست‌دوم، تعمیرکاران موبایل و توسعه‌دهندگان** انتخابی ایده‌آل است.

---

## 🌐 About PhoneScope (English)

**PhoneScope** is a production-grade, enterprise-quality Android hardware diagnostics, benchmarking, speaker cleaning, and real-time system monitoring tool built with Flutter and Native Kotlin. It provides an honest, in-depth look under the hood of any Android device (supporting Android 7.0 Nougat through Android 15, API levels 24 to 35).

### Core Pillars
- **Data Authenticity Guarantee:** Every frequency, temperature, sensor event, and battery metric reflects real hardware readings. No mock graphs or fake values.
- **Extreme Device Compatibility:** Null-safe architecture with automated fallback handlers for low-end, custom ROM, or older Android devices.
- **Enterprise Clean Architecture:** Robust separation of concerns (Views, ViewModels, Repositories, and Native Platform Services).
- **Integrated Adivery Monetization:** Fully compliant Iranian ad network integration with rate-limiting, test mode fallbacks, and zero-impact UI stability.

---

## ✨ قابلیت‌های کلیدی

### ۱. پایش و مشخصات جامع قطعات
- **تراشه و پردازنده (SoC & CPU):** شناسایی مدل دقیق چیپست، فرکانس زنده تک‌تک هسته‌ها، دسته‌بندی خوشه‌ای (big.LITTLE / Prime) و دستورالعمل‌های ABI.
- **پردازنده گرافیکی (GPU):** شناسایی `GL_RENDERER`، `GL_VENDOR`، نسخه OpenGL ES و اکستنشن‌های سخت‌افزاری از طریق ساخت Headless EGL Context اختصاصی در کدهای نیتیو.
- **حافظه و فضای ذخیره‌سازی (RAM & Storage):** درصد مصرف زنده رم با `ActivityManager.MemoryInfo`، حافظه تخصیص‌یافته به اپلیکیشن و حجم کل/آزاد پارتیشن‌ها با `StatFs`.
- **باتری و شارژ (Battery):** جریان لحظه‌ای بر حسب میلی‌آمپر (mA)، ولتاژ بر حسب میلی‌ولت (mV)، دمای سلول، وضعیت سلامت و تکنولوژی ساخت از طریق استریم زنده `EventChannel`.
- **وضعیت حرارتی (Thermal Monitor):** پایش وضعیت تراتلینگ پردازنده (Throttling) و Thermal Headroom با `PowerManager`.
- **صفحه‌نمایش (Display):** رزولوشن فیزیکی و منطقی، نرخ نوسازی (Hz)، تراکم پیکسلی (DPI)، استانداردهای HDR و وسعت رنگ (Wide Color Gamut).
- **دوربین‌ها (Camera):** استخراج مشخصات لنزها از طریق Camera2 API (مگاپیکسل واقعی، گشودگی دیافراگم، فاصله کانونی، لرزشگیر اپتیکال OIS و بازه ISO).
- **سنسورها (Sensors):** فهرست جامع کلیه سنسورهای فیزیکی به همراه مانیتورینگ زنده زاویه و شتاب با لغو خودکار لیسنرها جهت حفظ باتری.
- **شبکه و ارتباطات (Network & Wi-Fi):** تشخیص سیگنال RSSI، استاندارد شبکه (Wi-Fi 4/5/6/7)، فرکانس باند (2.4/5/6GHz) و IPv4 محلی.
- **برنامه‌های نصب‌شده (Installed Apps):** بررسی پکیج‌ها، Target SDK، حجم و مجوزهای اعلام‌شده با جلوگیری از خطای `TransactionTooLargeException`.

### ۲. جعبه‌ابزار تست سخت‌افزار و پاک‌کننده اسپیکر
- **🌊 پاک‌کننده جرم و خروج آب اسپیکر (جدید!):**
  - تولید فرکانس صوتی رزونانس دیافراگم (۱۶۵ هرتز) با بیشترین دامنه جابه‌جایی فیزیکی هوا جهت تخلیه قطرات آب.
  - پالس‌های شوک مکانیکی با فرکانس‌های ۲۶۰ تا ۸۸۰ هرتز برای پاکسازی جرم و غبار از توری بلندگو.
  - پشتیبانی از هر دو بلندگو: بلندگوی اصلی پایین (Loudspeaker) و اسپیکر مکالمه بالا (Earpiece) با تغییر داینامیک مسیر صوتی در لایه نیتیو اندروید.
  - ارتعاش مکانیکی هپتیک همگام (Haptic Sync) با موتور لرزش دستگاه.
  - تنظیم دستی فرکانس از ۵۰ تا ۱۲۰۰ هرتز با اسلایدر دقیق.
- **تست پیکسل سوخته (Screen Dead-Pixel Test):** چرخه ۵ رنگ تمام‌صفحه با مخفی‌سازی نوارهای سیستم برای کشف هاله، برن‌این و پیکسل‌های مرده.
- **تست تاچ چندگانه (Multi-touch Matrix):** تست هم‌زمان نقاط لمس، نمایش مختصات لحظه‌ای و سنجش پاسخگویی تاچ.
- **تست بلندگو و میکروفون (Audio & Mic Test):** تولید موج صوتی فرکانس خالص (Pure Sine Wave) و سنجش دامنه صدای میکروفون با تحلیلگر RMS زنده.
- **تست لرزش (Vibration Patterns):** اجرای الگوهای ویبره کوتاه، دوبل و کد مورس SOS با `VibrationEffect`.
- **تست فلاش دوربین (Torch Test):** سوئیچ سریع فلاش LED پشت دستگاه.

### ۳. ماژول بنچمارک استاندارد (Transparent Benchmarking)
- **بنچمارک تک‌هسته‌ای و چندهسته‌ای CPU:** اجرای موازی محاسبات سنگین با الگوریتم غربال اعداد اول و هشینگ SHA-256 در بستر چندرشته‌ای `Isolate`های دارت بدون فریز شدن UI.
- **بنچمارک سرعت خواندن و نوشتن حافظه داخلی:** تست ترتیبی I/O با تولید بلاک ۱۶ مگابایتی و پاکسازی کامل داده‌های موقت پس از اتمام بنچمارک.

### ۴. ابزارهای تکمیلی و خروجی
- **چک‌لیست خرید گوشی دست‌دوم:** راهنمای گام‌به‌گام بررسی بدنه، ریجستری، پورت‌ها، سنسورها و سلامت قطعات برای خریداران و فروشندگان.
- **تشخیص ناهنجاری سیستمی (Anomaly Detection):** راستی‌آزمایی مشخصات ادعایی دستگاه، شناسایی ردپای روت و بیلد با کلیدهای آزمایشی (test-keys).
- **تولید گزارش تشخیصی:** خروجی گرفتن در قالب‌های متنی (TXT)، ساختاریافته (JSON) و سند رسمی (PDF) همراه با قابلیت اشتراک‌گذاری در پیام‌رسان‌ها.
- **واژه‌نامه تخصصی:** توضیح ساده و روان مفاهیم پیچیده سخت‌افزاری برای ارتقای دانش فنی کاربران.

---

## 💰 شبکه تبلیغات ادیوری (Adivery Integration)

این اپلیکیشن طبق مستندات رسمی [Adivery](https://docs.adivery.com) به شبکه تبلیغاتی ادیوری مجهز شده است:
- **ویجت بنر تطبیقی (Banner Ad):** قرارگیری خودکار در انتهای صفحات بدون اشغال بی‌مورد فضا یا شکستن لایه‌بندی در زمان قطعی اینترنت.
- **تبلیغ همسان بومی (Native Ad):** کارت هماهنگ با تم تیره و روشن برنامه در داشبورد و ابزارها.
- **تبلیغ میان‌صفحه‌ای هوشمند (Interstitial Ad):** دارای کنترل فاصله زمانی (Rate Limiting حداقل ۱۲۰ ثانیه) تا کاربر آزرده نشود.
- **تبلیغ ویدیویی جایزه‌ای (Rewarded Ad):** برای باز کردن پاک‌سازی عمیق توربو اسپیکر یا حمایت اختیاری کاربر.
- **تنظیمات داینامیک:** امکان مشاهده، تست و تغییر شناسه‌ها در منوی تنظیمات برنامه.

---

## 🏗️ معماری پروژه

```
PhoneScope/
├── android/app/src/main/kotlin/com/phonescope/phonescope/
│   ├── MainActivity.kt                  # ثبت و مدیریت Platform Channels
│   └── channels/                        # ۱۳ هندلر مستقل بومی Kotlin
│       ├── HardwareTestHandler.kt       # فلاش، ویبره، پاک‌کننده صوتی اسپیکر، میکروفون
│       ├── SystemInfoHandler.kt         # مشخصات کرنل و سیستم
│       ├── CpuInfoHandler.kt            # فرکانس‌های sysfs و procfs
│       ├── GpuInfoHandler.kt            # رندرینگ هدلس EGL و OpenGL
│       ├── MemoryStorageHandler.kt      # ActivityManager و StatFs
│       ├── BatteryHandler.kt            # پایش باتری با Receiver امن اندروید ۱۴+
│       ├── ThermalHandler.kt            # سازگار با Android 7 تا 15
│       ├── DisplayInfoHandler.kt        # DisplayManager ایمن در برابر Exception
│       ├── CameraInfoHandler.kt         # CameraCharacteristics
│       ├── SensorsHandler.kt            # استریم زنده سنسورها
│       ├── NetworkInfoHandler.kt        # Wi-Fi و NetworkCapabilities
│       ├── AppsInfoHandler.kt           # اطلاعات پکیج‌های نصب‌شده با جلوگیری از OOM
│       └── ShareHandler.kt              # اینتنت‌ها، FileProvider و اشتراک‌گذاری
├── lib/
│   ├── app/                             # تم متریال ۳، تایپوگرافی، فونت وزیرمتن
│   ├── core/
│   │   ├── ads/                         # سرویس مدیریت ادیوری، بنر و کارت بومی
│   │   ├── platform/                    # سرویس ارتباط با چنل‌های بومی
│   │   └── widgets/                     # ویجت‌های مشترک و کارت‌های آماری
│   └── features/                        # ماژول‌های جداگانه (داشبورد، پاک‌کننده، بنچمارک...)
└── test/
    ├── unit_tests_test.dart             # آزمون‌های واحد مدل‌ها و تبدیل‌ها
    ├── widget_test.dart                 # آزمون‌های ویجت‌های سفارشی
    ├── smoke_test.dart                  # آزمون‌های اسموک راه‌اندازی و پایداری
    └── stress_test.dart                 # آزمون‌های استرس بار سنگین و سوییچ سریع
```

---

## 🚀 راهنمای بیلد و آزمون‌ها

### ۱. اجرای تمامی آزمون‌ها (۳۳ آزمون خودکار)
```bash
flutter test
```

### ۲. بررسی سلامت و استانداردهای کد (Linting)
```bash
flutter analyze
```

### ۳. ساخت نسخه نهایی جهت انتشار در کافه بازار و مایکت
```bash
# ساخت App Bundle استاندارد (توصیه شده توسط کافه‌بازار و گوگل‌پلی)
flutter build appbundle --release

# یا ساخت فایل نصبی APK چندتکه (Split-per-ABI) با حجم کاهش یافته به حدود ۲۰ مگابایت
flutter build apk --release --split-per-abi
```

---

## 👨‍💻 توسعه‌دهنده / Developer

طراحی، معماری و پیاده‌سازی شده توسط:

### **شایان نماینده (Shayan Namayandeh)**
- 🌐 **وب‌سایت شخصی:** [devshayan.ir](https://devshayan.ir)
- 🐙 **گیت‌هاب:** [@roseshayan](https://github.com/roseshayan)
- 📧 **ایمیل:** [namayandeshayan@gmail.com](mailto:namayandeshayan@gmail.com)

---

## 📄 مجوز و حقوق نشر (License)

این پروژه تحت مجوز [MIT License](LICENSE) منتشر شده است.  
فونت فارسی **وزیرمتن (Vazirmatn)** اثر صابر راستی‌کردار تحت مجوز آزاد [OFL (SIL Open Font License)](http://scripts.sil.org/OFL) استفاده شده است.
