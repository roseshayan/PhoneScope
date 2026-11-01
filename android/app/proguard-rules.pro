# ProGuard rules for PhoneScope

# Adivery SDK rules
-keep class com.google.android.gms.** { *; }
-keep class com.google.ads.** { *; }
-keep class com.adivery.** { *; }
-keep class com.chartboost.** { *; }
-keep class com.huawei.hms.ads.** { *; }
-keep class com.ironsource.mediationsdk.** { *; }
-keep class com.mbridge.msdk.** { *; }
-dontwarn com.adivery.**

# Flutter and Native Channels
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.phonescope.phonescope.** { *; }
