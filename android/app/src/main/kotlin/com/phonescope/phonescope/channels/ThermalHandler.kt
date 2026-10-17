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

    private var thermalHelper: Any? = null

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
            val helper = ThermalApi29Helper(context)
            thermalHelper = helper
            helper.startListening(events)
        }
    }

    override fun onCancel(arguments: Any?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            (thermalHelper as? ThermalApi29Helper)?.stopListening()
            thermalHelper = null
        }
    }

    private fun getThermalDetails(): Map<String, Any?> {
        val statusInt: Int
        val thermalHeadroom: Float?

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val helper = (thermalHelper as? ThermalApi29Helper) ?: ThermalApi29Helper(context)
            statusInt = helper.getCurrentThermalStatus()
            thermalHeadroom = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                helper.getThermalHeadroom()
            } else {
                null
            }
        } else {
            statusInt = -1
            thermalHeadroom = null
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
            0 -> "Normal / None"
            1 -> "Light Throttling"
            2 -> "Moderate Throttling"
            3 -> "Severe Throttling"
            4 -> "Critical Throttling"
            5 -> "Emergency Shutdown Required"
            6 -> "Thermal Shutdown"
            else -> "Not Supported or Pre-Android 10"
        }
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private class ThermalApi29Helper(private val context: Context) {
        private var listener: PowerManager.OnThermalStatusChangedListener? = null
        private val pm: PowerManager? = context.getSystemService(Context.POWER_SERVICE) as? PowerManager

        fun startListening(events: EventChannel.EventSink?) {
            if (pm != null && listener == null) {
                listener = PowerManager.OnThermalStatusChangedListener { status ->
                    val statusText = when (status) {
                        0 -> "Normal / None"
                        1 -> "Light Throttling"
                        2 -> "Moderate Throttling"
                        3 -> "Severe Throttling"
                        4 -> "Critical Throttling"
                        5 -> "Emergency Shutdown Required"
                        6 -> "Thermal Shutdown"
                        else -> "Unknown"
                    }
                    events?.success(mapOf(
                        "thermalStatus" to statusText,
                        "thermalStatusCode" to status
                    ))
                }
                pm.addThermalStatusListener(context.mainExecutor, listener!!)
            }
        }

        fun stopListening() {
            if (pm != null && listener != null) {
                try {
                    pm.removeThermalStatusListener(listener!!)
                } catch (_: Exception) {}
                listener = null
            }
        }

        fun getCurrentThermalStatus(): Int {
            return pm?.currentThermalStatus ?: -1
        }

        @RequiresApi(Build.VERSION_CODES.R)
        fun getThermalHeadroom(): Float? {
            return try {
                pm?.getThermalHeadroom(10)
            } catch (_: Exception) {
                null
            }
        }
    }
}
