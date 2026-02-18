import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundTaskHandler extends TaskHandler {
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final prefs = await SharedPreferences.getInstance();

      final deviceId = prefs.getString('deviceId');
      final tokenId = prefs.getString('tokenId');
      final customerId = prefs.getString('customerId');

      if (deviceId == null || tokenId == null || customerId == null) return;

      final url =
          'https://newqbitronics.org.in/motorpro/motorvoltvpro/sample.php'
          '?deviceid=$deviceId'
          '&tokenid=$tokenId'
          '&customerid=$customerId';

      try {
        final response = await http.get(Uri.parse(url));
        
        // Store the full response so app can parse on/off time from it
        if (response.statusCode == 200) {
          await prefs.setString('motor_response_$deviceId', response.body);
          await prefs.setString('motor_response_time_$deviceId', 
              DateTime.now().toIso8601String());
        }
      } catch (_) {}
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _timer?.cancel();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}
}
}
