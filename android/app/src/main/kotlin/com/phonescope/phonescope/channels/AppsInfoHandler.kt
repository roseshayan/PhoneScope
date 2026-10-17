package com.phonescope.phonescope.channels

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AppsInfoHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getInstalledApps" -> {
                try {
                    val includeSystem = call.argument<Boolean>("includeSystem") ?: true
                    val apps = getAppsList(includeSystem)
                    result.success(apps)
                } catch (e: Exception) {
                    result.error("APPS_INFO_ERROR", e.localizedMessage, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getAppsList(includeSystem: Boolean): List<Map<String, Any?>> {
        val pm = context.packageManager
        val flags = PackageManager.GET_PERMISSIONS
        val packages: List<PackageInfo> = pm.getInstalledPackages(flags)
        val result = mutableListOf<Map<String, Any?>>()

        for (pkg in packages) {
            val appInfo = pkg.applicationInfo ?: continue
            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            if (!includeSystem && isSystem) continue

            val appName = try {
                appInfo.loadLabel(pm).toString()
            } catch (_: Exception) {
                pkg.packageName
            }

            val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                pkg.longVersionCode
            } else {
                @Suppress("DEPRECATION")
                pkg.versionCode.toLong()
            }

            val minSdk = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                appInfo.minSdkVersion
            } else {
                -1
            }

            val permissions = pkg.requestedPermissions?.toList() ?: emptyList()

            result.add(
                mapOf(
                    "appName" to appName,
                    "packageName" to pkg.packageName,
                    "versionName" to (pkg.versionName ?: "Unknown"),
                    "versionCode" to versionCode,
                    "targetSdk" to appInfo.targetSdkVersion,
                    "minSdk" to minSdk,
                    "isSystemApp" to isSystem,
                    "firstInstallTime" to pkg.firstInstallTime,
                    "lastUpdateTime" to pkg.lastUpdateTime,
                    "permissionsCount" to permissions.size,
                    "permissions" to permissions
                )
            )
        }

        return result
    }
}
