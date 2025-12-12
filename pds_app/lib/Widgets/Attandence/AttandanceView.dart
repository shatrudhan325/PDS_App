// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pds_app/Widgets/Attandence/attandence.dart';
// import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
// import 'package:pds_app/features/Location_Get&Finde_Mock/attandenceLocation.dart';
// import 'package:pds_app/core/Services/Android_id_get.dart';
// import 'package:pds_app/core/Services/token_store.dart';
// import 'package:pds_app/core/apiConfig/config.dart';
// import 'Attandance_info_card.dart';
// import 'log_entry_items.dart';

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
//     'latitude': latitude,
//     'longitude': longitude,
//     'isMock': isMock,
//     'accuracy': accuracy,
//     'address': address,
//   };
// }

// /// GetX Controller
// class AttendanceController extends GetxController {
//   final attendanceRecord = AttendanceRecord().obs;
//   final isFakeLocation = false.obs;
//   final elapsedTime = '0 hours, 0 minutes'.obs;

//   final Rxn<AttendanceLocationData> lastLocation =
//       Rxn<AttendanceLocationData>();

//   Timer? _timer;
//   Timer? _midnightTimer;

//   final RxBool _isSending = false.obs;
//   bool get isSending => _isSending.value;

//   static const String _kAttendanceStorageKey = 'user_attendance_record_v1';

//   @override
//   void onInit() {
//     super.onInit();
//     _startTimer();
//     _loadAttendanceFromStorage().then((_) {
//       _scheduleMidnightReset();
//     });
//   }

//   @override
//   void onClose() {
//     _timer?.cancel();
//     _midnightTimer?.cancel();
//     super.onClose();
//   }

//   /// Compare only date part (year, month, day)
//   bool _isSameDate(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   /// Start elapsed timer
//   void _startTimer() {
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (attendanceRecord.value.isCheckedIn) {
//         elapsedTime.value = attendanceRecord.value.getElapsedTime();
//       }
//     });
//   }

//   /// Persist the attendanceRecord to SharedPreferences as JSON
//   Future<void> _saveAttendanceToStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final map = _attendanceRecordToMap(attendanceRecord.value);
//       final jsonStr = jsonEncode(map);
//       await prefs.setString(_kAttendanceStorageKey, jsonStr);
//       debugPrint('Attendance saved to storage: $jsonStr');
//     } catch (e) {
//       debugPrint('Failed to save attendance: $e');
//     }
//   }

//   Future<void> _loadAttendanceFromStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final jsonStr = prefs.getString(_kAttendanceStorageKey);
//       if (jsonStr == null) return;

//       final Map<String, dynamic> map = jsonDecode(jsonStr);
//       final AttendanceRecord loaded = _attendanceRecordFromMap(map);

//       final now = DateTime.now();
//       if (loaded.checkInTime != null && _isSameDate(loaded.checkInTime!, now)) {
//         attendanceRecord.value = loaded;
//         elapsedTime.value = loaded.getElapsedTime();
//         debugPrint('Loaded attendance for today: $map');
//       } else {
//         debugPrint('Stored attendance is from previous day. Clearing.');
//         await _clearAttendanceStorage();
//       }
//     } catch (e) {
//       debugPrint('Failed to load attendance: $e');
//     }
//   }

//   Future<void> _clearAttendanceStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_kAttendanceStorageKey);
//     } catch (e) {
//       debugPrint('Failed to clear attendance storage: $e');
//     } finally {
//       attendanceRecord.value = AttendanceRecord();
//       elapsedTime.value = attendanceRecord.value.getElapsedTime();
//     }
//   }

//   void _scheduleMidnightReset() {
//     _midnightTimer?.cancel();
//     final now = DateTime.now();
//     final nextMidnight = DateTime(
//       now.year,
//       now.month,
//       now.day,
//     ).add(const Duration(days: 1));
//     final durationUntilMidnight = nextMidnight.difference(now);

//     _midnightTimer = Timer(durationUntilMidnight, () async {
//       debugPrint('Midnight reached — clearing attendance for new day');
//       await _clearAttendanceStorage();
//       _scheduleMidnightReset(); // reschedule for next day
//     });

//     debugPrint(
//       'Midnight reset scheduled in: ${durationUntilMidnight.inSeconds} seconds',
//     );
//   }

//   /// Called by location widget with full data
//   void updateLocation(AttendanceLocationData location) {
//     lastLocation.value = location;
//     isFakeLocation.value = location.isMock;
//   }

//   /// Handle check-in action (only once per day)
//   Future<void> handleCheckIn() async {
//     if (_isSending.value) return; // prevent double taps

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

//     final loc = lastLocation.value;
//     if (loc == null) {
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

//     _isSending.value = true;

//     // Call backend first. Only update local state if success.
//     final success = await _sendAttendanceToBackend(action: 'check_in');

//     if (success) {
//       final record = AttendanceRecord(
//         checkInTime: now,
//         checkOutTime: null,
//         isCheckedIn: true,
//       );

//       attendanceRecord.value = record;
//       elapsedTime.value = record.getElapsedTime();

//       await _saveAttendanceToStorage();
//       _scheduleMidnightReset();

//       Get.snackbar(
//         'Check-in successful',
//         'You have checked in.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } else {
//       Get.snackbar(
//         'Check-in failed',
//         'Unable to check in. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//         backgroundColor: const Color(0xFFDC3545),
//         colorText: Colors.white,
//       );
//     }

//     _isSending.value = false;
//   }

//   Future<void> handleCheckOut() async {
//     if (_isSending.value) return;
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

//     final loc = lastLocation.value;
//     if (loc == null) {
//       Get.snackbar(
//         'Location missing',
//         'Unable to get current location. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//       );
//       return;
//     }

//     _isSending.value = true;

//     final success = await _sendAttendanceToBackend(action: 'check_out');

//     if (success) {
//       final updated = currentRecord.copyWith(
//         checkOutTime: now,
//         isCheckedIn: false,
//       );

//       attendanceRecord.value = updated;
//       elapsedTime.value = updated.getElapsedTime();

//       await _saveAttendanceToStorage();

//       Get.snackbar(
//         'Check-out successful',
//         'You have checked out.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } else {
//       Get.snackbar(
//         'Check-out failed',
//         'Unable to check out. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//         backgroundColor: const Color(0xFFDC3545),
//         colorText: Colors.white,
//       );
//     }

//     _isSending.value = false;
//   }

//   /// Send attendance to backend. Returns true on success, false on any failure.
//   Future<bool> _sendAttendanceToBackend({required String action}) async {
//     final loc = lastLocation.value;

//     if (loc == null) {
//       debugPrint('No location data available. Skipping API call.');
//       return false;
//     }

//     const String apiUrl = '${ApiConfig.baseUrl}/attendance/mark_attendance';

//     final String? androidId = await DeviceInfoService.getAndroidId();
//     final String? authToken = await TokenStorage.getToken();

//     final payload = <String, dynamic>{
//       'myLatitude': loc.latitude.toStringAsFixed(5),
//       'myLongitude': loc.longitude.toStringAsFixed(5),
//       'isMock': loc.isMock.toString(),
//       'address': loc.address,
//       'accuracy': loc.accuracy.toStringAsFixed(2),
//       'buildNumber': androidId,
//       'type': action == 'check_in' ? 'CHECK-IN' : 'CHECK-OUT',
//     };

//     debugPrint('Sending attendance payload: $payload');

//     try {
//       final headers = <String, String>{
//         'Content-Type': 'application/json',
//         if (authToken != null) 'Authorization': 'Bearer $authToken',
//       };

//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: jsonEncode(payload),
//       );

//       debugPrint(
//         'Attendance API response: ${response.statusCode} ${response.body}',
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       debugPrint('Attendance API error: $e');
//       return false;
//     }
//   }

//   // Convert AttendanceRecord -> Map for storage
//   Map<String, dynamic> _attendanceRecordToMap(AttendanceRecord r) {
//     return {
//       'checkInTime': r.checkInTime?.toIso8601String(),
//       'checkOutTime': r.checkOutTime?.toIso8601String(),
//       'isCheckedIn': r.isCheckedIn,
//     };
//   }

//   // Convert Map -> AttendanceRecord
//   AttendanceRecord _attendanceRecordFromMap(Map<String, dynamic> m) {
//     DateTime? parse(String? s) {
//       if (s == null) return null;
//       try {
//         return DateTime.parse(s);
//       } catch (_) {
//         return null;
//       }
//     }

//     return AttendanceRecord(
//       checkInTime: parse(m['checkInTime'] as String?),
//       checkOutTime: parse(m['checkOutTime'] as String?),
//       isCheckedIn: (m['isCheckedIn'] as bool?) ?? false,
//     );
//   }
// }

// /// Attendance tracking screen
// class AttendanceTrackingScreen extends StatelessWidget {
//   const AttendanceTrackingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final AttendanceController controller =
//         Get.isRegistered<AttendanceController>()
//         ? Get.find<AttendanceController>()
//         : Get.put(AttendanceController());

//     final double h = Get.height;
//     final double w = Get.width;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF030213)),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           'Daily Attendance',
//           style: TextStyle(
//             fontSize: w * 0.05,
//             fontWeight: FontWeight.w500,
//             color: const Color(0xFF030213),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.notifications_outlined,
//               color: Color(0xFF030213),
//             ),
//             onPressed: () {
//               debugPrint('Notifications clicked');
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings_outlined, color: Color(0xFF030213)),
//             onPressed: () {
//               debugPrint('Settings clicked');
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(w * 0.04),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// Current Date Card
//               AttendanceInfoCard(
//                 icon: Icons.calendar_today,
//                 iconColor: const Color(0xFF007BFF),
//                 backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
//                 label: 'Today',
//                 value: AttendanceRecord.getCurrentDate(),
//               ),

//               SizedBox(height: h * 0.02),

//               /// Location Indicator Card
//               Container(
//                 width: double.infinity,
//                 height: h * 0.25,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [Color(0xFFECECF0), Color(0xFFE9EBEF)],
//                   ),
//                   borderRadius: BorderRadius.circular(w * 0.03),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.10),
//                       blurRadius: w * 0.03,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: LiveLocationWidgets(
//                   onLocationUpdate: controller.updateLocation,
//                 ),
//               ),

//               SizedBox(height: h * 0.02),

//               /// Primary Action Card (reactive)
//               Obx(() => _buildPrimaryActionCard(controller, h, w)),

//               SizedBox(height: h * 0.03),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.description_outlined,
//                     color: Color(0xFF717182),
//                     size: 20,
//                   ),
//                   SizedBox(width: w * 0.02),
//                   Text(
//                     "Today's Log",
//                     style: TextStyle(
//                       fontSize: w * 0.045,
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0xFF030213),
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: h * 0.015),

//               /// Today's Log History Card (reactive)
//               Obx(() => _buildLogHistoryCard(controller, h, w)),

//               SizedBox(height: h * 0.03),
//               Center(
//                 child: TextButton(
//                   onPressed: () {
//                     debugPrint('View Past Records clicked');
//                     Get.to(() => const PastRecordsScreen());
//                   },
//                   style: TextButton.styleFrom(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: w * 0.06,
//                       vertical: h * 0.015,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(w * 0.02),
//                     ),
//                   ),
//                   child: Text(
//                     'View Past Records',
//                     style: TextStyle(
//                       fontSize: w * 0.04,
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0xFF007BFF),
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: h * 0.02),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// Primary Action Card (Check-in / Check-out)
//   Widget _buildPrimaryActionCard(
//     AttendanceController controller,
//     double h,
//     double w,
//   ) {
//     final record = controller.attendanceRecord.value;
//     final bool isCheckedIn = record.isCheckedIn;

//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: isCheckedIn
//               ? [const Color(0xFFFFC107), const Color(0xFFFF9800)]
//               : [const Color(0xFF007BFF), const Color(0xFF0056b3)],
//         ),
//         borderRadius: BorderRadius.circular(w * 0.03),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: w * 0.03,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(w * 0.05),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Status Header
//             Row(
//               children: [
//                 Icon(
//                   isCheckedIn ? Icons.check_circle : Icons.access_time,
//                   color: Colors.white,
//                   size: w * 0.055,
//                 ),
//                 SizedBox(width: w * 0.02),
//                 Expanded(
//                   child: Text(
//                     isCheckedIn
//                         ? 'Status: Work in Progress'
//                         : 'Status: Ready to Start',
//                     style: TextStyle(
//                       fontSize: w * 0.05,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             SizedBox(height: h * 0.01),

//             /// Status Description
//             Text(
//               isCheckedIn
//                   ? 'Checked in at ${AttendanceRecord.formatTime(record.checkInTime)}'
//                   : 'Tap to log your attendance.',
//               style: TextStyle(fontSize: w * 0.04, color: Colors.white),
//             ),

//             SizedBox(height: h * 0.03),

//             /// Action Button
//             SizedBox(
//               width: double.infinity,
//               height: h * 0.065,
//               child: Obx(
//                 () => ElevatedButton(
//                   onPressed: controller.isSending
//                       ? null
//                       : isCheckedIn
//                       ? () {
//                           Get.defaultDialog(
//                             title: 'Confirm Check Out',
//                             middleText: 'Are you sure you want to CHECK OUT?',
//                             barrierDismissible: false,
//                             textCancel: 'Cancel',
//                             textConfirm: 'Yes, Check Out',
//                             onCancel: () {},
//                             onConfirm: () {
//                               Get.back();
//                               controller.handleCheckOut();
//                             },
//                             buttonColor: const Color(0xFFDC3545),
//                             confirmTextColor: Colors.white,
//                           );
//                         }
//                       : () => controller.handleCheckIn(),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isCheckedIn
//                         ? const Color(0xFFDC3545)
//                         : Colors.white,
//                     foregroundColor: isCheckedIn
//                         ? Colors.white
//                         : const Color(0xFF007BFF),
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(w * 0.02),
//                     ),
//                   ),
//                   child: controller.isSending
//                       ? Row(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             SizedBox(
//                               height: 18,
//                               width: 18,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             SizedBox(width: 12),
//                             Text(
//                               'Processing...',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ],
//                         )
//                       : Text(
//                           isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
//                           style: TextStyle(
//                             fontSize: w * 0.045,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Log History Card: Check-in, Check-out, Total Hours
//   Widget _buildLogHistoryCard(
//     AttendanceController controller,
//     double h,
//     double w,
//   ) {
//     final record = controller.attendanceRecord.value;
//     final hasCheckedIn = record.checkInTime != null;
//     final hasCheckedOut = record.checkOutTime != null;
//     final isOngoing = record.isCheckedIn;

//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(w * 0.03),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(w * 0.05),
//         child: Column(
//           children: [
//             /// Check-in Entry
//             LogEntryItem(
//               icon: hasCheckedIn ? Icons.check_circle : Icons.access_time,
//               iconColor: hasCheckedIn
//                   ? const Color(0xFF28A745)
//                   : const Color(0xFF717182),
//               backgroundColor: hasCheckedIn
//                   ? const Color(0xFF28A745).withOpacity(0.1)
//                   : const Color(0xFFECECF0),
//               label: 'Check-in',
//               value: AttendanceRecord.formatTime(record.checkInTime),
//               valueColor: hasCheckedIn
//                   ? const Color(0xFF030213)
//                   : const Color(0xFF717182),
//               statusLabel: hasCheckedIn ? 'Logged' : null,
//               statusBackgroundColor: const Color(0xFF28A745).withOpacity(0.1),
//               statusTextColor: const Color(0xFF28A745),
//             ),

//             SizedBox(height: h * 0.02),
//             const Divider(color: Color(0xFFECECF0), height: 1),
//             SizedBox(height: h * 0.02),

//             /// Check-out Entry
//             LogEntryItem(
//               icon: hasCheckedOut ? Icons.cancel : Icons.access_time,
//               iconColor: hasCheckedOut
//                   ? const Color(0xFFDC3545)
//                   : (isOngoing
//                         ? const Color(0xFFFFC107)
//                         : const Color(0xFF717182)),
//               backgroundColor: hasCheckedOut
//                   ? const Color(0xFFDC3545).withOpacity(0.1)
//                   : const Color(0xFFECECF0),
//               label: 'Check-out',
//               value: hasCheckedOut
//                   ? AttendanceRecord.formatTime(record.checkOutTime)
//                   : (isOngoing ? 'Ongoing...' : '—'),
//               valueColor: hasCheckedOut
//                   ? const Color(0xFF030213)
//                   : (isOngoing
//                         ? const Color(0xFFFFC107)
//                         : const Color(0xFF717182)),
//               statusLabel: hasCheckedOut ? 'Logged' : null,
//               statusBackgroundColor: const Color(0xFFDC3545).withOpacity(0.1),
//               statusTextColor: const Color(0xFFDC3545),
//             ),

//             SizedBox(height: h * 0.02),
//             const Divider(color: Color(0xFFECECF0), height: 1),
//             SizedBox(height: h * 0.02),

//             /// Total Hours Entry
//             Obx(
//               () => LogEntryItem(
//                 icon: Icons.access_time,
//                 iconColor: const Color(0xFF007BFF),
//                 backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
//                 label: 'Total Hours',
//                 value: controller.elapsedTime.value,
//                 valueColor: const Color(0xFF030213),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// //Upper Wala Tested and Final hai But niche Wala UI testing hai
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pds_app/Widgets/Attandence/attandence.dart';
// import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
// import 'package:pds_app/features/Location_Get&Finde_Mock/attandenceLocation.dart';
// import 'package:pds_app/core/Services/Android_id_get.dart';
// import 'package:pds_app/core/Services/token_store.dart';
// import 'package:pds_app/core/apiConfig/config.dart';
// import 'log_entry_items.dart';

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
//     'latitude': latitude,
//     'longitude': longitude,
//     'isMock': isMock,
//     'accuracy': accuracy,
//     'address': address,
//   };
// }

// /// GetX Controller
// class AttendanceController extends GetxController {
//   final attendanceRecord = AttendanceRecord().obs;
//   final isFakeLocation = false.obs;
//   final elapsedTime = '0 hours, 0 minutes'.obs;

//   final Rxn<AttendanceLocationData> lastLocation =
//       Rxn<AttendanceLocationData>();

//   Timer? _timer;
//   Timer? _midnightTimer;

//   final RxBool _isSending = false.obs;
//   bool get isSending => _isSending.value;

//   static const String _kAttendanceStorageKey = 'user_attendance_record_v1';

//   @override
//   void onInit() {
//     super.onInit();
//     _startTimer();
//     _loadAttendanceFromStorage().then((_) {
//       _scheduleMidnightReset();
//     });
//   }

//   @override
//   void onClose() {
//     _timer?.cancel();
//     _midnightTimer?.cancel();
//     super.onClose();
//   }

//   /// Compare only date part (year, month, day)
//   bool _isSameDate(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   /// Start elapsed timer
//   void _startTimer() {
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (attendanceRecord.value.isCheckedIn) {
//         elapsedTime.value = attendanceRecord.value.getElapsedTime();
//       }
//     });
//   }

//   /// Persist the attendanceRecord to SharedPreferences as JSON
//   Future<void> _saveAttendanceToStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final map = _attendanceRecordToMap(attendanceRecord.value);
//       final jsonStr = jsonEncode(map);
//       await prefs.setString(_kAttendanceStorageKey, jsonStr);
//       debugPrint('Attendance saved to storage: $jsonStr');
//     } catch (e) {
//       debugPrint('Failed to save attendance: $e');
//     }
//   }

//   Future<void> _loadAttendanceFromStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final jsonStr = prefs.getString(_kAttendanceStorageKey);
//       if (jsonStr == null) return;

//       final Map<String, dynamic> map = jsonDecode(jsonStr);
//       final AttendanceRecord loaded = _attendanceRecordFromMap(map);

//       final now = DateTime.now();
//       if (loaded.checkInTime != null && _isSameDate(loaded.checkInTime!, now)) {
//         attendanceRecord.value = loaded;
//         elapsedTime.value = loaded.getElapsedTime();
//         debugPrint('Loaded attendance for today: $map');
//       } else {
//         debugPrint('Stored attendance is from previous day. Clearing.');
//         await _clearAttendanceStorage();
//       }
//     } catch (e) {
//       debugPrint('Failed to load attendance: $e');
//     }
//   }

//   Future<void> _clearAttendanceStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_kAttendanceStorageKey);
//     } catch (e) {
//       debugPrint('Failed to clear attendance storage: $e');
//     } finally {
//       attendanceRecord.value = AttendanceRecord();
//       elapsedTime.value = attendanceRecord.value.getElapsedTime();
//     }
//   }

//   void _scheduleMidnightReset() {
//     _midnightTimer?.cancel();
//     final now = DateTime.now();
//     final nextMidnight = DateTime(
//       now.year,
//       now.month,
//       now.day,
//     ).add(const Duration(days: 1));
//     final durationUntilMidnight = nextMidnight.difference(now);

//     _midnightTimer = Timer(durationUntilMidnight, () async {
//       debugPrint('Midnight reached — clearing attendance for new day');
//       await _clearAttendanceStorage();
//       _scheduleMidnightReset(); // reschedule for next day
//     });

//     debugPrint(
//       'Midnight reset scheduled in: ${durationUntilMidnight.inSeconds} seconds',
//     );
//   }

//   /// Called by location widget with full data
//   void updateLocation(AttendanceLocationData location) {
//     lastLocation.value = location;
//     isFakeLocation.value = location.isMock;
//   }

//   /// Handle check-in action (only once per day)
//   Future<void> handleCheckIn() async {
//     if (_isSending.value) return; // prevent double taps

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

//     final loc = lastLocation.value;
//     if (loc == null) {
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

//     _isSending.value = true;

//     // Call backend first. Only update local state if success.
//     final success = await _sendAttendanceToBackend(action: 'check_in');

//     if (success) {
//       final record = AttendanceRecord(
//         checkInTime: now,
//         checkOutTime: null,
//         isCheckedIn: true,
//       );

//       attendanceRecord.value = record;
//       elapsedTime.value = record.getElapsedTime();

//       await _saveAttendanceToStorage();
//       _scheduleMidnightReset();

//       Get.snackbar(
//         'Check-in successful',
//         'You have checked in.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } else {
//       Get.snackbar(
//         'Check-in failed',
//         'Unable to check in. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//         backgroundColor: const Color(0xFFDC3545),
//         colorText: Colors.white,
//       );
//     }

//     _isSending.value = false;
//   }

//   Future<void> handleCheckOut() async {
//     if (_isSending.value) return;
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

//     final loc = lastLocation.value;
//     if (loc == null) {
//       Get.snackbar(
//         'Location missing',
//         'Unable to get current location. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//       );
//       return;
//     }

//     _isSending.value = true;

//     final success = await _sendAttendanceToBackend(action: 'check_out');

//     if (success) {
//       final updated = currentRecord.copyWith(
//         checkOutTime: now,
//         isCheckedIn: false,
//       );

//       attendanceRecord.value = updated;
//       elapsedTime.value = updated.getElapsedTime();

//       await _saveAttendanceToStorage();

//       Get.snackbar(
//         'Check-out successful',
//         'You have checked out.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } else {
//       Get.snackbar(
//         'Check-out failed',
//         'Unable to check out. Please try again.',
//         snackPosition: SnackPosition.BOTTOM,
//         margin: const EdgeInsets.all(12),
//         backgroundColor: const Color(0xFFDC3545),
//         colorText: Colors.white,
//       );
//     }

//     _isSending.value = false;
//   }

//   /// Send attendance to backend. Returns true on success, false on any failure.
//   Future<bool> _sendAttendanceToBackend({required String action}) async {
//     final loc = lastLocation.value;

//     if (loc == null) {
//       debugPrint('No location data available. Skipping API call.');
//       return false;
//     }

//     const String apiUrl = '${ApiConfig.baseUrl}/attendance/mark_attendance';

//     final String? androidId = await DeviceInfoService.getAndroidId();
//     final String? authToken = await TokenStorage.getToken();

//     final payload = <String, dynamic>{
//       'myLatitude': loc.latitude.toStringAsFixed(5),
//       'myLongitude': loc.longitude.toStringAsFixed(5),
//       'isMock': loc.isMock.toString(),
//       'address': loc.address,
//       'accuracy': loc.accuracy.toStringAsFixed(2),
//       'buildNumber': androidId,
//       'type': action == 'check_in' ? 'CHECK-IN' : 'CHECK-OUT',
//     };

//     debugPrint('Sending attendance payload: $payload');

//     try {
//       final headers = <String, String>{
//         'Content-Type': 'application/json',
//         if (authToken != null) 'Authorization': 'Bearer $authToken',
//       };

//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: jsonEncode(payload),
//       );

//       debugPrint(
//         'Attendance API response: ${response.statusCode} ${response.body}',
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       debugPrint('Attendance API error: $e');
//       return false;
//     }
//   }

//   // Convert AttendanceRecord -> Map for storage
//   Map<String, dynamic> _attendanceRecordToMap(AttendanceRecord r) {
//     return {
//       'checkInTime': r.checkInTime?.toIso8601String(),
//       'checkOutTime': r.checkOutTime?.toIso8601String(),
//       'isCheckedIn': r.isCheckedIn,
//     };
//   }

//   // Convert Map -> AttendanceRecord
//   AttendanceRecord _attendanceRecordFromMap(Map<String, dynamic> m) {
//     DateTime? parse(String? s) {
//       if (s == null) return null;
//       try {
//         return DateTime.parse(s);
//       } catch (_) {
//         return null;
//       }
//     }

//     return AttendanceRecord(
//       checkInTime: parse(m['checkInTime'] as String?),
//       checkOutTime: parse(m['checkOutTime'] as String?),
//       isCheckedIn: (m['isCheckedIn'] as bool?) ?? false,
//     );
//   }
// }

// /// Attendance tracking screen (UI-only update)
// class AttendanceTrackingScreen extends StatelessWidget {
//   const AttendanceTrackingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final AttendanceController controller =
//         Get.isRegistered<AttendanceController>()
//         ? Get.find<AttendanceController>()
//         : Get.put(AttendanceController());

//     final double h = Get.height;
//     final double w = Get.width;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           'Daily Attendance',
//           style: TextStyle(
//             fontSize: w * 0.05,
//             fontWeight: FontWeight.w600,
//             color: const Color(0xFF1A1A1A),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings_outlined, color: Color(0xFF1A1A1A)),
//             onPressed: () {
//               debugPrint('Settings clicked');
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(w * 0.045),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildLocationCard(controller, h, w),
//             SizedBox(height: h * 0.02),
//             Obx(() => _buildPrimaryActionCard(controller, h, w)),
//             SizedBox(height: h * 0.03),
//             _buildSectionTitle("Today's Log", w),
//             SizedBox(height: h * 0.015),
//             Obx(() => _buildLogHistoryCard(controller, h, w)),
//             SizedBox(height: h * 0.03),
//             Center(
//               child: TextButton(
//                 onPressed: () {
//                   debugPrint('View Past Records clicked');
//                   Get.to(() => const PastRecordsScreen());
//                 },
//                 child: Text(
//                   'View Past Records',
//                   style: TextStyle(
//                     fontSize: w * 0.042,
//                     color: const Color(0xFF007BFF),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: h * 0.02),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _buildHeaderCard(double w) {
//   //   return Container(
//   //     padding: EdgeInsets.all(w * 0.045),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(w * 0.03),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: Colors.black.withOpacity(0.05),
//   //           blurRadius: 8,
//   //           offset: const Offset(0, 3),
//   //         ),
//   //       ],
//   //     ),
//   //     //     child: Row(
//   //     //       children: [
//   //     //         CircleAvatar(
//   //     //           radius: w * 0.055,
//   //     //           backgroundColor: const Color(0xFF007BFF).withOpacity(0.12),
//   //     //           child: const Icon(Icons.calendar_month, color: Color(0xFF007BFF)),
//   //     //         ),
//   //     //         SizedBox(width: w * 0.04),
//   //     //         Column(
//   //     //           crossAxisAlignment: CrossAxisAlignment.start,
//   //     //           children: [
//   //     //             Text(
//   //     //               "Today",
//   //     //               style: TextStyle(
//   //     //                 fontSize: w * 0.038,
//   //     //                 color: Colors.grey[700],
//   //     //                 fontWeight: FontWeight.w500,
//   //     //               ),
//   //     //             ),
//   //     //             Text(
//   //     //               AttendanceRecord.getCurrentDate(),
//   //     //               style: TextStyle(
//   //     //                 fontSize: w * 0.045,
//   //     //                 fontWeight: FontWeight.w600,
//   //     //                 color: const Color(0xFF1A1A1A),
//   //     //               ),
//   //     //             ),
//   //     //           ],
//   //     //         ),
//   //     //       ],
//   //     //     ),
//   //   );
//   // }

//   Widget _buildLocationCard(
//     AttendanceController controller,
//     double h,
//     double w,
//   ) {
//     return Container(
//       height: h * 0.24,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(w * 0.035),
//         gradient: const LinearGradient(
//           colors: [Colors.blue, Colors.blue],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: LiveLocationWidgets(onLocationUpdate: controller.updateLocation),
//     );
//   }

//   Widget _buildPrimaryActionCard(
//     AttendanceController controller,
//     double h,
//     double w,
//   ) {
//     final record = controller.attendanceRecord.value;
//     final bool isCheckedIn = record.isCheckedIn;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: EdgeInsets.all(w * 0.05),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(w * 0.035),
//         gradient: LinearGradient(
//           colors: isCheckedIn
//               ? [Color(0xFF1A57D8), Color(0xFF1A57D8)]
//               : [Color(0xFF4285F4), Color(0xFF1967D2)],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             blurRadius: 12,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 isCheckedIn ? Icons.work_history : Icons.timer_outlined,
//                 color: Colors.white,
//                 size: w * 0.06,
//               ),
//               SizedBox(width: w * 0.03),
//               Expanded(
//                 child: Text(
//                   isCheckedIn ? 'Work in Progress' : 'Ready to Start',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: w * 0.048,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: h * 0.01),
//           Text(
//             isCheckedIn
//                 ? 'Checked in at ${AttendanceRecord.formatTime(record.checkInTime)}'
//                 : 'Tap the button to log your attendance.',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.9),
//               fontSize: w * 0.038,
//             ),
//           ),
//           SizedBox(height: h * 0.03),

//           /// BUTTON
//           SizedBox(
//             width: double.infinity,
//             height: h * 0.065,
//             child: Obx(() {
//               return ElevatedButton(
//                 onPressed: controller.isSending
//                     ? null
//                     : isCheckedIn
//                     ? () {
//                         Get.defaultDialog(
//                           title: 'Confirm Check Out',
//                           middleText: 'Are you sure you want to check out?',
//                           textConfirm: 'Yes',
//                           textCancel: 'No',
//                           onConfirm: () {
//                             Get.back();
//                             controller.handleCheckOut();
//                           },
//                         );
//                       }
//                     : controller.handleCheckIn,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isCheckedIn
//                       ? const Color(0xFFDC3545)
//                       : Colors.white,
//                   foregroundColor: isCheckedIn
//                       ? Colors.white
//                       : const Color(0xFF1967D2),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(w * 0.02),
//                   ),
//                   elevation: 4,
//                 ),
//                 child: controller.isSending
//                     ? Row(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           SizedBox(
//                             height: 18,
//                             width: 18,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Text('Processing...', style: TextStyle(fontSize: 16)),
//                         ],
//                       )
//                     : Text(
//                         isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
//                         style: TextStyle(
//                           fontSize: w * 0.045,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title, double w) {
//     return Row(
//       children: [
//         const Icon(
//           Icons.description_outlined,
//           color: Color(0xFF717182),
//           size: 20,
//         ),
//         SizedBox(width: w * 0.02),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: w * 0.045,
//             fontWeight: FontWeight.w500,
//             color: const Color(0xFF030213),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLogHistoryCard(
//     AttendanceController controller,
//     double h,
//     double w,
//   ) {
//     final record = controller.attendanceRecord.value;
//     final hasCheckedIn = record.checkInTime != null;
//     final hasCheckedOut = record.checkOutTime != null;
//     final isOngoing = record.isCheckedIn;

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(w * 0.03),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(w * 0.05),
//         child: Column(
//           children: [
//             /// Check-in Entry
//             LogEntryItem(
//               icon: hasCheckedIn ? Icons.check_circle : Icons.access_time,
//               iconColor: hasCheckedIn
//                   ? const Color(0xFF28A745)
//                   : const Color(0xFF717182),
//               backgroundColor: hasCheckedIn
//                   ? const Color(0xFFEFF8F2)
//                   : const Color(0xFFECECF0),
//               label: 'Check-in',
//               value: AttendanceRecord.formatTime(record.checkInTime),
//               valueColor: hasCheckedIn
//                   ? const Color(0xFF030213)
//                   : const Color(0xFF717182),
//               statusLabel: hasCheckedIn ? 'Logged' : null,
//               statusBackgroundColor: const Color(0xFF28A745).withOpacity(0.1),
//               statusTextColor: const Color(0xFF28A745),
//             ),

//             SizedBox(height: h * 0.02),
//             const Divider(color: Color(0xFFECECF0), height: 1),
//             SizedBox(height: h * 0.02),

//             /// Check-out Entry
//             LogEntryItem(
//               icon: hasCheckedOut ? Icons.cancel : Icons.access_time,
//               iconColor: hasCheckedOut
//                   ? const Color(0xFFDC3545)
//                   : (isOngoing
//                         ? const Color(0xFFFFC107)
//                         : const Color(0xFF717182)),
//               backgroundColor: hasCheckedOut
//                   ? const Color(0xFFFCECEC)
//                   : const Color(0xFFECECF0),
//               label: 'Check-out',
//               value: hasCheckedOut
//                   ? AttendanceRecord.formatTime(record.checkOutTime)
//                   : (isOngoing ? 'Ongoing...' : '—'),
//               valueColor: hasCheckedOut
//                   ? const Color(0xFF030213)
//                   : (isOngoing
//                         ? const Color(0xFFFFC107)
//                         : const Color(0xFF717182)),
//               statusLabel: hasCheckedOut ? 'Logged' : null,
//               statusBackgroundColor: const Color(0xFFDC3545).withOpacity(0.1),
//               statusTextColor: const Color(0xFFDC3545),
//             ),

//             SizedBox(height: h * 0.02),
//             const Divider(color: Color(0xFFECECF0), height: 1),
//             SizedBox(height: h * 0.02),

//             /// Total Hours Entry
//             Obx(
//               () => LogEntryItem(
//                 icon: Icons.access_time,
//                 iconColor: const Color(0xFF007BFF),
//                 backgroundColor: const Color(0xFFEAF2FF),
//                 label: 'Total Hours',
//                 value: controller.elapsedTime.value,
//                 valueColor: const Color(0xFF030213),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//Uper wala code sahi hai
//test
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pds_app/Widgets/Attandence/attandence.dart';
import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
import 'package:pds_app/features/Location_Get&Finde_Mock/attandenceLocation.dart';
import 'package:pds_app/core/Services/Android_id_get.dart';
import 'package:pds_app/core/Services/token_store.dart';
import 'package:pds_app/core/apiConfig/config.dart';
import 'log_entry_items.dart';
import 'package:pds_app/Widgets/Attandence/Attandence_History/attendance_db.dart';

class AttendanceLocationData {
  final double latitude;
  final double longitude;
  final bool isMock;
  final double accuracy;
  final String address;

  AttendanceLocationData({
    required this.latitude,
    required this.longitude,
    required this.isMock,
    required this.accuracy,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'isMock': isMock,
    'accuracy': accuracy,
    'address': address,
  };
}

/// GetX Controller
class AttendanceController extends GetxController {
  final attendanceRecord = AttendanceRecord().obs;
  final isFakeLocation = false.obs;
  final elapsedTime = '0 hours, 0 minutes'.obs;

  final Rxn<AttendanceLocationData> lastLocation =
      Rxn<AttendanceLocationData>();

  Timer? _timer;
  Timer? _midnightTimer;

  final RxBool _isSending = false.obs;
  bool get isSending => _isSending.value;

  static const String _kAttendanceStorageKey = 'user_attendance_record_v1';

  @override
  void onInit() {
    super.onInit();
    _startTimer();
    _loadAttendanceFromStorage().then((_) {
      _scheduleMidnightReset();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    _midnightTimer?.cancel();
    super.onClose();
  }

  /// Compare only date part (year, month, day)
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Start elapsed timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (attendanceRecord.value.isCheckedIn) {
        elapsedTime.value = attendanceRecord.value.getElapsedTime();
      }
    });
  }

  /// Persist the attendanceRecord to SharedPreferences as JSON
  Future<void> _saveAttendanceToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = _attendanceRecordToMap(attendanceRecord.value);
      final jsonStr = jsonEncode(map);
      await prefs.setString(_kAttendanceStorageKey, jsonStr);
      debugPrint('Attendance saved to storage: $jsonStr');
    } catch (e) {
      debugPrint('Failed to save attendance: $e');
    }
  }

  Future<void> _loadAttendanceFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kAttendanceStorageKey);
      if (jsonStr == null) return;

      final Map<String, dynamic> map = jsonDecode(jsonStr);
      final AttendanceRecord loaded = _attendanceRecordFromMap(map);

      final now = DateTime.now();
      if (loaded.checkInTime != null && _isSameDate(loaded.checkInTime!, now)) {
        attendanceRecord.value = loaded;
        elapsedTime.value = loaded.getElapsedTime();
        debugPrint('Loaded attendance for today: $map');
      } else {
        debugPrint('Stored attendance is from previous day. Clearing.');
        await _clearAttendanceStorage();
      }
    } catch (e) {
      debugPrint('Failed to load attendance: $e');
    }
  }

  Future<void> _clearAttendanceStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kAttendanceStorageKey);
    } catch (e) {
      debugPrint('Failed to clear attendance storage: $e');
    } finally {
      attendanceRecord.value = AttendanceRecord();
      elapsedTime.value = attendanceRecord.value.getElapsedTime();
    }
  }

  void _scheduleMidnightReset() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final durationUntilMidnight = nextMidnight.difference(now);

    _midnightTimer = Timer(durationUntilMidnight, () async {
      debugPrint('Midnight reached — clearing attendance for new day');
      await _clearAttendanceStorage();
      _scheduleMidnightReset(); // reschedule for next day
    });

    debugPrint(
      'Midnight reset scheduled in: ${durationUntilMidnight.inSeconds} seconds',
    );
  }

  /// Called by location widget with full data
  void updateLocation(AttendanceLocationData location) {
    lastLocation.value = location;
    isFakeLocation.value = location.isMock;
  }

  /// Handle check-in action (only once per day)
  Future<void> handleCheckIn() async {
    if (_isSending.value) return; // prevent double taps

    if (isFakeLocation.value) {
      Get.snackbar(
        'Check-in blocked',
        'Fake GPS detected! Check-in not allowed.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: const Color(0xFFDC3545),
        colorText: Colors.white,
      );
      return;
    }

    final loc = lastLocation.value;
    if (loc == null) {
      Get.snackbar(
        'Location missing',
        'Unable to get current location. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    final now = DateTime.now();
    final currentRecord = attendanceRecord.value;

    if (currentRecord.checkInTime != null &&
        _isSameDate(currentRecord.checkInTime!, now)) {
      Get.snackbar(
        'Already checked in',
        'You have already checked in for today.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    _isSending.value = true;

    // Call backend first. Only update local state if success.
    final success = await _sendAttendanceToBackend(action: 'check_in');

    if (success) {
      final record = AttendanceRecord(
        checkInTime: now,
        checkOutTime: null,
        isCheckedIn: true,
      );

      attendanceRecord.value = record;
      elapsedTime.value = record.getElapsedTime();

      await _saveAttendanceToStorage();
      _scheduleMidnightReset();

      // Persist to local DB (so PastRecordsScreen can show it)
      try {
        await AttendanceDb.instance.checkIn(location: loc.address);
      } catch (e) {
        debugPrint('Local DB check-in failed: $e');
      }

      Get.snackbar(
        'Check-in successful',
        'You have checked in.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Check-in failed',
        'Unable to check in. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: const Color(0xFFDC3545),
        colorText: Colors.white,
      );
    }

    _isSending.value = false;
  }

  Future<void> handleCheckOut() async {
    if (_isSending.value) return;
    final currentRecord = attendanceRecord.value;
    final now = DateTime.now();

    if (currentRecord.checkInTime == null ||
        !_isSameDate(currentRecord.checkInTime!, now)) {
      Get.snackbar(
        'No active check-in',
        'You have not checked in today.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    final loc = lastLocation.value;
    if (loc == null) {
      Get.snackbar(
        'Location missing',
        'Unable to get current location. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    _isSending.value = true;

    final success = await _sendAttendanceToBackend(action: 'check_out');

    if (success) {
      final updated = currentRecord.copyWith(
        checkOutTime: now,
        isCheckedIn: false,
      );

      attendanceRecord.value = updated;
      elapsedTime.value = updated.getElapsedTime();

      await _saveAttendanceToStorage();

      // Persist checkout in local DB (so PastRecordsScreen shows completed record)
      try {
        final historyRecord = await AttendanceDb.instance.checkOut();
        if (historyRecord == null) {
          debugPrint('No open DB record found to checkout for today.');
        }
      } catch (e) {
        debugPrint('Local DB check-out failed: $e');
      }

      Get.snackbar(
        'Check-out successful',
        'You have checked out.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Check-out failed',
        'Unable to check out. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
        backgroundColor: const Color(0xFFDC3545),
        colorText: Colors.white,
      );
    }

    _isSending.value = false;
  }

  /// Send attendance to backend. Returns true on success, false on any failure.
  Future<bool> _sendAttendanceToBackend({required String action}) async {
    final loc = lastLocation.value;

    if (loc == null) {
      debugPrint('No location data available. Skipping API call.');
      return false;
    }

    const String apiUrl = '${ApiConfig.baseUrl}/attendance/mark_attendance';

    final String? androidId = await DeviceInfoService.getAndroidId();
    final String? authToken = await TokenStorage.getToken();

    final payload = <String, dynamic>{
      'myLatitude': loc.latitude.toStringAsFixed(5),
      'myLongitude': loc.longitude.toStringAsFixed(5),
      'isMock': loc.isMock.toString(),
      'address': loc.address,
      'accuracy': loc.accuracy.toStringAsFixed(2),
      'buildNumber': androidId,
      'type': action == 'check_in' ? 'CHECK-IN' : 'CHECK-OUT',
    };

    debugPrint('Sending attendance payload: $payload');

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(payload),
      );

      debugPrint(
        'Attendance API response: ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Attendance API error: $e');
      return false;
    }
  }

  // Convert AttendanceRecord -> Map for storage
  Map<String, dynamic> _attendanceRecordToMap(AttendanceRecord r) {
    return {
      'checkInTime': r.checkInTime?.toIso8601String(),
      'checkOutTime': r.checkOutTime?.toIso8601String(),
      'isCheckedIn': r.isCheckedIn,
    };
  }

  // Convert Map -> AttendanceRecord
  AttendanceRecord _attendanceRecordFromMap(Map<String, dynamic> m) {
    DateTime? parse(String? s) {
      if (s == null) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    return AttendanceRecord(
      checkInTime: parse(m['checkInTime'] as String?),
      checkOutTime: parse(m['checkOutTime'] as String?),
      isCheckedIn: (m['isCheckedIn'] as bool?) ?? false,
    );
  }
}

/// Attendance tracking screen (UI-only update)
class AttendanceTrackingScreen extends StatelessWidget {
  const AttendanceTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController controller =
        Get.isRegistered<AttendanceController>()
        ? Get.find<AttendanceController>()
        : Get.put(AttendanceController());

    final double h = Get.height;
    final double w = Get.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A57D8),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 251, 251, 251),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Daily Attendance',
          style: TextStyle(
            fontSize: w * 0.05,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Color.fromARGB(255, 247, 247, 247),
            ),
            onPressed: () {
              debugPrint('Settings clicked');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(w * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationCard(controller, h, w),
            SizedBox(height: h * 0.02),
            Obx(() => _buildPrimaryActionCard(controller, h, w)),
            SizedBox(height: h * 0.03),
            _buildSectionTitle("Today's Log", w),
            SizedBox(height: h * 0.015),
            Obx(() => _buildLogHistoryCard(controller, h, w)),
            SizedBox(height: h * 0.03),
            Center(
              child: TextButton(
                onPressed: () async {
                  debugPrint('View Past Records clicked');
                  // await the navigation so PastRecordsScreen can refresh on return if needed
                  await Get.to(() => const PastRecordsScreen());
                },
                child: Text(
                  'View Past Records',
                  style: TextStyle(
                    fontSize: w * 0.042,
                    color: const Color(0xFF007BFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: h * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(
    AttendanceController controller,
    double h,
    double w,
  ) {
    return Container(
      height: h * 0.24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(w * 0.035),
        gradient: const LinearGradient(
          colors: [Color(0xFF007BFF), Color(0xFF007BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LiveLocationWidgets(onLocationUpdate: controller.updateLocation),
    );
  }

  Widget _buildPrimaryActionCard(
    AttendanceController controller,
    double h,
    double w,
  ) {
    final record = controller.attendanceRecord.value;
    final bool isCheckedIn = record.isCheckedIn;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(w * 0.05),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(w * 0.035),
        gradient: LinearGradient(
          colors: isCheckedIn
              ? [Color(0xFF1A57D8), Color(0xFF1A57D8)]
              : [Color(0xFF4285F4), Color(0xFF1967D2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCheckedIn ? Icons.work_history : Icons.timer_outlined,
                color: Colors.white,
                size: w * 0.06,
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: Text(
                  isCheckedIn ? 'Work in Progress' : 'Ready to Start',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: w * 0.048,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.01),
          Text(
            isCheckedIn
                ? 'Checked in at ${AttendanceRecord.formatTime(record.checkInTime)}'
                : 'Tap the button to log your attendance.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: w * 0.038,
            ),
          ),
          SizedBox(height: h * 0.03),

          /// BUTTON
          SizedBox(
            width: double.infinity,
            height: h * 0.065,
            child: Obx(() {
              return ElevatedButton(
                onPressed: controller.isSending
                    ? null
                    : isCheckedIn
                    ? () {
                        Get.defaultDialog(
                          title: 'Confirm Check Out',
                          middleText: 'Are you sure you want to check out?',
                          textConfirm: 'Yes',
                          textCancel: 'No',
                          onConfirm: () {
                            Get.back();
                            controller.handleCheckOut();
                          },
                        );
                      }
                    : controller.handleCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCheckedIn
                      ? const Color(0xFFDC3545)
                      : Colors.white,
                  foregroundColor: isCheckedIn
                      ? Colors.white
                      : const Color(0xFF1967D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.02),
                  ),
                  elevation: 4,
                ),
                child: controller.isSending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Processing...', style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : Text(
                        isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                        style: TextStyle(
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double w) {
    return Row(
      children: [
        const Icon(
          Icons.description_outlined,
          color: Color(0xFF717182),
          size: 20,
        ),
        SizedBox(width: w * 0.02),
        Text(
          title,
          style: TextStyle(
            fontSize: w * 0.045,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF030213),
          ),
        ),
      ],
    );
  }

  Widget _buildLogHistoryCard(
    AttendanceController controller,
    double h,
    double w,
  ) {
    final record = controller.attendanceRecord.value;
    final hasCheckedIn = record.checkInTime != null;
    final hasCheckedOut = record.checkOutTime != null;
    final isOngoing = record.isCheckedIn;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(w * 0.03),
      ),
      child: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          children: [
            /// Check-in Entry
            LogEntryItem(
              icon: hasCheckedIn ? Icons.check_circle : Icons.access_time,
              iconColor: hasCheckedIn
                  ? const Color(0xFF28A745)
                  : const Color(0xFF717182),
              backgroundColor: hasCheckedIn
                  ? const Color(0xFFEFF8F2)
                  : const Color(0xFFECECF0),
              label: 'Check-in',
              value: AttendanceRecord.formatTime(record.checkInTime),
              valueColor: hasCheckedIn
                  ? const Color(0xFF030213)
                  : const Color(0xFF717182),
              statusLabel: hasCheckedIn ? 'Logged' : null,
              statusBackgroundColor: const Color(0xFF28A745).withOpacity(0.1),
              statusTextColor: const Color(0xFF28A745),
            ),

            SizedBox(height: h * 0.02),
            const Divider(color: Color(0xFFECECF0), height: 1),
            SizedBox(height: h * 0.02),

            /// Check-out Entry
            LogEntryItem(
              icon: hasCheckedOut ? Icons.cancel : Icons.access_time,
              iconColor: hasCheckedOut
                  ? const Color(0xFFDC3545)
                  : (isOngoing
                        ? const Color(0xFFFFC107)
                        : const Color(0xFF717182)),
              backgroundColor: hasCheckedOut
                  ? const Color(0xFFFCECEC)
                  : const Color(0xFFECECF0),
              label: 'Check-out',
              value: hasCheckedOut
                  ? AttendanceRecord.formatTime(record.checkOutTime)
                  : (isOngoing ? 'Ongoing...' : '—'),
              valueColor: hasCheckedOut
                  ? const Color(0xFF030213)
                  : (isOngoing
                        ? const Color(0xFFFFC107)
                        : const Color(0xFF717182)),
              statusLabel: hasCheckedOut ? 'Logged' : null,
              statusBackgroundColor: const Color(0xFFDC3545).withOpacity(0.1),
              statusTextColor: const Color(0xFFDC3545),
            ),

            SizedBox(height: h * 0.02),
            const Divider(color: Color(0xFFECECF0), height: 1),
            SizedBox(height: h * 0.02),

            /// Total Hours Entry
            Obx(
              () => LogEntryItem(
                icon: Icons.access_time,
                iconColor: const Color(0xFF007BFF),
                backgroundColor: const Color(0xFFEAF2FF),
                label: 'Total Hours',
                value: controller.elapsedTime.value,
                valueColor: const Color(0xFF030213),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
