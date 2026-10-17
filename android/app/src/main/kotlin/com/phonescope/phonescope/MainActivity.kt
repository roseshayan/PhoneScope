package com.phonescope.phonescope

import androidx.annotation.NonNull
import com.phonescope.phonescope.channels.AppsInfoHandler
import com.phonescope.phonescope.channels.BatteryHandler
import com.phonescope.phonescope.channels.CameraInfoHandler
import com.phonescope.phonescope.channels.CpuInfoHandler
import com.phonescope.phonescope.channels.DisplayInfoHandler
import com.phonescope.phonescope.channels.GpuInfoHandler
import com.phonescope.phonescope.channels.HardwareTestHandler
import com.phonescope.phonescope.channels.MemoryStorageHandler
import com.phonescope.phonescope.channels.NetworkInfoHandler
import com.phonescope.phonescope.channels.SensorsHandler
import com.phonescope.phonescope.channels.ShareHandler
import com.phonescope.phonescope.channels.SystemInfoHandler
import com.phonescope.phonescope.channels.ThermalHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private lateinit var shareHandler: ShareHandler

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // 1. System Info
        MethodChannel(messenger, "com.phonescope.app/system")
            .setMethodCallHandler(SystemInfoHandler(applicationContext))

        // 2. CPU & SoC Info
        MethodChannel(messenger, "com.phonescope.app/cpu")
            .setMethodCallHandler(CpuInfoHandler())

        // 3. GPU Info
        MethodChannel(messenger, "com.phonescope.app/gpu")
            .setMethodCallHandler(GpuInfoHandler(applicationContext))

        // 4. Memory & Storage Info
        MethodChannel(messenger, "com.phonescope.app/memory_storage")
            .setMethodCallHandler(MemoryStorageHandler(applicationContext))

        // 5. Battery Info & Stream
        val batteryHandler = BatteryHandler(applicationContext)
        MethodChannel(messenger, "com.phonescope.app/battery")
            .setMethodCallHandler(batteryHandler)
        EventChannel(messenger, "com.phonescope.app/battery_stream")
            .setStreamHandler(batteryHandler)

        // 6. Thermal Info & Stream
        val thermalHandler = ThermalHandler(applicationContext)
        MethodChannel(messenger, "com.phonescope.app/thermal")
            .setMethodCallHandler(thermalHandler)
        EventChannel(messenger, "com.phonescope.app/thermal_stream")
            .setStreamHandler(thermalHandler)

        // 7. Display Info
        MethodChannel(messenger, "com.phonescope.app/display")
            .setMethodCallHandler(DisplayInfoHandler(applicationContext))

        // 8. Camera Info
        MethodChannel(messenger, "com.phonescope.app/camera")
            .setMethodCallHandler(CameraInfoHandler(applicationContext))

        // 9. Sensors Info & Stream
        val sensorsHandler = SensorsHandler(applicationContext)
        MethodChannel(messenger, "com.phonescope.app/sensors")
            .setMethodCallHandler(sensorsHandler)
        EventChannel(messenger, "com.phonescope.app/sensors_stream")
            .setStreamHandler(sensorsHandler)

        // 10. Network Info
        MethodChannel(messenger, "com.phonescope.app/network")
            .setMethodCallHandler(NetworkInfoHandler(applicationContext))

        // 11. Apps Info
        MethodChannel(messenger, "com.phonescope.app/apps")
            .setMethodCallHandler(AppsInfoHandler(applicationContext))

        // 12. Hardware Tests
        MethodChannel(messenger, "com.phonescope.app/hardware_test")
            .setMethodCallHandler(HardwareTestHandler(applicationContext))

        // 13. File & Text Share
        shareHandler = ShareHandler(applicationContext, this)
        MethodChannel(messenger, "com.phonescope.app/share")
            .setMethodCallHandler(shareHandler)
    }

    override fun onResume() {
        super.onResume()
        if (::shareHandler.isInitialized) {
            shareHandler.setActivity(this)
        }
    }
}
