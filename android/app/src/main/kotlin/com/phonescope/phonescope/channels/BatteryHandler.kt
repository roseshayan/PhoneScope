package com.phonescope.phonescope.channels

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BatteryHandler(private val context: Context) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private var batteryReceiver: BroadcastReceiver? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBatteryInfo" -> {
                try {
                    val info = getBatteryDetails()
                    result.success(info)
                } catch (e: Exception) {
                    result.error("BATTERY_INFO_ERROR", e.localizedMessage, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        batteryReceiver = object : BroadcastReceiver() {
            override fun onReceive(c: Context?, intent: Intent?) {
                if (intent != null && events != null) {
                    events.success(extractFromIntent(intent))
                }
            }
        }
        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        context.registerReceiver(batteryReceiver, filter)
    }

    override fun onCancel(arguments: Any?) {
        if (batteryReceiver != null) {
            try {
                context.unregisterReceiver(batteryReceiver)
            } catch (_: Exception) {}
            batteryReceiver = null
        }
    }

    private fun getBatteryDetails(): Map<String, Any?> {
        val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        val intent = context.registerReceiver(null, filter)
        return if (intent != null) {
            extractFromIntent(intent)
        } else {
            emptyMap()
        }
    }

    private fun extractFromIntent(intent: Intent): Map<String, Any?> {
        val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        val percentage = if (level >= 0 && scale > 0) (level * 100.0 / scale) else -1.0

        val voltageMv = intent.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1)
        val tempRaw = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
        val tempCelsius = if (tempRaw != -1) (tempRaw / 10.0) else null

        val statusInt = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
        val statusString = when (statusInt) {
            BatteryManager.BATTERY_STATUS_CHARGING -> "Charging"
            BatteryManager.BATTERY_STATUS_DISCHARGING -> "Discharging"
            BatteryManager.BATTERY_STATUS_FULL -> "Full"
            BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "Not Charging"
            else -> "Unknown"
        }

        val pluggedInt = intent.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1)
        val pluggedString = when (pluggedInt) {
            BatteryManager.BATTERY_PLUGGED_AC -> "AC Charger"
            BatteryManager.BATTERY_PLUGGED_USB -> "USB Port"
            BatteryManager.BATTERY_PLUGGED_WIRELESS -> "Wireless"
            else -> if (pluggedInt > 0) "Dock/Other" else "Unplugged"
        }

        val healthInt = intent.getIntExtra(BatteryManager.EXTRA_HEALTH, -1)
        val healthString = when (healthInt) {
            BatteryManager.BATTERY_HEALTH_GOOD -> "Good"
            BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Overheat"
            BatteryManager.BATTERY_HEALTH_DEAD -> "Dead"
            BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "Over Voltage"
            BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE -> "Unspecified Failure"
            BatteryManager.BATTERY_HEALTH_COLD -> "Cold"
            else -> "Unknown"
        }

        val technology = intent.getStringExtra(BatteryManager.EXTRA_TECHNOLOGY) ?: "Unknown"

        val bm = context.getSystemService(Context.BATTERY_SERVICE) as? BatteryManager
        val currentNowUa = bm?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW) ?: 0
        val currentAvgUa = bm?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_AVERAGE) ?: 0
        val chargeCounterUah = bm?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CHARGE_COUNTER) ?: 0
        val capacityPercent = bm?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) ?: -1

        return mapOf(
            "level" to percentage,
            "voltageMv" to voltageMv,
            "temperatureCelsius" to tempCelsius,
            "status" to statusString,
            "isCharging" to (statusInt == BatteryManager.BATTERY_STATUS_CHARGING),
            "plugged" to pluggedString,
            "health" to healthString,
            "technology" to technology,
            "currentNowMicroAmps" to currentNowUa,
            "currentAverageMicroAmps" to currentAvgUa,
            "chargeCounterMicroAmpHours" to chargeCounterUah,
            "capacity" to capacityPercent
        )
    }
}
