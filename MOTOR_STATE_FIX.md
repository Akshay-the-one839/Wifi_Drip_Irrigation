# Motor State Timestamp Fix - Implementation Guide

## Problem Statement
When you manually turn off the motor at 12:33 PM and then open the app at 12:37 PM, the app was displaying the off time as 12:37 PM instead of the actual time (12:33 PM). This occurred because the app only recorded the time when it fetched the device state, not when the state actually changed.

## Root Cause
- The app was fetching the motor state from the server but not recording **when** the state changed
- When you reopened the app, it would fetch the current state and use the current time
- The actual timestamp of when the manual off event occurred was lost

## Solution Overview
The fix involves two main components:

### 1. **Background Task Enhancement** (background_task.dart)
The background task now:
- Fetches the motor status periodically (every minute)
- Compares with the previous state
- Records the **timestamp of state changes** (not just the current time when fetching)
- Stores both the current state AND when it changed

Key addition:
```dart
// Store current state and its timestamp
await prefs.setString('motor_state_$deviceId', currentState);
await prefs.setString('motor_state_time_$deviceId', timestamp);
```

### 2. **Motor State Manager Utility** (utils/motor_state_manager.dart)
New utility class provides:
- `getLastStateChangeTime()` - Retrieves the stored timestamp
- `getCurrentState()` - Retrieves the motor state
- `getStateChangeMessage()` - Returns formatted message like "OFF since 12:33 PM"
- `setMotorState()` - For manual state changes

### 3. **UI Display** (device_token_screen.dart)
- Added motor status widget that displays the state change time
- Shows message like: "OFF since 12:33 PM" or "ON since 2:45 PM"

## Files Modified

### 1. `lib/background_task.dart`
**Changes:**
- Added `_trackStateChange()` method to detect and record state changes
- Added `_parseMotorState()` method to extract motor status from API response
- Now stores timestamps when state changes occur

**Note:** You need to update `_parseMotorState()` method based on your actual API response format!

### 2. `lib/utils/motor_state_manager.dart` (NEW FILE)
**Purpose:** Centralized utility for managing and retrieving motor state information

**Main Methods:**
- `getLastStateChangeTime(String deviceId)` - Get the timestamp string
- `getCurrentState(String deviceId)` - Get current state (on/off)
- `getStateChangeMessage(String deviceId)` - Get formatted display message
- `setMotorState(String deviceId, String state)` - Manually set state

### 3. `lib/screens/device_token_screen.dart`
**Changes:**
- Added import for `MotorStateManager`
- Added `_buildMotorStatusWidget()` to display motor status
- Added `_getDeviceId()` helper method
- Widget displays in the UI between token ID field and save button

### 4. `pubspec.yaml`
**Changes:**
- Added dependency: `intl: ^0.19.0` for date formatting

## Important Note: API Response Parsing

The `_parseMotorState()` method in `background_task.dart` needs to be customized for your API!

**Current placeholder implementation:**
```dart
String _parseMotorState(String responseBody) {
  try {
    if (responseBody.contains('status=1') || responseBody.contains('"status":1')) {
      return 'on';
    } else if (responseBody.contains('status=0') || responseBody.contains('"status":0')) {
      return 'off';
    }
  } catch (_) {}
  return 'unknown';
}
```

**To customize:**
1. Check exactly what your API returns (e.g., JSON, XML, query string)
2. Adjust the parsing logic to extract the motor status correctly
3. Return either `'on'` or `'off'` as the state

**Example:** If your API returns JSON like `{"status": 1, "power": 230}`:
```dart
String _parseMotorState(String responseBody) {
  try {
    final decoded = jsonDecode(responseBody);
    return decoded['status'] == 1 ? 'on' : 'off';
  } catch (_) {}
  return 'unknown';
}
```

## How It Works - Step by Step

### When Motor State Changes (via any method):
1. Background task fetches status from API every minute
2. Compares with previous state
3. If changed → stores new state + current timestamp
4. State persists even if app is closed

### When User Opens App:
1. Device token screen loads
2. `_buildMotorStatusWidget()` is called
3. Manager retrieves stored state and timestamp
4. Displays formatted message like "OFF since 12:33 PM"

## Testing the Fix

### Test Case 1: Manual Off Event (Your Scenario)
1. Turn on motor at 12:30 PM via app
2. Close the app
3. Manually turn off motor at 12:33 PM
4. Open app at 12:37 PM
5. ✅ Should show "OFF since 12:33 PM" (not 12:37 PM)

### Test Case 2: App-Based Action
1. Turn off motor via app at 3:45 PM
2. Close and reopen app immediately
3. ✅ Should show "OFF since 3:45 PM"

### Test Case 3: Persistence
1. Turn off motor at 5:00 PM
2. Reboot device
3. Open app after reboot
4. ✅ Should still show "OFF since 5:00 PM"

## Next Steps (Optional Enhancements)

1. **Show Full Timestamp:** Modify `getStateChangeMessage()` to show full date/time for old state changes
2. **Add Manual Controls:** Add ON/OFF buttons that use `MotorStateManager.setMotorState()`
3. **Add Duration Tracking:** Show "OFF for 2 hours 15 minutes"
4. **Add State History:** Store multiple state changes in a list

## Troubleshooting

**Issue:** Still showing wrong time
- Check that `_parseMotorState()` correctly extracts motor status from your API
- Verify background service is running (foreground task)

**Issue:** State not updating
- Ensure SharedPreferences keys match between background_task.dart and motor_state_manager.dart
- Check that background task interval (currently 1 minute) works for your needs

**Issue:** Import errors
- Run `flutter pub get` to install the `intl` package
- Ensure all file paths are correct

