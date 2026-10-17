package com.phonescope.phonescope.channels

import android.content.Context
import android.os.Build
import android.os.Process
import android.os.SystemClock
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.File
import java.io.FileReader

class SystemInfoHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getSystemInfo" -> {
                try {
                    val info = getSystemDetails()
                    result.success(info)
                } catch (e: Exception) {
                    result.error("SYSTEM_INFO_ERROR", e.localizedMessage, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getSystemDetails(): Map<String, Any?> {
        val rootInfo = checkRootHeuristics()
        val kernelVersion = getKernelVersion()

        val securityPatch = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Build.VERSION.SECURITY_PATCH
        } else {
            "Unavailable"
        }

        val socModel = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                Build.SOC_MODEL
            } catch (t: Throwable) {
                "Unavailable"
            }
        } else {
            "Not supported before Android 12"
        }

        val socManufacturer = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                Build.SOC_MANUFACTURER
            } catch (t: Throwable) {
                "Unavailable"
            }
        } else {
            "Not supported before Android 12"
        }

        val is64Bit = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Process.is64Bit()
        } else {
            Build.SUPPORTED_64_BIT_ABIS.isNotEmpty()
        }

        return mapOf(
            "manufacturer" to Build.MANUFACTURER,
            "brand" to Build.BRAND,
            "model" to Build.MODEL,
            "device" to Build.DEVICE,
            "product" to Build.PRODUCT,
            "board" to Build.BOARD,
            "hardware" to Build.HARDWARE,
            "androidVersion" to Build.VERSION.RELEASE,
            "apiLevel" to Build.VERSION.SDK_INT,
            "securityPatch" to securityPatch,
            "buildId" to Build.DISPLAY,
            "fingerprint" to Build.FINGERPRINT,
            "bootloader" to Build.BOOTLOADER,
            "supportedAbis" to Build.SUPPORTED_ABIS.toList(),
            "supported32BitAbis" to Build.SUPPORTED_32_BIT_ABIS.toList(),
            "supported64BitAbis" to Build.SUPPORTED_64_BIT_ABIS.toList(),
            "is64Bit" to is64Bit,
            "kernelVersion" to kernelVersion,
            "socModel" to socModel,
            "socManufacturer" to socManufacturer,
            "buildType" to Build.TYPE,
            "buildTags" to Build.TAGS,
            "uptimeMillis" to SystemClock.elapsedRealtime(),
            "isRootedHeuristic" to rootInfo["isRooted"],
            "rootCheckDetails" to rootInfo["details"]
        )
    }

    private fun getKernelVersion(): String {
        return try {
            val file = File("/proc/version")
            if (file.exists() && file.canRead()) {
                BufferedReader(FileReader(file)).use { it.readLine() ?: "Unknown" }
            } else {
                System.getProperty("os.version") ?: "Unknown"
            }
        } catch (e: Exception) {
            System.getProperty("os.version") ?: "Unknown"
        }
    }

    private fun checkRootHeuristics(): Map<String, Any> {
        val signs = mutableListOf<String>()

        // 1. Check build tags for test-keys
        val tags = Build.TAGS
        if (tags != null && tags.contains("test-keys")) {
            signs.add("Build tags contain test-keys")
        }

        // 2. Check for common su paths
        val suPaths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su"
        )
        for (path in suPaths) {
            try {
                if (File(path).exists()) {
                    signs.add("SU binary found at: $path")
                }
            } catch (_: Exception) {
                // Ignore security exceptions
            }
        }

        // 3. Check for Magisk / SuperSU app packages if visible
        val pm = context.packageManager
        val knownRootPackages = arrayOf("com.topjohnwu.magisk", "eu.chainfire.supersu")
        for (pkg in knownRootPackages) {
            try {
                pm.getPackageInfo(pkg, 0)
                signs.add("Root manager package found: $pkg")
            } catch (_: Exception) {
                // Not found
            }
        }

        return mapOf(
            "isRooted" to signs.isNotEmpty(),
            "details" to signs
        )
    }
}
