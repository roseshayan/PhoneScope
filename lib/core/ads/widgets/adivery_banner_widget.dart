import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adivery/adivery_ads.dart';
import '../adivery_service.dart';

/// ویجت بنر تبلیغاتی هوشمند ادیوری (Adivery Banner Widget)
/// همراه با مدیریت استایل، ریسپانسیو بودن و عدم شکست رابط کاربری
class AdiveryBannerWidget extends StatefulWidget {
  final BannerAdSize bannerSize;
  final String? placementId;
  final bool showBadge;

  const AdiveryBannerWidget({
    super.key,
    this.bannerSize = BannerAdSize.BANNER,
    this.placementId,
    this.showBadge = true,
  });

  @override
  State<AdiveryBannerWidget> createState() => _AdiveryBannerWidgetState();
}

class _AdiveryBannerWidgetState extends State<AdiveryBannerWidget> {
  bool _isAdLoaded = false;
  bool _hasError = false;

  double get _height {
    switch (widget.bannerSize) {
      case BannerAdSize.BANNER:
        return 50.0;
      case BannerAdSize.LARGE_BANNER:
        return 100.0;
      case BannerAdSize.MEDIUM_RECTANGLE:
        return 250.0;
    }
  }

  double get _width {
    switch (widget.bannerSize) {
      case BannerAdSize.BANNER:
      case BannerAdSize.LARGE_BANNER:
        return 320.0;
      case BannerAdSize.MEDIUM_RECTANGLE:
        return 300.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const SizedBox.shrink();
    }

    final placement = widget.placementId ?? AdiveryService().bannerPlacement;
    final isRealAndroid = !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        !Platform.environment.containsKey('FLUTTER_TEST');

    if (!isRealAndroid) {
      // حالت تستی / شبیه‌ساز / تست‌های ویجت فلاتر
      return Center(
        child: Container(
          width: _width,
          height: _height,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.campaign, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'تبلیغ بنری ادیوری',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showBadge && _isAdLoaded)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                'آگهی',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.withValues(alpha: 0.6),
                ),
              ),
            ),
          SizedBox(
            width: _width,
            height: _height,
            child: BannerAd(
              placement,
              widget.bannerSize,
              onAdLoaded: (ad) {
                if (mounted) setState(() => _isAdLoaded = true);
              },
              onError: (ad, reason) {
                if (mounted) setState(() => _hasError = true);
              },
            ),
          ),
        ],
      ),
    );
  }
}
