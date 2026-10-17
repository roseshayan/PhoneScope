package com.phonescope.phonescope.channels

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SensorsHandler(private val context: Context) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
    private var activeListener: SensorEventListener? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getSensorsList" -> {
                try {
                    val list = getSensors()
                    result.success(list)
                } catch (e: Exception) {
                    result.error("SENSORS_ERROR", e.localizedMessage, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        val sensorType = (arguments as? Map<*, *>)?.get("sensorType") as? Int ?: Sensor.TYPE_ACCELEROMETER
        val sensor = sensorManager?.getDefaultSensor(sensorType)

        if (sensor == null) {
            events?.error("SENSOR_NOT_AVAILABLE", "Sensor type $sensorType not available on this device", null)
            return
        }

        activeListener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent?) {
                if (event != null && events != null) {
                    val values = event.values.map { it.toDouble() }
                    events.success(
                        mapOf(
                            "sensorType" to event.sensor.type,
                            "accuracy" to event.accuracy,
                            "timestamp" to event.timestamp,
                            "values" to values
                        )
                    )
                }
            }

            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }

        val samplingPeriod = SensorManager.SENSOR_DELAY_UI
        sensorManager?.registerListener(activeListener, sensor, samplingPeriod)
    }

    override fun onCancel(arguments: Any?) {
        if (activeListener != null) {
            sensorManager?.unregisterListener(activeListener)
            activeListener = null
        }
    }

    private fun getSensors(): List<Map<String, Any?>> {
        val list = sensorManager?.getSensorList(Sensor.TYPE_ALL) ?: emptyList()
        val result = mutableListOf<Map<String, Any?>>()

        for (s in list) {
            val stringType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
                s.stringType
            } else {
                "Sensor_${s.type}"
            }

            val reportingModeStr = when (s.reportingMode) {
                Sensor.REPORTING_MODE_CONTINUOUS -> "Continuous"
                Sensor.REPORTING_MODE_ON_CHANGE -> "On-Change"
                Sensor.REPORTING_MODE_ONE_SHOT -> "One-Shot"
                Sensor.REPORTING_MODE_SPECIAL_TRIGGER -> "Special Trigger"
                else -> "Unknown"
            }

            result.add(
                mapOf(
                    "name" to s.name,
                    "vendor" to s.vendor,
                    "version" to s.version,
                    "type" to s.type,
                    "stringType" to stringType,
                    "maxRange" to s.maximumRange,
                    "resolution" to s.resolution,
                    "powerMa" to s.power,
                    "minDelayMicros" to s.minDelay,
                    "maxDelayMicros" to (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) s.maxDelay else 0),
                    "isWakeUp" to (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) s.isWakeUpSensor else false),
                    "reportingMode" to reportingModeStr
                )
            )
        }

        return result
    }
}
