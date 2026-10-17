package com.phonescope.phonescope.channels

import android.app.ActivityManager
import android.content.Context
import android.os.Environment
import android.os.StatFs
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MemoryStorageHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getMemoryInfo" -> {
                try {
                    val mem = getMemoryDetails()
                    result.success(mem)
                } catch (e: Exception) {
                    result.error("MEMORY_INFO_ERROR", e.localizedMessage, null)
                }
            }
            "getStorageInfo" -> {
                try {
                    val storage = getStorageDetails()
                    result.success(storage)
                } catch (e: Exception) {
                    result.error("STORAGE_INFO_ERROR", e.localizedMessage, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getMemoryDetails(): Map<String, Any?> {
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        am.getMemoryInfo(memInfo)

        val rt = Runtime.getRuntime()
        val appUsed = rt.totalMemory() - rt.freeMemory()

        return mapOf(
            "totalMemBytes" to memInfo.totalMem,
            "availMemBytes" to memInfo.availMem,
            "thresholdBytes" to memInfo.threshold,
            "isLowMemory" to memInfo.lowMemory,
            "appHeapAllocatedBytes" to rt.totalMemory(),
            "appHeapFreeBytes" to rt.freeMemory(),
            "appHeapMaxBytes" to rt.maxMemory(),
            "appUsedBytes" to appUsed
        )
    }

    private fun getStorageDetails(): Map<String, Any?> {
        // Internal Storage
        val dataDir = Environment.getDataDirectory()
        val internalStat = StatFs(dataDir.path)
        val internalTotal = internalStat.totalBytes
        val internalAvail = internalStat.availableBytes
        val internalFree = internalStat.freeBytes

        // External Storage / SD Cards
        val externalVolumes = mutableListOf<Map<String, Any?>>()
        val externalDirs = ContextCompat.getExternalFilesDirs(context, null)

        for (dir in externalDirs) {
            if (dir != null) {
                try {
                    val stat = StatFs(dir.path)
                    val isRemovable = Environment.isExternalStorageRemovable(dir)
                    val isEmulated = Environment.isExternalStorageEmulated(dir)
                    val total = stat.totalBytes
                    val avail = stat.availableBytes
                    externalVolumes.add(
                        mapOf(
                            "path" to dir.absolutePath,
                            "isRemovable" to isRemovable,
                            "isEmulated" to isEmulated,
                            "totalBytes" to total,
                            "availableBytes" to avail,
                            "type" to (if (isRemovable) "SD Card / Removable" else "Primary External / Shared")
                        )
                    )
                } catch (_: Exception) {
                    // Ignore volume error
                }
            }
        }

        return mapOf(
            "internalTotalBytes" to internalTotal,
            "internalAvailableBytes" to internalAvail,
            "internalFreeBytes" to internalFree,
            "externalVolumes" to externalVolumes
        )
    }
}
