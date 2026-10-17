package com.phonescope.phonescope.channels

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.PowerManager
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ThermalHandler(private val context: Context) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private var thermalListener: PowerManager.OnThermalStatusChangedListener? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getThermalInfo" -> {
                try {
                    val info = getThermalDetails()
                    result.success(info)
                } catch (e: Exception) {
                    result.error("THERMAL_INFO_ERROR", e.localizedMessage, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
            if (pm != null) {
                thermalListener = PowerManager.OnThermalStatusChangedListener { status ->
                    events?.success(mapOf(
                        "thermalStatus" to thermalStatusToString(status),
                        "thermalStatusCode" to status
                    ))
                }
                pm.addThermalStatusListener(context.mainExecutor, thermalListener!!)
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && thermalListener != null) {
            val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
            try {
                pm?.removeThermalStatusListener(thermalListener!!)
            } catch (_: Exception) {}
            thermalListener = null
        }
    }

    private fun getThermalDetails(): Map<String, Any?> {
        val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager

        val statusInt = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && pm != null) {
            pm.currentThermalStatus
        } else {
            -1
        }

        val thermalHeadroom = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && pm != null) {
            try {
                pm.getThermalHeadroom(10)
            } catch (_: Exception) {
                null
            }
        } else {
            null
        }

        // Battery temperature
        val batteryIntent = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val rawTemp = batteryIntent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1) ?: -1
        val batteryTempCelsius = if (rawTemp != -1) rawTemp / 10.0 else null

        return mapOf(
            "thermalStatus" to thermalStatusToString(statusInt),
            "thermalStatusCode" to statusInt,
            "thermalHeadroom" to thermalHeadroom,
            "batteryTemperatureCelsius" to batteryTempCelsius,
            "isThermalApiSupported" to (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q),
            "socTemperatureNote" to "Individual CPU/GPU core thermal sensors are restricted by Android OS SELinux. Reported thermal state reflects official Android Hardware Thermal Service."
        )
    }

    private fun thermalStatusToString(status: Int): String {
        return when (status) {
            PowerManager.THERMAL_STATUS_NONE -> "Normal / None"
            PowerManager.THERMAL_STATUS_LIGHT -> "Light Throttling"
            PowerManager.THERMAL_STATUS_MODERATE -> "Moderate Throttling"
            PowerManager.THERMAL_STATUS_SEVERE -> "Severe Throttling"
            PowerManager.THERMAL_STATUS_CRITICAL -> "Critical Throttling"
            PowerManager.THERMAL_STATUS_EMERGENCY -> "Emergency Shutdown Required"
            PowerManager.THERMAL_STATUS_SHUTDOWN -> "Thermal Shutdown"
            else -> "Not Supported or Pre-Android 10"
        }
    }
}
