package com.phonescope.phonescope.channels

import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.Inet4Address
import java.net.NetworkInterface

class NetworkInfoHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getNetworkInfo" -> {
                try {
                    val info = getNetworkDetails()
                    result.success(info)
                } catch (e: Exception) {
                    result.error("NETWORK_INFO_ERROR", e.localizedMessage, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun getNetworkDetails(): Map<String, Any?> {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
        val wm = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager

        val activeNetwork = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) cm?.activeNetwork else null
        val caps = if (activeNetwork != null) cm?.getNetworkCapabilities(activeNetwork) else null

        val isConnected = caps != null && caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
        val isWifi = caps?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ?: false
        val isCellular = caps?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) ?: false
        val isVpn = caps?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) ?: false

        val networkTypeStr = when {
            isWifi -> "Wi-Fi"
            isCellular -> "Cellular Mobile Data"
            isVpn -> "VPN"
            caps?.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) == true -> "Ethernet"
            else -> if (isConnected) "Other" else "Disconnected"
        }

        // Wi-Fi Details
        var wifiSsid = "Unavailable"
        var wifiBssid = "Unavailable"
        var linkSpeedMbps = -1
        var rssiDbm = -127
        var frequencyMhz = -1
        var wifiStandard = "Unknown"

        if (isWifi && wm != null) {
            @Suppress("DEPRECATION")
            val wifiInfo: WifiInfo? = wm.connectionInfo
            if (wifiInfo != null) {
                linkSpeedMbps = wifiInfo.linkSpeed
                rssiDbm = wifiInfo.rssi
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    frequencyMhz = wifiInfo.frequency
                }

                // SSID permission check on Android 8+ / 10+
                val hasLocation = ContextCompat.checkSelfPermission(
                    context,
                    android.Manifest.permission.ACCESS_FINE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED

                val rawSsid = wifiInfo.ssid
                wifiSsid = if (rawSsid != null && rawSsid != "<unknown ssid>") {
                    rawSsid.replace("\"", "")
                } else if (!hasLocation) {
                    "Location permission required on Android 10+"
                } else {
                    "Unavailable or Hidden"
                }

                if (hasLocation) {
                    wifiBssid = wifiInfo.bssid ?: "Unavailable"
                } else {
                    wifiBssid = "Permission required"
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    wifiStandard = when (wifiInfo.wifiStandard) {
                        6 -> "Wi-Fi 6 (802.11ax)"
                        5 -> "Wi-Fi 5 (802.11ac)"
                        4 -> "Wi-Fi 4 (802.11n)"
                        1 -> "Legacy (802.11a/b/g)"
                        8 -> "Wi-Fi 7 (802.11be)"
                        else -> if (frequencyMhz > 4900) "5 GHz" else if (frequencyMhz > 0) "2.4 GHz" else "Standard ${wifiInfo.wifiStandard}"
                    }
                } else {
                    wifiStandard = if (frequencyMhz > 4900) "5 GHz (802.11ac/n)" else if (frequencyMhz > 0) "2.4 GHz (802.11n/g)" else "Unknown"
                }
            }
        }

        // Local IP Addresses
        val localIpv4 = getLocalIpv4Address()
        val dnsServers = getDnsServers(cm)

        return mapOf(
            "isConnected" to isConnected,
            "networkType" to networkTypeStr,
            "isWifi" to isWifi,
            "isCellular" to isCellular,
            "isVpn" to isVpn,
            "wifiSsid" to wifiSsid,
            "wifiBssid" to wifiBssid,
            "linkSpeedMbps" to linkSpeedMbps,
            "rssiDbm" to rssiDbm,
            "frequencyMhz" to frequencyMhz,
            "frequencyBand" to (if (frequencyMhz > 5900) "6 GHz" else if (frequencyMhz > 4900) "5 GHz" else if (frequencyMhz > 0) "2.4 GHz" else "Unknown"),
            "wifiStandard" to wifiStandard,
            "localIpv4" to localIpv4,
            "dnsServers" to dnsServers
        )
    }

    private fun getLocalIpv4Address(): String {
        try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            for (intf in interfaces) {
                if (intf.isLoopback || !intf.isUp) continue
                val addrs = intf.inetAddresses
                for (addr in addrs) {
                    if (!addr.isLoopbackAddress && addr is Inet4Address) {
                        return addr.hostAddress ?: "Unknown"
                    }
                }
            }
        } catch (_: Exception) {}
        return "127.0.0.1"
    }

    private fun getDnsServers(cm: ConnectivityManager?): List<String> {
        val list = mutableListOf<String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && cm != null) {
            val activeNetwork = cm.activeNetwork
            if (activeNetwork != null) {
                val linkProps = cm.getLinkProperties(activeNetwork)
                linkProps?.dnsServers?.forEach { dns ->
                    list.add(dns.hostAddress ?: "")
                }
            }
        }
        return list.filter { it.isNotBlank() }
    }
}
