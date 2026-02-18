import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MotorStateManager {
  /// Get the last recorded state change time for a motor
  static Future<String?> getLastStateChangeTime(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('motor_state_time_$deviceId');
  }

  /// Get the current state of the motor
  static Future<String> getCurrentState(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('motor_state_$deviceId') ?? 'unknown';
  }

  /// Get formatted state change message (e.g., "OFF since 12:33 PM")
  static Future<String> getStateChangeMessage(String deviceId) async {
    final state = await getCurrentState(deviceId);
    final timeStr = await getLastStateChangeTime(deviceId);
    
    if (timeStr == null) {
      return 'Status: ${state.toUpperCase()}';
    }
    
    try {
      final dateTime = DateTime.parse(timeStr);
      final formatter = DateFormat('h:mm a'); // 12:33 PM format
      final formattedTime = formatter.format(dateTime);
      return '${state.toUpperCase()} since $formattedTime';
    } catch (_) {
      return 'Status: ${state.toUpperCase()}';
    }
  }

  /// Manually set motor state and timestamp (useful for manual on/off buttons)
  static Future<void> setMotorState(
    String deviceId,
    String state,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    await prefs.setString('motor_state_$deviceId', state);
    await prefs.setString('motor_state_time_$deviceId', now.toIso8601String());
  }
}
