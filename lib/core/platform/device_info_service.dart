import 'dart:async';

import 'package:flutter/services.dart';

import '../constants/channel_constants.dart';
import '../../features/system/models/system_info_model.dart';
import '../../features/soc/models/cpu_info_model.dart';
import '../../features/gpu/models/gpu_info_model.dart';
import '../../features/memory/models/memory_storage_model.dart';
import '../../features/battery/models/battery_info_model.dart';
import '../../features/thermal/models/thermal_info_model.dart';
import '../../features/display/models/display_info_model.dart';
import '../../features/camera/models/camera_info_model.dart';
import '../../features/sensors/models/sensor_info_model.dart';
import '../../features/network/models/network_info_model.dart';
import '../../features/apps/models/app_info_model.dart';

class DeviceInfoService {
  static const MethodChannel _systemChannel = MethodChannel(
    ChannelConstants.system,
  );
  static const MethodChannel _cpuChannel = MethodChannel(ChannelConstants.cpu);
  static const MethodChannel _gpuChannel = MethodChannel(ChannelConstants.gpu);
  static const MethodChannel _memStorageChannel = MethodChannel(
    ChannelConstants.memoryStorage,
  );
  static const MethodChannel _batteryChannel = MethodChannel(
    ChannelConstants.battery,
  );
  static const EventChannel _batteryEventChannel = EventChannel(
    ChannelConstants.batteryStream,
  );
  static const MethodChannel _thermalChannel = MethodChannel(
    ChannelConstants.thermal,
  );
  static const EventChannel _thermalEventChannel = EventChannel(
    ChannelConstants.thermalStream,
  );
  static const MethodChannel _displayChannel = MethodChannel(
    ChannelConstants.display,
  );
  static const MethodChannel _cameraChannel = MethodChannel(
    ChannelConstants.camera,
  );
  static const MethodChannel _sensorsChannel = MethodChannel(
    ChannelConstants.sensors,
  );
  static const EventChannel _sensorsEventChannel = EventChannel(
    ChannelConstants.sensorsStream,
  );
  static const MethodChannel _networkChannel = MethodChannel(
    ChannelConstants.network,
  );
  static const MethodChannel _appsChannel = MethodChannel(
    ChannelConstants.apps,
  );
  static const MethodChannel _hardwareTestChannel = MethodChannel(
    ChannelConstants.hardwareTest,
  );
  static const MethodChannel _shareChannel = MethodChannel(
    ChannelConstants.share,
  );

  // System
  Future<SystemInfoModel> getSystemInfo() async {
    final result = await _systemChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getSystemInfo',
    );
    return SystemInfoModel.fromMap(result ?? {});
  }

  // CPU & SoC
  Future<CpuInfoModel> getCpuInfo() async {
    final result = await _cpuChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getCpuInfo',
    );
    return CpuInfoModel.fromMap(result ?? {});
  }

  Future<List<Map<String, dynamic>>> getCpuLiveFrequencies() async {
    final result = await _cpuChannel.invokeListMethod<Map<dynamic, dynamic>>(
      'getCpuLiveFrequencies',
    );
    return (result ?? []).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // GPU
  Future<GpuInfoModel> getGpuInfo() async {
    final result = await _gpuChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getGpuInfo',
    );
    return GpuInfoModel.fromMap(result ?? {});
  }

  // Memory & Storage
  Future<MemoryInfoModel> getMemoryInfo() async {
    final result = await _memStorageChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getMemoryInfo',
    );
    return MemoryInfoModel.fromMap(result ?? {});
  }

  Future<StorageInfoModel> getStorageInfo() async {
    final result = await _memStorageChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getStorageInfo',
    );
    return StorageInfoModel.fromMap(result ?? {});
  }

  // Battery
  Future<BatteryInfoModel> getBatteryInfo() async {
    final result = await _batteryChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getBatteryInfo',
    );
    return BatteryInfoModel.fromMap(result ?? {});
  }

  Stream<BatteryInfoModel> get batteryStream {
    return _batteryEventChannel.receiveBroadcastStream().map((event) {
      return BatteryInfoModel.fromMap(event as Map<dynamic, dynamic>);
    });
  }

  // Thermal
  Future<ThermalInfoModel> getThermalInfo() async {
    final result = await _thermalChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getThermalInfo',
    );
    return ThermalInfoModel.fromMap(result ?? {});
  }

  Stream<Map<String, dynamic>> get thermalStream {
    return _thermalEventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }

  // Display
  Future<DisplayInfoModel> getDisplayInfo() async {
    final result = await _displayChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getDisplayInfo',
    );
    return DisplayInfoModel.fromMap(result ?? {});
  }

  // Camera
  Future<CameraInfoModel> getCameraInfo() async {
    final result = await _cameraChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getCameraInfo',
    );
    return CameraInfoModel.fromMap(result ?? {});
  }

  // Sensors
  Future<List<SensorInfoModel>> getSensorsList() async {
    final result = await _sensorsChannel
        .invokeListMethod<Map<dynamic, dynamic>>('getSensorsList');
    return (result ?? []).map((e) => SensorInfoModel.fromMap(e)).toList();
  }

  Stream<SensorEventData> getLiveSensorStream(int sensorType) {
    return _sensorsEventChannel
        .receiveBroadcastStream({'sensorType': sensorType})
        .map((event) {
          return SensorEventData.fromMap(event as Map<dynamic, dynamic>);
        });
  }

  // Network
  Future<NetworkInfoModel> getNetworkInfo() async {
    final result = await _networkChannel.invokeMethod<Map<dynamic, dynamic>>(
      'getNetworkInfo',
    );
    return NetworkInfoModel.fromMap(result ?? {});
  }

  // Apps
  Future<List<AppInfoModel>> getInstalledApps({
    bool includeSystem = true,
  }) async {
    final result = await _appsChannel.invokeListMethod<Map<dynamic, dynamic>>(
      'getInstalledApps',
      {'includeSystem': includeSystem},
    );
    return (result ?? []).map((e) => AppInfoModel.fromMap(e)).toList();
  }

  // Hardware Tests
  Future<bool> setFlashlight(bool enable) async {
    final result = await _hardwareTestChannel.invokeMethod<bool>(
      'setFlashlight',
      {'enable': enable},
    );
    return result ?? false;
  }

  Future<bool> vibrate({String type = 'short', int durationMs = 300}) async {
    final result = await _hardwareTestChannel.invokeMethod<bool>('vibrate', {
      'type': type,
      'durationMs': durationMs,
    });
    return result ?? false;
  }

  Future<bool> cancelVibration() async {
    final result = await _hardwareTestChannel.invokeMethod<bool>(
      'cancelVibration',
    );
    return result ?? false;
  }

  Future<bool> playTestTone({
    double frequency = 440.0,
    double durationSeconds = 1.5,
  }) async {
    final result = await _hardwareTestChannel.invokeMethod<bool>(
      'playTestTone',
      {'frequency': frequency, 'durationSeconds': durationSeconds},
    );
    return result ?? false;
  }

  Future<bool> stopTestTone() async {
    final result = await _hardwareTestChannel.invokeMethod<bool>(
      'stopTestTone',
    );
    return result ?? false;
  }

  Future<double> getMicAmplitude() async {
    final result = await _hardwareTestChannel.invokeMethod<double>(
      'getMicAmplitude',
    );
    return result ?? 0.0;
  }

  // Share
  Future<bool> shareFile(
    String filePath, {
    String mimeType = '*/*',
    String title = 'PhoneScope',
  }) async {
    final result = await _shareChannel.invokeMethod<bool>('shareFile', {
      'filePath': filePath,
      'mimeType': mimeType,
      'title': title,
    });
    return result ?? false;
  }

  Future<bool> shareText(String text, {String title = 'PhoneScope'}) async {
    final result = await _shareChannel.invokeMethod<bool>('shareText', {
      'text': text,
      'title': title,
    });
    return result ?? false;
  }
}
