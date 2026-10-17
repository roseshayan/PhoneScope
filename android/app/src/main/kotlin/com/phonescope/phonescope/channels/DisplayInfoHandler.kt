package com.phonescope.phonescope.channels

import android.content.Context
import android.graphics.Point
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
        val display: Display? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            context.display
        } else {
            @Suppress("DEPRECATION")
            wm.defaultDisplay
        }

        val metrics = DisplayMetrics()
        val realMetrics = DisplayMetrics()
        @Suppress("DEPRECATION")
        display?.getMetrics(metrics)
        @Suppress("DEPRECATION")
        display?.getRealMetrics(realMetrics)

        val realWidth = realMetrics.widthPixels
        val realHeight = realMetrics.heightPixels

        // Physical size in inches
        val xInches = realWidth / (if (realMetrics.xdpi > 0) realMetrics.xdpi else 160f)
        val yInches = realHeight / (if (realMetrics.ydpi > 0) realMetrics.ydpi else 160f)
        val diagonalInches = sqrt(xInches.toDouble().pow(2.0) + yInches.toDouble().pow(2.0))
        val roundedDiagonal = (diagonalInches * 10.0).roundToInt() / 10.0

        // Refresh rates
        val currentRefreshRate = display?.refreshRate ?: 60f
        val supportedRefreshRates = mutableListOf<Float>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && display != null) {
            for (mode in display.supportedModes) {
                if (!supportedRefreshRates.contains(mode.refreshRate)) {
                    supportedRefreshRates.add(mode.refreshRate)
                }
            }
        } else {
            supportedRefreshRates.add(currentRefreshRate)
        }

        // HDR Capabilities
        val hdrTypes = mutableListOf<String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && display != null) {
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
        }

        // Wide color gamut
        val isWideColorGamut = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && display != null) {
            display.isWideColorGamut
        } else {
            false
        }

        val rotation = display?.rotation ?: 0
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
            "logicalWidthDp" to (realWidth / realMetrics.density).roundToInt(),
            "logicalHeightDp" to (realHeight / realMetrics.density).roundToInt(),
            "density" to realMetrics.density,
            "densityDpi" to realMetrics.densityDpi,
            "xdpi" to realMetrics.xdpi,
            "ydpi" to realMetrics.ydpi,
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
