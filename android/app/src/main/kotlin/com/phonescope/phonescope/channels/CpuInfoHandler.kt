package com.phonescope.phonescope.channels

import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.RandomAccessFile

class CpuInfoHandler : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getCpuInfo" -> {
                try {
                    val info = getCpuDetails()
                    result.success(info)
                } catch (e: Exception) {
                    result.error("CPU_INFO_ERROR", e.localizedMessage, null)
                }
            }
            "getCpuLiveFrequencies" -> {
                try {
                    val freqs = getLiveFrequencies()
                    result.success(freqs)
                } catch (e: Exception) {
                    result.error("CPU_FREQ_ERROR", e.localizedMessage, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getCpuDetails(): Map<String, Any?> {
        val coreCount = Runtime.getRuntime().availableProcessors()
        val coresInfo = mutableListOf<Map<String, Any?>>()

        for (i in 0 until coreCount) {
            val minFreqKHz = readSysfsLong("/sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_min_freq")
            val maxFreqKHz = readSysfsLong("/sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq")
            val curFreqKHz = readSysfsLong("/sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq")
            val governor = readSysfsString("/sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor")

            coresInfo.add(
                mapOf(
                    "coreIndex" to i,
                    "minFreqKHz" to (if (minFreqKHz > 0) minFreqKHz else null),
                    "maxFreqKHz" to (if (maxFreqKHz > 0) maxFreqKHz else null),
                    "curFreqKHz" to (if (curFreqKHz > 0) curFreqKHz else null),
                    "governor" to (governor.ifEmpty { "Unavailable" })
                )
            )
        }

        val procCpuInfo = parseProcCpuinfo()
        val clusters = groupCoresIntoClusters(coresInfo)

        return mapOf(
            "coresCount" to coreCount,
            "architecture" to (System.getProperty("os.arch") ?: Build.SUPPORTED_ABIS.firstOrNull() ?: "Unknown"),
            "abi" to (Build.SUPPORTED_ABIS.firstOrNull() ?: "Unknown"),
            "cores" to coresInfo,
            "clusters" to clusters,
            "hardware" to procCpuInfo["Hardware"],
            "features" to procCpuInfo["Features"],
            "modelName" to procCpuInfo["model name"],
            "procCpuInfoAccessible" to procCpuInfo.isNotEmpty()
        )
    }

    private fun getLiveFrequencies(): List<Map<String, Any?>> {
        val coreCount = Runtime.getRuntime().availableProcessors()
        val list = mutableListOf<Map<String, Any?>>()
        for (i in 0 until coreCount) {
            var curFreq = readSysfsLong("/sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq")
            if (curFreq <= 0) {
                // Try reading scaling_max_freq as fallback reference if cur is restricted
                curFreq = readSysfsLong("/sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_cur_freq")
            }
            list.add(
                mapOf(
                    "coreIndex" to i,
                    "curFreqKHz" to (if (curFreq > 0) curFreq else null),
                    "isRestricted" to (curFreq <= 0)
                )
            )
        }
        return list
    }

    private fun groupCoresIntoClusters(cores: List<Map<String, Any?>>): List<Map<String, Any?>> {
        val grouped = mutableMapOf<Long, MutableList<Int>>()
        for (core in cores) {
            val idx = core["coreIndex"] as Int
            val maxFreq = (core["maxFreqKHz"] as? Long) ?: 0L
            grouped.getOrPut(maxFreq) { mutableListOf() }.add(idx)
        }

        val sortedGroups = grouped.entries.sortedBy { it.key }
        return sortedGroups.mapIndexed { index, entry ->
            val clusterType = when {
                sortedGroups.size == 1 -> "Unified"
                sortedGroups.size == 2 && index == 0 -> "Efficiency (LITTLE)"
                sortedGroups.size == 2 && index == 1 -> "Performance (big)"
                sortedGroups.size == 3 && index == 0 -> "Efficiency (LITTLE)"
                sortedGroups.size == 3 && index == 1 -> "Performance (Mid)"
                sortedGroups.size == 3 && index == 2 -> "Prime (Super Core)"
                else -> "Cluster ${index + 1}"
            }
            mapOf(
                "clusterName" to clusterType,
                "maxFreqKHz" to entry.key,
                "cores" to entry.value
            )
        }
    }

    private fun parseProcCpuinfo(): Map<String, String> {
        val map = mutableMapOf<String, String>()
        try {
            val file = File("/proc/cpuinfo")
            if (file.exists() && file.canRead()) {
                file.forEachLine { line ->
                    val parts = line.split(":")
                    if (parts.size >= 2) {
                        val key = parts[0].trim()
                        val value = parts[1].trim()
                        if (!map.containsKey(key)) {
                            map[key] = value
                        }
                    }
                }
            }
        } catch (_: Exception) {
            // SELinux policy blocks /proc/cpuinfo access on modern Android
        }
        return map
    }

    private fun readSysfsLong(path: String): Long {
        return try {
            val file = File(path)
            if (file.exists() && file.canRead()) {
                file.readText().trim().toLongOrNull() ?: 0L
            } else {
                0L
            }
        } catch (_: Exception) {
            0L
        }
    }

    private fun readSysfsString(path: String): String {
        return try {
            val file = File(path)
            if (file.exists() && file.canRead()) {
                file.readText().trim()
            } else {
                ""
            }
        } catch (_: Exception) {
            ""
        }
    }
}
