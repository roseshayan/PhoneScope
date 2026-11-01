import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:adivery/adivery.dart';
import 'adivery_constants.dart';

/// سرویس جامع مدیریت تبلیغات ادیوری (Adivery SDK Manager)
/// هماهنگ با مستندات رسمی docs.adivery.com
class AdiveryService {
  static final AdiveryService _instance = AdiveryService._internal();
  factory AdiveryService() => _instance;
  AdiveryService._internal();

  bool _isInitialized = false;
  bool _isLogging = false;

  String _appId = AdiveryConstants.defaultAppId;
  String _bannerPlacement = AdiveryConstants.defaultBannerPlacement;
  String _interstitialPlacement = AdiveryConstants.defaultInterstitialPlacement;
  String _rewardedPlacement = AdiveryConstants.defaultRewardedPlacement;
  String _nativePlacement = AdiveryConstants.defaultNativePlacement;

  DateTime? _lastInterstitialShownTime;
  Function(bool isRewarded)? _activeRewardedCallback;
  VoidCallback? _activeInterstitialClosedCallback;

  // وضعیت‌های زنده بارگیری تبلیغات
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;

  bool get isInitialized => _isInitialized;
  String get appId => _appId;
  String get bannerPlacement => _bannerPlacement;
  String get interstitialPlacement => _interstitialPlacement;
  String get rewardedPlacement => _rewardedPlacement;
  String get nativePlacement => _nativePlacement;

  bool get isInterstitialLoaded => _isInterstitialLoaded;
  bool get isRewardedLoaded => _isRewardedLoaded;

  bool get isRealAndroid =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      !Platform.environment.containsKey('FLUTTER_TEST');

  /// مقداردهی اولیه SDK ادیوری
  Future<void> initialize({
    String? appId,
    String? bannerPlacement,
    String? interstitialPlacement,
    String? rewardedPlacement,
    String? nativePlacement,
    bool enableLogging = kDebugMode,
  }) async {
    if (_isInitialized) return;

    _appId = appId ?? _appId;
    _bannerPlacement = bannerPlacement ?? _bannerPlacement;
    _interstitialPlacement = interstitialPlacement ?? _interstitialPlacement;
    _rewardedPlacement = rewardedPlacement ?? _rewardedPlacement;
    _nativePlacement = nativePlacement ?? _nativePlacement;
    _isLogging = enableLogging;

    // ادیوری فقط روی پلتفرم واقعی اندروید اجرا می‌شود
    if (isRealAndroid) {
      try {
        AdiveryPlugin.initialize(_appId);
        AdiveryPlugin.setLoggingEnabled(_isLogging);

        _setupListeners();
        _preparePlacements();

        _isInitialized = true;
        if (_isLogging) {
          debugPrint('[AdiveryService] Successfully initialized with appId: $_appId');
        }
      } catch (e) {
        debugPrint('[AdiveryService] Initialization failed: $e');
      }
    } else {
      if (_isLogging) {
        debugPrint('[AdiveryService] Skipping native initialization on test/non-Android platform.');
      }
    }
  }

  /// به‌روزرسانی شناسه‌های اختصاصی کاربر (از صفحه تنظیمات برنامه)
  void updatePlacements({
    String? appId,
    String? bannerPlacement,
    String? interstitialPlacement,
    String? rewardedPlacement,
    String? nativePlacement,
  }) {
    if (appId != null && appId.trim().isNotEmpty) _appId = appId.trim();
    if (bannerPlacement != null && bannerPlacement.trim().isNotEmpty) {
      _bannerPlacement = bannerPlacement.trim();
    }
    if (interstitialPlacement != null && interstitialPlacement.trim().isNotEmpty) {
      _interstitialPlacement = interstitialPlacement.trim();
    }
    if (rewardedPlacement != null && rewardedPlacement.trim().isNotEmpty) {
      _rewardedPlacement = rewardedPlacement.trim();
    }
    if (nativePlacement != null && nativePlacement.trim().isNotEmpty) {
      _nativePlacement = nativePlacement.trim();
    }

    _preparePlacements();
  }

  /// پیش‌بارگذاری جایگاه‌های میان‌صفحه‌ای و جایزه‌ای
  void _preparePlacements() {
    if (isRealAndroid) {
      try {
        AdiveryPlugin.prepareInterstitialAd(_interstitialPlacement);
        AdiveryPlugin.prepareRewardedAd(_rewardedPlacement);
      } catch (e) {
        debugPrint('[AdiveryService] Prepare placements failed: $e');
      }
    }
  }

  /// تنظیم رویدادهای عمومی SDK
  void _setupListeners() {
    AdiveryPlugin.addListener(
      onInterstitialLoaded: (placement) {
        if (placement == _interstitialPlacement) {
          _isInterstitialLoaded = true;
        }
        if (_isLogging) debugPrint('[Adivery] Interstitial loaded: $placement');
      },
      onInterstitialClosed: (placement) {
        if (placement == _interstitialPlacement) {
          _isInterstitialLoaded = false;
          _lastInterstitialShownTime = DateTime.now();
          _activeInterstitialClosedCallback?.call();
          _activeInterstitialClosedCallback = null;
          // بارگذاری خودکار برای دفعه بعدی
          AdiveryPlugin.prepareInterstitialAd(_interstitialPlacement);
        }
        if (_isLogging) debugPrint('[Adivery] Interstitial closed: $placement');
      },
      onInterstitialClicked: (placement) {
        if (_isLogging) debugPrint('[Adivery] Interstitial clicked: $placement');
      },
      onRewardedLoaded: (placement) {
        if (placement == _rewardedPlacement) {
          _isRewardedLoaded = true;
        }
        if (_isLogging) debugPrint('[Adivery] Rewarded ad loaded: $placement');
      },
      onRewardedClosed: (placement, isRewarded) {
        if (placement == _rewardedPlacement) {
          _isRewardedLoaded = false;
          _activeRewardedCallback?.call(isRewarded);
          _activeRewardedCallback = null;
          // بارگذاری خودکار برای دفعه بعدی
          AdiveryPlugin.prepareRewardedAd(_rewardedPlacement);
        }
        if (_isLogging) {
          debugPrint('[Adivery] Rewarded ad closed. Reward granted: $isRewarded');
        }
      },
      onRewardedClicked: (placement) {
        if (_isLogging) debugPrint('[Adivery] Rewarded ad clicked: $placement');
      },
      onError: (placement, reason) {
        if (_isLogging) {
          debugPrint('[Adivery] Error on placement $placement: $reason');
        }
      },
    );
  }

  /// بررسی فاصله زمانی مجاز برای نمایش تبلیغ میان‌صفحه‌ای
  bool canShowInterstitial() {
    if (_lastInterstitialShownTime == null) return true;
    final diff = DateTime.now().difference(_lastInterstitialShownTime!).inSeconds;
    return diff >= AdiveryConstants.interstitialCooldownSeconds;
  }

  /// نمایش تبلیغ میان‌صفحه‌ای با کنترل فاصله زمانی
  Future<bool> showInterstitialAd({
    VoidCallback? onClosed,
    bool force = false,
  }) async {
    if (isRealAndroid) {
      if (!force && !canShowInterstitial()) {
        if (_isLogging) {
          debugPrint('[Adivery] Interstitial skipped due to rate limit cooldown.');
        }
        onClosed?.call();
        return false;
      }

      try {
        final bool isReady = await AdiveryPlugin.isLoaded(_interstitialPlacement) ?? false;
        if (isReady) {
          _activeInterstitialClosedCallback = onClosed;
          AdiveryPlugin.show(_interstitialPlacement);
          return true;
        } else {
          AdiveryPlugin.prepareInterstitialAd(_interstitialPlacement);
          onClosed?.call();
          return false;
        }
      } catch (e) {
        debugPrint('[Adivery] Show interstitial error: $e');
        onClosed?.call();
        return false;
      }
    } else {
      onClosed?.call();
      return false;
    }
  }

  /// نمایش تبلیغ ویدیویی جایزه‌ای با فراخوانی نتیجه
  Future<bool> showRewardedAd({
    required Function(bool isRewarded) onRewardResult,
  }) async {
    if (isRealAndroid) {
      try {
        final bool isReady = await AdiveryPlugin.isLoaded(_rewardedPlacement) ?? false;
        if (isReady) {
          _activeRewardedCallback = onRewardResult;
          AdiveryPlugin.show(_rewardedPlacement);
          return true;
        } else {
          AdiveryPlugin.prepareRewardedAd(_rewardedPlacement);
          onRewardResult(false);
          return false;
        }
      } catch (e) {
        debugPrint('[Adivery] Show rewarded error: $e');
        onRewardResult(false);
        return false;
      }
    } else {
      // در محیط شبیه‌ساز یا تست، پاداش آزمایشی برمی‌گرداند
      onRewardResult(true);
      return true;
    }
  }
}
