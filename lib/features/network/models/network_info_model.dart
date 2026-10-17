class NetworkInfoModel {
  final bool isConnected;
  final String networkType;
  final bool isWifi;
  final bool isCellular;
  final bool isVpn;
  final String wifiSsid;
  final String wifiBssid;
  final int linkSpeedMbps;
  final int rssiDbm;
  final int frequencyMhz;
  final String frequencyBand;
  final String wifiStandard;
  final String localIpv4;
  final List<String> dnsServers;

  const NetworkInfoModel({
    required this.isConnected,
    required this.networkType,
    required this.isWifi,
    required this.isCellular,
    required this.isVpn,
    required this.wifiSsid,
    required this.wifiBssid,
    required this.linkSpeedMbps,
    required this.rssiDbm,
    required this.frequencyMhz,
    required this.frequencyBand,
    required this.wifiStandard,
    required this.localIpv4,
    required this.dnsServers,
  });

  factory NetworkInfoModel.fromMap(Map<dynamic, dynamic> map) {
    return NetworkInfoModel(
      isConnected: map['isConnected'] as bool? ?? false,
      networkType: map['networkType'] as String? ?? 'Disconnected',
      isWifi: map['isWifi'] as bool? ?? false,
      isCellular: map['isCellular'] as bool? ?? false,
      isVpn: map['isVpn'] as bool? ?? false,
      wifiSsid: map['wifiSsid'] as String? ?? 'Unavailable',
      wifiBssid: map['wifiBssid'] as String? ?? 'Unavailable',
      linkSpeedMbps: map['linkSpeedMbps'] as int? ?? -1,
      rssiDbm: map['rssiDbm'] as int? ?? -127,
      frequencyMhz: map['frequencyMhz'] as int? ?? -1,
      frequencyBand: map['frequencyBand'] as String? ?? 'Unknown',
      wifiStandard: map['wifiStandard'] as String? ?? 'Unknown',
      localIpv4: map['localIpv4'] as String? ?? '127.0.0.1',
      dnsServers:
          (map['dnsServers'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isConnected': isConnected,
      'networkType': networkType,
      'isWifi': isWifi,
      'isCellular': isCellular,
      'wifiSsid': wifiSsid,
      'linkSpeedMbps': linkSpeedMbps,
      'rssiDbm': rssiDbm,
      'frequencyBand': frequencyBand,
      'wifiStandard': wifiStandard,
      'localIpv4': localIpv4,
      'dnsServers': dnsServers,
    };
  }
}
