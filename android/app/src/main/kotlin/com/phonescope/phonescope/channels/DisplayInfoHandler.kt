package com.phonescope.phonescope.channels

import android.content.Context
import android.hardware.display.DisplayManager
import android.os.Build
import android.util.DisplayMetrics
import android.view.Display
import android.view.WindowManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.pow
import kotlin.math.roundToInt
import kotlin.math.sqrt

class DisplayInfoHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getDisplayInfo" -> {
                try {
                    val info = getDisplayDetails()
                    result.success(info)
                } catch (e: Exception) {
                    result.error("DISPLAY_INFO_ERROR", e.localizedMessage, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getDisplayDetails(): Map<String, Any?> {
        val wm = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val dm = context.getSystemService(Context.DISPLAY_SERVICE) as? DisplayManager

        // Safe display resolution across API 21 to 35 without throwing UnsupportedOperationException
        val display: Display? = try {
            dm?.getDisplay(Display.DEFAULT_DISPLAY)
        } catch (_: Exception) {
            null
        } ?: try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                try {
                    context.display
                } catch (_: Exception) {
                    @Suppress("DEPRECATION")
                    wm.defaultDisplay
                }
            } else {
                @Suppress("DEPRECATION")
                wm.defaultDisplay
            }
        } catch (_: Exception) {
            @Suppress("DEPRECATION")
            wm.defaultDisplay
        }

        val metrics = DisplayMetrics()
        val realMetrics = DisplayMetrics()
        try {
            @Suppress("DEPRECATION")
            display?.getMetrics(metrics)
            @Suppress("DEPRECATION")
            display?.getRealMetrics(realMetrics)
        } catch (_: Exception) {}

        val realWidth = if (realMetrics.widthPixels > 0) realMetrics.widthPixels else 1080
        val realHeight = if (realMetrics.heightPixels > 0) realMetrics.heightPixels else 1920
        val density = if (realMetrics.density > 0) realMetrics.density else 2.0f
        val densityDpi = if (realMetrics.densityDpi > 0) realMetrics.densityDpi else 320

        // Physical size in inches
        val xdpi = if (realMetrics.xdpi > 0) realMetrics.xdpi else 160f
        val ydpi = if (realMetrics.ydpi > 0) realMetrics.ydpi else 160f
        val xInches = realWidth / xdpi
        val yInches = realHeight / ydpi
        val diagonalInches = sqrt(xInches.toDouble().pow(2.0) + yInches.toDouble().pow(2.0))
        val roundedDiagonal = (diagonalInches * 10.0).roundToInt() / 10.0

        // Refresh rates
        val currentRefreshRate = display?.refreshRate ?: 60f
        val supportedRefreshRates = mutableListOf<Float>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && display != null) {
            try {
                for (mode in display.supportedModes) {
                    if (!supportedRefreshRates.contains(mode.refreshRate)) {
                        supportedRefreshRates.add(mode.refreshRate)
                    }
                }
            } catch (_: Exception) {}
        }
        if (supportedRefreshRates.isEmpty()) {
            supportedRefreshRates.add(currentRefreshRate)
        }

        // HDR Capabilities
        val hdrTypes = mutableListOf<String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && display != null) {
            try {
                val hdrCaps = display.hdrCapabilities
                if (hdrCaps != null) {
                    for (type in hdrCaps.supportedHdrTypes) {
                        when (type) {
                            Display.HdrCapabilities.HDR_TYPE_HDR10 -> hdrTypes.add("HDR10")
                            Display.HdrCapabilities.HDR_TYPE_HLG -> hdrTypes.add("HLG")
                            Display.HdrCapabilities.HDR_TYPE_DOLBY_VISION -> hdrTypes.add("Dolby Vision")
                            Display.HdrCapabilities.HDR_TYPE_HDR10_PLUS -> hdrTypes.add("HDR10+")
                            else -> hdrTypes.add("Type_$type")
                        }
                    }
                }
            } catch (_: Exception) {}
        }

        // Wide color gamut
        val isWideColorGamut = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && display != null) {
            try {
                display.isWideColorGamut
            } catch (_: Exception) {
                false
            }
        } else {
            false
        }

        val rotation = try {
            display?.rotation ?: 0
        } catch (_: Exception) {
            0
        }
        val orientation = when (rotation) {
            0 -> "Portrait (0°)"
            1 -> "Landscape (90°)"
            2 -> "Reverse Portrait (180°)"
            3 -> "Reverse Landscape (270°)"
            else -> "Unknown"
        }

        return mapOf(
            "physicalWidthPixels" to realWidth,
            "physicalHeightPixels" to realHeight,
            "logicalWidthDp" to (realWidth / density).roundToInt(),
            "logicalHeightDp" to (realHeight / density).roundToInt(),
            "density" to density,
            "densityDpi" to densityDpi,
            "xdpi" to xdpi,
            "ydpi" to ydpi,
            "diagonalInches" to roundedDiagonal,
            "currentRefreshRate" to currentRefreshRate,
            "supportedRefreshRates" to supportedRefreshRates.sorted(),
            "isHdrSupported" to hdrTypes.isNotEmpty(),
            "hdrTypes" to hdrTypes,
            "isWideColorGamut" to isWideColorGamut,
            "orientation" to orientation
        )
    }
}
