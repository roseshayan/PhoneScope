/// Adivery Ads Configuration and Constants
///
/// شناسه اپلیکیشن و جایگاه‌های تبلیغاتی در شبکه ادیوری (Adivery)
/// جهت انتشار در کافه بازار و مایکت، شناسه‌های اختصاصی دریافت شده از پنل:
/// https://panel.adivery.com را در این بخش جایگزین فرمایید.
class AdiveryConstants {
  // شناسه پیش‌فرض اپلیکیشن در پنل ادیوری (شناسه تستی معتبر)
  static const String defaultAppId = '7524c563-e7fe-4deb-9e7f-c340a698a6ff';

  // شناسه جایگاه بنر استاندارد (Banner Ad)
  static const String defaultBannerPlacement = '0f512704-fb5e-4903-8884-25e2298c4840';

  // شناسه جایگاه تبلیغ میان‌صفحه‌ای (Interstitial Ad)
  static const String defaultInterstitialPlacement = '3f97e7e5-1810-4845-9831-299a9a3b7230';

  // شناسه جایگاه تبلیغ ویدیویی جایزه‌ای (Rewarded Ad)
  static const String defaultRewardedPlacement = '89a24419-5d2d-4560-96f7-111009386c90';

  // شناسه جایگاه تبلیغ همسان / بومی (Native Ad)
  static const String defaultNativePlacement = '25634e06-6923-4556-9467-36c58908f97b';

  // حداقل فاصله زمانی بین نمایش تبلیغات میان‌صفحه‌ای (ثانیه) جهت رضایت کاربر
  static const int interstitialCooldownSeconds = 120;
}
