import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoHelper {
  static Future<String> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand}_${androidInfo.model}_${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name}_${iosInfo.model}_${iosInfo.identifierForVendor}';
      } else {
        return '${Platform.operatingSystem}_${Platform.operatingSystemVersion}';
      }
    } catch (e) {
      return 'Unknown_Device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}
