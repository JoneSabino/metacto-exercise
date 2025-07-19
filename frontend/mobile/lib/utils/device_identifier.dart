import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

Future<String> getDeviceIdentifier() async {
  final prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString('deviceId');

  if (deviceId == null) {
    // Generate a simple random ID and store it
    var random = Random.secure();
    var values = List<int>.generate(16, (i) => random.nextInt(256));
    deviceId = 'flutter_user_${base64Url.encode(values)}';
    await prefs.setString('deviceId', deviceId);
    print('Generated new device ID: $deviceId');
  } else {
    print('Retrieved existing device ID: $deviceId');
  }
  return deviceId;
}