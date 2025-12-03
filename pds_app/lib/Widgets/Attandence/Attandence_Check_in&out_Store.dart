// // lib/controllers/attendance_controller.dart
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:pds_app/Widgets/Attandence/attandence.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pds_app/core/Services/Android_id_get.dart';
// import 'package:pds_app/core/Services/token_store.dart';
// import 'package:pds_app/core/apiConfig/config.dart';

// /// Small extension to mimic toPrecision behaviour used earlier.
// extension DoublePrecision on double {
//   /// Returns double rounded to [fraction] decimal places.
//   double toPrecision(int fraction) {
//     if (fraction < 0) return this;
//     final fac = pow(10, fraction).toDouble();
//     return (this * fac).round() / fac;
//   }

//   /// If you ever need string with fixed decimals:
//   String toPrecisionString(int fraction) =>
//       toPrecision(fraction).toStringAsFixed(fraction);
// }

// num pow(num x, int exponent) {
//   // quick local pow to avoid importing 'dart:math' repeatedly.
//   return x == 0 && exponent == 0 ? 1 : x.toDouble().pow(exponent);
// }

// extension NumPow on double {
//   double pow(int exponent) {
//     return double.parse(
//       (this == 0.0 && exponent == 0)
//           ? '1'
//           : (this > 0.0
//                 ? _pow(this, exponent).toString()
//                 : _pow(this, exponent).toString()),
//     );
//   }

//   double _pow(double base, int exp) {
//     double result = 1.0;
//     for (int i = 0; i < exp; i++) result *= base;
//     return result;
//   }
// }

// /// Model for current location data
// class AttendanceLocationData {
//   final double latitude;
//   final double longitude;
//   final bool isMock;
//   final double accuracy;
//   final String address;

//   AttendanceLocationData({
//     required this.latitude,
//     required this.longitude,
//     required this.isMock,
//     required this.accuracy,
//     required this.address,
//   });

//   Map<String, dynamic> toJson() => {
//     'myLatitude': latitude,
//     'myLongitude': longitude,
//     'isMock': isMock.toString(),
//     'accuracy': accuracy,
//     'address': address,
//   };
// }

// class AttendanceController extends GetxController {
//   final attendanceRecord = AttendanceRecord().obs;
//   final isFakeLocation = false.obs;
//   final elapsedTime = '0 hours, 0 minutes'.obs;

//   final Rxn<AttendanceLocationData> lastLocation =
//       Rxn<AttendanceLocationData>();

//   Timer? _timer;
//   Timer? _midnightTimer;

//   static const String _kPersistKey = 'attendance_record_v1';

//   @override
//   void onInit() {
//     super.onInit();
//     _startTimer();
//     _loadPersistedRecord();
//     _scheduleMidnightReset();
//   }

//   @override
//   void onClose() {
//     _timer?.cancel();
//     _midnightTimer?.cancel();
//     super.onClose();
//   }

//   bool _isSameDate(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (attendanceRecord.value.isCheckedIn) {
//         elapsedTime.value = attendanceRecord.value.getElapsedTime();
//       }
//     });
//   }

//   void _scheduleMidnightReset() {
//     _midnightTimer?.cancel();
//     final now = DateTime.now();
//     final tomorrow = DateTime(
//       now.year,
//       now.month,
//       now.day,
//     ).add(const Duration(days: 1));
//     final nextMidnight = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
//     final durationUntilMidnight = nextMidnight.difference(now);
//     _midnightTimer = Timer(durationUntilMidnight, () async {
//       attendanceRecord.value = AttendanceRecord();
//       elapsedTime.value = attendanceRecord.value.getElapsedTime();
//       await _clearPersistedRecord();
//       _scheduleMidnightReset();
//     });
//   }

//   void updateLocation(AttendanceLocationData location) {
//     lastLocation.value = location;
//     isFakeLocation.value = location.isMock;
//   }

//   Future<void> handleCheckIn() async {
//     if (isFakeLocation.value) {
//       Get.snackbar(
//         'Check-in blocked',
//         'Fake GPS detected! Check-in not allowed.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//         backgroundColor: const Color(0xFFDC3545),
//         colorText: Colors.white,
//       );
//       return;
//     }

//     if (lastLocation.value == null) {
//       Get.snackbar(
//         'Location missing',
//         'Unable to get current location. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//       );
//       return;
//     }

//     final now = DateTime.now();
//     final currentRecord = attendanceRecord.value;

//     if (currentRecord.checkInTime != null &&
//         _isSameDate(currentRecord.checkInTime!, now)) {
//       Get.snackbar(
//         'Already checked in',
//         'You have already checked in for today.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//       );
//       return;
//     }

//     final record = AttendanceRecord(
//       checkInTime: now,
//       checkOutTime: null,
//       isCheckedIn: true,
//     );

//     attendanceRecord.value = record;
//     elapsedTime.value = record.getElapsedTime();

//     await _persistRecord(record);

//     _sendAttendanceToBackend(action: 'check_in');
//   }

//   Future<void> handleCheckOut() async {
//     final currentRecord = attendanceRecord.value;
//     final now = DateTime.now();

//     if (currentRecord.checkInTime == null ||
//         !_isSameDate(currentRecord.checkInTime!, now)) {
//       Get.snackbar(
//         'No active check-in',
//         'You have not checked in today.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//       );
//       return;
//     }

//     final updated = currentRecord.copyWith(
//       checkOutTime: now,
//       isCheckedIn: false,
//     );

//     attendanceRecord.value = updated;
//     elapsedTime.value = updated.getElapsedTime();

//     await _persistRecord(updated);

//     _sendAttendanceToBackend(action: 'check_out');
//   }

//   Future<void> _sendAttendanceToBackend({required String action}) async {
//     final loc = lastLocation.value;

//     if (loc == null) {
//       debugPrint('No location data available. Skipping API call.');
//       return;
//     }

//     // changed to final (cannot be const because ApiConfig.baseUrl is runtime)
//     final String apiUrl = '${ApiConfig.baseUrl}/attandance/mark_attandance';

//     final String? androidId = await DeviceInfoService.getAndroidId();
//     final String? authToken = await TokenStorage.getToken();

//     final payload = <String, dynamic>{
//       'myLatitude': loc.latitude,
//       'myLongitude': loc.longitude,
//       'isMock': loc.isMock.toString(),
//       'address': loc.address,
//       'accuracy': loc.accuracy,
//       'buildNumber': androidId,
//       'type': action == 'check_in' ? 'CHECK-IN' : 'CHECK-OUT',
//     };

//     debugPrint('Sending attendance payload: $payload');

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $authToken',
//         },
//         body: jsonEncode(payload),
//       );
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         debugPrint('Attendance saved successfully');
//       } else {
//         debugPrint(
//           'Attendance API failed: ${response.statusCode} ${response.body}',
//         );
//         Get.snackbar(
//           'Server error',
//           'Unable to save attendance. Please try again.',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       }
//     } catch (e) {
//       debugPrint('Attendance API error: $e');
//       Get.snackbar(
//         'Network error',
//         'Failed to connect to server.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }

//   Future<void> _persistRecord(AttendanceRecord record) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final Map<String, dynamic> m = {
//         'checkInTime': record.checkInTime?.toIso8601String(),
//         'checkOutTime': record.checkOutTime?.toIso8601String(),
//         'isCheckedIn': record.isCheckedIn,
//       };
//       await prefs.setString(_kPersistKey, jsonEncode(m));
//       debugPrint('Persisted attendance: $m');
//     } catch (e) {
//       debugPrint('Error persisting attendance: $e');
//     }
//   }

//   Future<void> _clearPersistedRecord() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_kPersistKey);
//       debugPrint('Cleared persisted attendance');
//     } catch (e) {
//       debugPrint('Error clearing persisted attendance: $e');
//     }
//   }

//   Future<void> _loadPersistedRecord() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final jsonStr = prefs.getString(_kPersistKey);
//       if (jsonStr == null || jsonStr.isEmpty) {
//         return;
//       }
//       final Map<String, dynamic> m = jsonDecode(jsonStr);
//       final String? checkInStr = m['checkInTime'];
//       final String? checkOutStr = m['checkOutTime'];
//       final bool isCheckedIn = m['isCheckedIn'] == true;

//       final DateTime? checkInTime = checkInStr != null
//           ? DateTime.parse(checkInStr).toLocal()
//           : null;
//       final DateTime? checkOutTime = checkOutStr != null
//           ? DateTime.parse(checkOutStr).toLocal()
//           : null;

//       final now = DateTime.now();

//       if (checkInTime != null && _isSameDate(checkInTime, now)) {
//         final restored = AttendanceRecord(
//           checkInTime: checkInTime,
//           checkOutTime: checkOutTime,
//           isCheckedIn: isCheckedIn,
//         );
//         attendanceRecord.value = restored;
//         elapsedTime.value = restored.getElapsedTime();
//         debugPrint('Restored attendance for today: $m');
//       } else {
//         await _clearPersistedRecord();
//         debugPrint('Persisted attendance was for previous date; cleared.');
//       }
//     } catch (e) {
//       debugPrint('Error loading persisted attendance: $e');
//     }
//   }
// }
