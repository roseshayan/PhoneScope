package com.phonescope.phonescope.channels

import android.content.Context
import android.graphics.ImageFormat
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.roundToInt

class CameraInfoHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getCameraInfo" -> {
                try {
                    val info = getCameraDetails()
                    result.success(info)
                } catch (e: Exception) {
                    result.error("CAMERA_INFO_ERROR", e.localizedMessage, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getCameraDetails(): Map<String, Any?> {
        val cm = context.getSystemService(Context.CAMERA_SERVICE) as? CameraManager
            ?: return mapOf("camerasCount" to 0, "cameras" to emptyList<Map<String, Any?>>())

        val cameraList = mutableListOf<Map<String, Any?>>()
        val cameraIds = cm.cameraIdList

        for (id in cameraIds) {
            try {
                val chars = cm.getCameraCharacteristics(id)

                val facingInt = chars.get(CameraCharacteristics.LENS_FACING)
                val facingStr = when (facingInt) {
                    CameraCharacteristics.LENS_FACING_FRONT -> "Front (Selfie)"
                    CameraCharacteristics.LENS_FACING_BACK -> "Back (Rear)"
                    CameraCharacteristics.LENS_FACING_EXTERNAL -> "External"
                    else -> "Unknown"
                }

                val hwLevelInt = chars.get(CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL)
                val hwLevelStr = when (hwLevelInt) {
                    CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_LEGACY -> "Legacy"
                    CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_LIMITED -> "Limited"
                    CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_FULL -> "Full"
                    CameraCharacteristics.INFO_SUPPORTED_HARDWARE_LEVEL_3 -> "Level 3"
                    4 -> "External" // INFO_SUPPORTED_HARDWARE_LEVEL_EXTERNAL on Android 9+
                    else -> "Unknown"
                }

                // Sensor resolution & active array size
                val arraySize = chars.get(CameraCharacteristics.SENSOR_INFO_ACTIVE_ARRAY_SIZE)
                val activeWidth = arraySize?.width() ?: 0
                val activeHeight = arraySize?.height() ?: 0
                val megapixels = ((activeWidth * activeHeight.toDouble()) / 1_000_000.0 * 10.0).roundToInt() / 10.0

                // Physical sensor size
                val sensorSize = chars.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE)
                val sensorSizeStr = if (sensorSize != null) "${sensorSize.width} x ${sensorSize.height} mm" else "Unavailable"

                // Focal lengths
                val focalLengths = chars.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)?.toList() ?: emptyList()

                // Apertures
                val apertures = chars.get(CameraCharacteristics.LENS_INFO_AVAILABLE_APERTURES)?.toList() ?: emptyList()

                // ISO sensitivity range
                val isoRange = chars.get(CameraCharacteristics.SENSOR_INFO_SENSITIVITY_RANGE)
                val isoMin = isoRange?.lower ?: 0
                val isoMax = isoRange?.upper ?: 0

                // Flash available
                val hasFlash = chars.get(CameraCharacteristics.FLASH_INFO_AVAILABLE) ?: false

                // Optical image stabilization
                val oisModes = chars.get(CameraCharacteristics.LENS_INFO_AVAILABLE_OPTICAL_STABILIZATION)?.toList() ?: emptyList()
                val hasOis = oisModes.contains(CameraCharacteristics.LENS_OPTICAL_STABILIZATION_MODE_ON)

                // Capabilities (RAW support, etc.)
                val capabilities = chars.get(CameraCharacteristics.REQUEST_AVAILABLE_CAPABILITIES)?.toList() ?: emptyList()
                val supportsRaw = capabilities.contains(CameraCharacteristics.REQUEST_AVAILABLE_CAPABILITIES_RAW)

                // Stream configuration (resolutions)
                val map = chars.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
                val jpegSizes = map?.getOutputSizes(ImageFormat.JPEG)?.map { "${it.width}x${it.height}" } ?: emptyList()

                cameraList.add(
                    mapOf(
                        "id" to id,
                        "facing" to facingStr,
                        "hardwareLevel" to hwLevelStr,
                        "megapixels" to megapixels,
                        "sensorWidth" to activeWidth,
                        "sensorHeight" to activeHeight,
                        "physicalSensorSize" to sensorSizeStr,
                        "focalLengths" to focalLengths,
                        "apertures" to apertures,
                        "isoMin" to isoMin,
                        "isoMax" to isoMax,
                        "hasFlash" to hasFlash,
                        "hasOis" to hasOis,
                        "supportsRaw" to supportsRaw,
                        "resolutionsCount" to jpegSizes.size,
                        "supportedResolutions" to jpegSizes.take(10) // top 10 resolutions
                    )
                )
            } catch (_: Exception) {
                // Ignore restricted camera ID
            }
        }

        return mapOf(
            "camerasCount" to cameraList.size,
            "cameras" to cameraList
        )
    }
}
