// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/get_navigation.dart';
// import 'package:pds_app/Models/attandence.dart';
// import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
// import 'package:pds_app/Widgets/Location_Get&Finde_Mock/attandenceLocation.dart';
// import 'Attandance_info_card.dart';
// import 'log_entry_items.dart';
// // import 'AttandencePastRecord.dart';

// /// Daily Attendance Tracking Screen
// ///
// /// Complete implementation with:
// /// - Check-in and check-out functionality
// /// - Real-time elapsed time tracking
// /// - Today's attendance log
// /// - Location indicator
// /// - Two dynamic states (Ready to Start / Work in Progress)
// class AttendanceTrackingScreen extends StatefulWidget {
//   const AttendanceTrackingScreen({super.key});

//   @override
//   State<AttendanceTrackingScreen> createState() =>
//       _AttendanceTrackingScreenState();
// }

// class _AttendanceTrackingScreenState extends State<AttendanceTrackingScreen> {
//   AttendanceRecord _attendanceRecord = AttendanceRecord();
//   bool _isFakeLocation = false;
//   String _elapsedTime = '0 hours, 0 minutes';
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startTimer();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   /// Start a timer to update elapsed time every second
//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_attendanceRecord.isCheckedIn) {
//         setState(() {
//           _elapsedTime = _attendanceRecord.getElapsedTime();
//         });
//       }
//     });
//   }

//   /// Handle check-in action
//   void _handleCheckIn() {
//     if (_isFakeLocation) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('❌ Check-in not allowed — Fake GPS detected!'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return; // 🚫 Stop check-in
//     }

//     setState(() {
//       _attendanceRecord = AttendanceRecord(
//         checkInTime: DateTime.now(),
//         checkOutTime: null,
//         isCheckedIn: true,
//       );
//       _elapsedTime = _attendanceRecord.getElapsedTime();
//     });
//   }

//   /// Handle check-out action
//   void _handleCheckOut() {
//     setState(() {
//       _attendanceRecord = _attendanceRecord.copyWith(
//         checkOutTime: DateTime.now(),
//         isCheckedIn: false,
//       );
//       _elapsedTime = _attendanceRecord.getElapsedTime();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),

//       /// App Bar with back button, title, and action icons
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF030213)),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text(
//           'Daily Attendance',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF030213),
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

//       /// Scrollable content area
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
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

//               const SizedBox(height: 16),

//               /// Location Indicator Card
//               Container(
//                 width: double.infinity,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [Color(0xFFECECF0), Color(0xFFE9EBEF)],
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.10),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: LiveLocationWidgets(
//                   onLocationCheck: (isFake) {
//                     setState(() {
//                       _isFakeLocation = isFake;
//                     });
//                   },
//                 ),
//               ),

//               const SizedBox(height: 16),

//               /// Primary Action Section - Dynamic Based on State
//               _buildPrimaryActionCard(),

//               const SizedBox(height: 24),

//               /// Today's Log Section Header
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.description_outlined,
//                     color: Color(0xFF717182),
//                     size: 20,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     "Today's Log",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF030213),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               /// Today's Log History Card
//               _buildLogHistoryCard(),

//               const SizedBox(height: 24),

//               /// Footer - View Past Records Button
//               Center(
//                 child: TextButton(
//                   onPressed: () {
//                     debugPrint('View Past Records clicked');
//                     Get.to(() => const PastRecordsScreen());
//                   },
//                   style: TextButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'View Past Records',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF007BFF),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// Build the primary action card with gradient background
//   /// Changes color and content based on check-in state
//   Widget _buildPrimaryActionCard() {
//     final isCheckedIn = _attendanceRecord.isCheckedIn;

//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: isCheckedIn
//               ? [const Color(0xFFFFC107), const Color(0xFFFF9800)]
//               : [const Color(0xFF007BFF), const Color(0xFF0056b3)],
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Status Header
//             Row(
//               children: [
//                 Icon(
//                   isCheckedIn ? Icons.check_circle : Icons.access_time,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     isCheckedIn
//                         ? 'Status: Work in Progress'
//                         : 'Status: Ready to Start',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             /// Status Description
//             Text(
//               isCheckedIn
//                   ? 'Checked in at ${AttendanceRecord.formatTime(_attendanceRecord.checkInTime)}'
//                   : 'Tap to log your attendance.',
//               style: const TextStyle(fontSize: 16, color: Colors.white),
//             ),

//             const SizedBox(height: 24),

//             /// Action Button
//             // SizedBox(
//             //   width: double.infinity,
//             //   height: 56,
//             //   child: ElevatedButton(
//             //     onPressed: isCheckedIn ? _handleCheckOut : _handleCheckIn,
//             //     style: ElevatedButton.styleFrom(
//             //       backgroundColor: isCheckedIn
//             //           ? const Color(0xFFDC3545)
//             //           : Colors.white,
//             //       foregroundColor: isCheckedIn
//             //           ? Colors.white
//             //           : const Color(0xFF007BFF),
//             //       elevation: 4,
//             //       shape: RoundedRectangleBorder(
//             //         borderRadius: BorderRadius.circular(8),
//             //       ),
//             //     ),
//             //     child: Text(
//             //       isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
//             //       style: const TextStyle(
//             //         fontSize: 18,
//             //         fontWeight: FontWeight.w500,
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: isCheckedIn
//                     ? () {
//                         Get.defaultDialog(
//                           title: 'Confirm Check Out',
//                           middleText: 'Are you sure you want to CHECK OUT?',
//                           barrierDismissible: false,
//                           textCancel: 'Cancel',
//                           textConfirm: 'Yes, Check Out',
//                           onCancel: () {},
//                           onConfirm: () {
//                             Get.back(); // Close dialog
//                             _handleCheckOut(); // Execute checkout
//                           },
//                           buttonColor: const Color(0xFFDC3545),
//                           confirmTextColor: Colors.white,
//                         );
//                       }
//                     : _handleCheckIn,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isCheckedIn
//                       ? const Color(0xFFDC3545)
//                       : Colors.white,
//                   foregroundColor: isCheckedIn
//                       ? Colors.white
//                       : const Color(0xFF007BFF),
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Build the log history card showing check-in, check-out, and total time
//   Widget _buildLogHistoryCard() {
//     final hasCheckedIn = _attendanceRecord.checkInTime != null;
//     final hasCheckedOut = _attendanceRecord.checkOutTime != null;
//     final isOngoing = _attendanceRecord.isCheckedIn;

//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
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
//               value: AttendanceRecord.formatTime(_attendanceRecord.checkInTime),
//               valueColor: hasCheckedIn
//                   ? const Color(0xFF030213)
//                   : const Color(0xFF717182),
//               statusLabel: hasCheckedIn ? 'Logged' : null,
//               statusBackgroundColor: const Color(0xFF28A745).withOpacity(0.1),
//               statusTextColor: const Color(0xFF28A745),
//             ),

//             const SizedBox(height: 16),
//             const Divider(color: Color(0xFFECECF0), height: 1),
//             const SizedBox(height: 16),

//             /// Check-out Entry
//             LogEntryItem(
//               icon: hasCheckedOut
//                   ? Icons.cancel
//                   : (isOngoing ? Icons.access_time : Icons.access_time),
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
//                   ? AttendanceRecord.formatTime(_attendanceRecord.checkOutTime)
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

//             const SizedBox(height: 16),
//             const Divider(color: Color(0xFFECECF0), height: 1),
//             const SizedBox(height: 16),

//             /// Total Hours Entry
//             LogEntryItem(
//               icon: Icons.access_time,
//               iconColor: const Color(0xFF007BFF),
//               backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
//               label: 'Total Hours',
//               value: _elapsedTime,
//               valueColor: const Color(0xFF030213),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Yaha se with logic code hai.
// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// import 'package:pds_app/Models/attandence.dart';
// import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
// import 'package:pds_app/Widgets/Location_Get&Finde_Mock/attandenceLocation.dart';

// import 'Attandance_info_card.dart';
// import 'log_entry_items.dart';

// /// Model for location data
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
// }

// ///  GetX Controller
// class AttendanceController extends GetxController {
//   final attendanceRecord = AttendanceRecord().obs;
//   final isFakeLocation = false.obs;
//   final elapsedTime = '0 hours, 0 minutes'.obs;

//   // latest location from LiveLocationWidgets
//   final Rxn<AttendanceLocationData> lastLocation =
//       Rxn<AttendanceLocationData>();

//   Timer? _timer;

//   @override
//   void onInit() {
//     super.onInit();
//     _startTimer();
//   }

//   @override
//   void onClose() {
//     _timer?.cancel();
//     super.onClose();
//   }

//   /// Start a timer to update elapsed time every second
//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (attendanceRecord.value.isCheckedIn) {
//         elapsedTime.value = attendanceRecord.value.getElapsedTime();
//       }
//     });
//   }

//   /// Called by location widget with full data
//   void updateLocation(AttendanceLocationData location) {
//     lastLocation.value = location;
//     isFakeLocation.value = location.isMock;
//   }

//   /// -------------------- CHECK IN --------------------
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

//     final record = AttendanceRecord(
//       checkInTime: DateTime.now(),
//       checkOutTime: null,
//       isCheckedIn: true,
//     );

//     attendanceRecord.value = record;
//     elapsedTime.value = record.getElapsedTime();

//     // Hit CHECK-IN endpoint
//     _sendCheckInToBackend();
//   }

//   /// -------------------- CHECK OUT -------------------
//   Future<void> handleCheckOut() async {
//     final updated = attendanceRecord.value.copyWith(
//       checkOutTime: DateTime.now(),
//       isCheckedIn: false,
//     );

//     attendanceRecord.value = updated;
//     elapsedTime.value = updated.getElapsedTime();

//     // Hit CHECK-OUT endpoint
//     _sendCheckOutToBackend();
//   }

//   ///   API: CHECK-IN ENDPOINT
//   Future<void> _sendCheckInToBackend() async {
//     final loc = lastLocation.value;
//     final record = attendanceRecord.value;

//     if (loc == null) {
//       debugPrint('No location data available. Skipping CHECK-IN API call.');
//       return;
//     }

//     // CHECK-IN endpoint
//     const String apiUrl =
//         'http://192.168.29.202:8080/auth/m/attandence/check-in';

//     final payload = <String, dynamic>{
//       'latitude': loc.latitude,
//       'longitude': loc.longitude,
//       'is_mock_location': loc.isMock ? 1 : 0,
//       'address': loc.address,
//       'accuracy': loc.accuracy,
//       'device_id': 123,
//     };

//     debugPrint('Sending CHECK-IN payload: $payload');

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//           // 'Authorization': 'Bearer YOUR_TOKEN', // if needed
//         },
//         body: jsonEncode(payload),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         debugPrint('CHECK-IN saved successfully');
//       } else {
//         debugPrint(
//           'CHECK-IN API failed: ${response.statusCode} ${response.body}',
//         );
//         Get.snackbar(
//           'Server error',
//           'Unable to save check-in. Please try again.',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       }
//     } catch (e) {
//       debugPrint('CHECK-IN API error: $e');
//       Get.snackbar(
//         'Network error',
//         'Failed to connect to server.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }

//   ///   API: CHECK-OUT ENDPOINT

//   Future<void> _sendCheckOutToBackend() async {
//     final loc = lastLocation.value;
//     final record = attendanceRecord.value;

//     if (loc == null) {
//       debugPrint('No location data available. Skipping CHECK-OUT API call.');
//       return;
//     }

//     // CHECK-OUT endpoint
//     const String apiUrl =
//         'http://192.168.29.202:8080/auth/m/attandence/check-out';

//     final payload = <String, dynamic>{
//       'latitude': loc.latitude,
//       'longitude': loc.longitude,
//       'is_mock_location': loc.isMock ? 1 : 0,
//       'address': loc.address,
//       'accuracy': loc.accuracy,
//       'device_id': 123,
//     };

//     debugPrint('Sending CHECK-OUT payload: $payload');

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(payload),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         debugPrint('CHECK-OUT saved successfully');
//       } else {
//         debugPrint(
//           'CHECK-OUT API failed: ${response.statusCode} ${response.body}',
//         );
//         Get.snackbar(
//           'Server error',
//           'Unable to save check-out. Please try again.',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       }
//     } catch (e) {
//       debugPrint('CHECK-OUT API error: $e');
//       Get.snackbar(
//         'Network error',
//         'Failed to connect to server.',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
// }

// /// Attendance Tracking Screen
// class AttendanceTrackingScreen extends StatelessWidget {
//   const AttendanceTrackingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Register/Get controller
//     final AttendanceController controller = Get.put(AttendanceController());

//     final double h = Get.height;
//     final double w = Get.width;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),

//       /// App Bar
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

//       /// Body
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

//               /// Today's Log Header
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

//               /// Footer - View Past Records
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
//               child: ElevatedButton(
//                 onPressed: isCheckedIn
//                     ? () {
//                         Get.defaultDialog(
//                           title: 'Confirm Check Out',
//                           middleText: 'Are you sure you want to CHECK OUT?',
//                           barrierDismissible: false,
//                           textCancel: 'Cancel',
//                           textConfirm: 'Yes, Check Out',
//                           onCancel: () {},
//                           onConfirm: () {
//                             Get.back();
//                             controller.handleCheckOut();
//                           },
//                           buttonColor: const Color(0xFFDC3545),
//                           confirmTextColor: Colors.white,
//                         );
//                       }
//                     : () => controller.handleCheckIn(),

//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isCheckedIn
//                       ? const Color(0xFFDC3545)
//                       : Colors.white,
//                   foregroundColor: isCheckedIn
//                       ? Colors.white
//                       : const Color(0xFF007BFF),
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(w * 0.02),
//                   ),
//                 ),
//                 child: Text(
//                   isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
//                   style: TextStyle(
//                     fontSize: w * 0.045,
//                     fontWeight: FontWeight.w500,
//                   ),
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
// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;

// import 'package:pds_app/Models/attandence.dart';
// import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
// import 'package:pds_app/Widgets/Location_Get&Finde_Mock/attandenceLocation.dart';
// import 'package:pds_app/core/Services/Android_id_get.dart';

// import 'Attandance_info_card.dart';
// import 'log_entry_items.dart';

// ///   Model for current location data
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

//   /// If you ever need to serialize location directly, this matches backend keys
//   Map<String, dynamic> toJson() => {
//     'myLatitude': latitude,
//     'myLongitude': longitude,
//     'isMock': isMock.toString(), // "true" / "false"
//     'accuracy': accuracy,
//     'address': address,
//   };
// }

// ///  GetX Controller
// class AttendanceController extends GetxController {
//   final attendanceRecord = AttendanceRecord().obs;
//   final isFakeLocation = false.obs;
//   final elapsedTime = '0 hours, 0 minutes'.obs;

//     bool _isSameDate(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   // latest location from LiveLocationWidgets
//   final Rxn<AttendanceLocationData> lastLocation =
//       Rxn<AttendanceLocationData>();

//   Timer? _timer;

//   @override
//   void onInit() {
//     super.onInit();
//     _startTimer();
//   }

//   @override
//   void onClose() {
//     _timer?.cancel();
//     super.onClose();
//   }

//   /// Start a timer to update elapsed time every second
//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (attendanceRecord.value.isCheckedIn) {
//         elapsedTime.value = attendanceRecord.value.getElapsedTime();
//       }
//     });
//   }

//   /// Called by location widget with full data
//   void updateLocation(AttendanceLocationData location) {
//     lastLocation.value = location;
//     isFakeLocation.value = location.isMock;
//   }

//   /// Handle check-in action
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

//     final record = AttendanceRecord(
//       checkInTime: DateTime.now(),
//       checkOutTime: null,
//       isCheckedIn: true,
//     );

//     attendanceRecord.value = record;
//     elapsedTime.value = record.getElapsedTime();

//     // Fire & forget API
//     _sendAttendanceToBackend(action: 'check_in');
//   }

//   /// Handle check-out action
//   Future<void> handleCheckOut() async {
//     final updated = attendanceRecord.value.copyWith(
//       checkOutTime: DateTime.now(),
//       isCheckedIn: false,
//     );

//     attendanceRecord.value = updated;
//     elapsedTime.value = updated.getElapsedTime();

//     // Fire & forget API
//     _sendAttendanceToBackend(action: 'check_out');
//   }

//   /// API Call to Backend (yaha se hai)
//   ///
//   /// Backend required JSON format:
//   /// {
//   ///   "myLatitude":23.346578,
//   ///   "myLongitude":85.309000,
//   ///   "isMock":"true",
//   ///   "address":"ABC",
//   ///   "accuracy":200,
//   ///   "buildNumber":"e705c25aa20e0644",
//   ///   "type":"CHECK-IN"
//   /// }
//   Future<void> _sendAttendanceToBackend({required String action}) async {
//     final loc = lastLocation.value;

//     if (loc == null) {
//       debugPrint('No location data available. Skipping API call.');
//       return;
//     }

//     const String apiUrl =
//         'http://localhost:8080/v1/m/attendance/mark_attendance';

//     // const String buildNumber = 'e705c25aa20e0644';
//     final String? androidId = await DeviceInfoService.getAndroidId();
//     final payload = <String, dynamic>{
//       'myLatitude': loc.latitude,
//       'myLongitude': loc.longitude,
//       'isMock': loc.isMock.toString(), // backend expects string "true"/"false"
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
//           // 'Authorization': 'Bearer YOUR_TOKEN_IF_NEEDED',
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
// }

// // Attendance tracking screen yaha se hai.
// class AttendanceTrackingScreen extends StatelessWidget {
//   const AttendanceTrackingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Register/Get controller
//     final AttendanceController controller = Get.put(AttendanceController());

//     final double h = Get.height;
//     final double w = Get.width;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),

//       /// App Bar
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

//       /// Body
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

//               /// Today's Log Header
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

//               /// Footer - View Past Records
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
//               child: ElevatedButton(
//                 onPressed: isCheckedIn
//                     ? () {
//                         Get.defaultDialog(
//                           title: 'Confirm Check Out',
//                           middleText: 'Are you sure you want to CHECK OUT?',
//                           barrierDismissible: false,
//                           textCancel: 'Cancel',
//                           textConfirm: 'Yes, Check Out',
//                           onCancel: () {},
//                           onConfirm: () {
//                             Get.back();
//                             controller.handleCheckOut();
//                           },
//                           buttonColor: const Color(0xFFDC3545),
//                           confirmTextColor: Colors.white,
//                         );
//                       }
//                     : () => controller.handleCheckIn(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isCheckedIn
//                       ? const Color(0xFFDC3545)
//                       : Colors.white,
//                   foregroundColor: isCheckedIn
//                       ? Colors.white
//                       : const Color(0xFF007BFF),
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(w * 0.02),
//                   ),
//                 ),
//                 child: Text(
//                   isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
//                   style: TextStyle(
//                     fontSize: w * 0.045,
//                     fontWeight: FontWeight.w500,
//                   ),
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

//Uper Wala code Sahi Hai.
//Testing Purpose Yeha par hamne checkin checkout control kar rhe hai.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:pds_app/Widgets/Attandence/attandence.dart';
import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
import 'package:pds_app/Widgets/Location_Get&Finde_Mock/attandenceLocation.dart';
import 'package:pds_app/core/Services/Android_id_get.dart';

import 'Attandance_info_card.dart';
import 'log_entry_items.dart';

///   Model for current location data
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

  /// If you ever need to serialize location directly, this matches backend keys
  Map<String, dynamic> toJson() => {
    'myLatitude': latitude,
    'myLongitude': longitude,
    'isMock': isMock.toString(), // "true" / "false"
    'accuracy': accuracy,
    'address': address,
  };
}

///  GetX Controller
class AttendanceController extends GetxController {
  final attendanceRecord = AttendanceRecord().obs;
  final isFakeLocation = false.obs;
  final elapsedTime = '0 hours, 0 minutes'.obs;

  // latest location from LiveLocationWidgets
  final Rxn<AttendanceLocationData> lastLocation =
      Rxn<AttendanceLocationData>();

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  /// Compare only date part (year, month, day)
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Start a timer to update elapsed time every second
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (attendanceRecord.value.isCheckedIn) {
        elapsedTime.value = attendanceRecord.value.getElapsedTime();
      }
    });
  }

  /// Called by location widget with full data
  void updateLocation(AttendanceLocationData location) {
    lastLocation.value = location;
    isFakeLocation.value = location.isMock;
  }

  /// Handle check-in action (only once per day)
  Future<void> handleCheckIn() async {
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

    if (lastLocation.value == null) {
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

    // Already checked in today? Block second check-in
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

    // Either first time or new day → fresh record for today
    final record = AttendanceRecord(
      checkInTime: now,
      checkOutTime: null,
      isCheckedIn: true,
    );

    attendanceRecord.value = record;
    elapsedTime.value = record.getElapsedTime();

    // Fire & forget API
    _sendAttendanceToBackend(action: 'check_in');
  }

  /// Handle check-out action (only for today's check-in)
  Future<void> handleCheckOut() async {
    final currentRecord = attendanceRecord.value;
    final now = DateTime.now();

    // No check-in or not today's check-in → block
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

    final updated = currentRecord.copyWith(
      checkOutTime: now,
      isCheckedIn: false,
    );

    attendanceRecord.value = updated;
    elapsedTime.value = updated.getElapsedTime();

    // Fire & forget API
    _sendAttendanceToBackend(action: 'check_out');
  }

  /// API Call to Backend (yaha se hai)
  ///
  /// Backend required JSON format:
  /// {
  ///   "myLatitude":23.346578,
  ///   "myLongitude":85.309000,
  ///   "isMock":"true",
  ///   "address":"ABC",
  ///   "accuracy":200,
  ///   "buildNumber":"e705c25aa20e0644",
  ///   "type":"CHECK-IN"
  /// }
  Future<void> _sendAttendanceToBackend({required String action}) async {
    final loc = lastLocation.value;

    if (loc == null) {
      debugPrint('No location data available. Skipping API call.');
      return;
    }

    const String apiUrl =
        'http://192.168.29.202:8080/v1/m/attendance/mark_attendance';

    final String? androidId = await DeviceInfoService.getAndroidId();

    final payload = <String, dynamic>{
      'myLatitude': loc.latitude,
      'myLongitude': loc.longitude,
      'isMock': loc.isMock.toString(),
      'address': loc.address,
      'accuracy': loc.accuracy,
      'buildNumber': androidId,
      'type': action == 'check_in' ? 'CHECK-IN' : 'CHECK-OUT',
    };

    debugPrint('Sending attendance payload: $payload');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Attendance saved successfully');
      } else {
        debugPrint(
          'Attendance API failed: ${response.statusCode} ${response.body}',
        );
        Get.snackbar(
          'Server error',
          'Unable to save attendance. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('Attendance API error: $e');
      Get.snackbar(
        'Network error',
        'Failed to connect to server.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

// Attendance tracking screen yaha se hai.
class AttendanceTrackingScreen extends StatelessWidget {
  const AttendanceTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Register/Get controller
    final AttendanceController controller = Get.put(AttendanceController());

    final double h = Get.height;
    final double w = Get.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      /// App Bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF030213)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Daily Attendance',
          style: TextStyle(
            fontSize: w * 0.05,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF030213),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF030213),
            ),
            onPressed: () {
              debugPrint('Notifications clicked');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF030213)),
            onPressed: () {
              debugPrint('Settings clicked');
            },
          ),
        ],
      ),

      /// Body
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(w * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Current Date Card
              AttendanceInfoCard(
                icon: Icons.calendar_today,
                iconColor: const Color(0xFF007BFF),
                backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
                label: 'Today',
                value: AttendanceRecord.getCurrentDate(),
              ),

              SizedBox(height: h * 0.02),

              /// Location Indicator Card
              Container(
                width: double.infinity,
                height: h * 0.25,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFECECF0), Color(0xFFE9EBEF)],
                  ),
                  borderRadius: BorderRadius.circular(w * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: w * 0.03,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: LiveLocationWidgets(
                  onLocationUpdate: controller.updateLocation,
                ),
              ),

              SizedBox(height: h * 0.02),

              /// Primary Action Card (reactive)
              Obx(() => _buildPrimaryActionCard(controller, h, w)),

              SizedBox(height: h * 0.03),

              /// Today's Log Header
              Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF717182),
                    size: 20,
                  ),
                  SizedBox(width: w * 0.02),
                  Text(
                    "Today's Log",
                    style: TextStyle(
                      fontSize: w * 0.045,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF030213),
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.015),

              /// Today's Log History Card (reactive)
              Obx(() => _buildLogHistoryCard(controller, h, w)),

              SizedBox(height: h * 0.03),

              /// Footer - View Past Records
              Center(
                child: TextButton(
                  onPressed: () {
                    debugPrint('View Past Records clicked');
                    Get.to(() => const PastRecordsScreen());
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.06,
                      vertical: h * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.02),
                    ),
                  ),
                  child: Text(
                    'View Past Records',
                    style: TextStyle(
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF007BFF),
                    ),
                  ),
                ),
              ),

              SizedBox(height: h * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  /// Primary Action Card (Check-in / Check-out)
  Widget _buildPrimaryActionCard(
    AttendanceController controller,
    double h,
    double w,
  ) {
    final record = controller.attendanceRecord.value;
    final bool isCheckedIn = record.isCheckedIn;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCheckedIn
              ? [const Color(0xFFFFC107), const Color(0xFFFF9800)]
              : [const Color(0xFF007BFF), const Color(0xFF0056b3)],
        ),
        borderRadius: BorderRadius.circular(w * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: w * 0.03,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Status Header
            Row(
              children: [
                Icon(
                  isCheckedIn ? Icons.check_circle : Icons.access_time,
                  color: Colors.white,
                  size: w * 0.055,
                ),
                SizedBox(width: w * 0.02),
                Expanded(
                  child: Text(
                    isCheckedIn
                        ? 'Status: Work in Progress'
                        : 'Status: Ready to Start',
                    style: TextStyle(
                      fontSize: w * 0.05,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: h * 0.01),

            /// Status Description
            Text(
              isCheckedIn
                  ? 'Checked in at ${AttendanceRecord.formatTime(record.checkInTime)}'
                  : 'Tap to log your attendance.',
              style: TextStyle(fontSize: w * 0.04, color: Colors.white),
            ),

            SizedBox(height: h * 0.03),

            /// Action Button
            SizedBox(
              width: double.infinity,
              height: h * 0.065,
              child: ElevatedButton(
                onPressed: isCheckedIn
                    ? () {
                        Get.defaultDialog(
                          title: 'Confirm Check Out',
                          middleText: 'Are you sure you want to CHECK OUT?',
                          barrierDismissible: false,
                          textCancel: 'Cancel',
                          textConfirm: 'Yes, Check Out',
                          onCancel: () {},
                          onConfirm: () {
                            Get.back();
                            controller.handleCheckOut();
                          },
                          buttonColor: const Color(0xFFDC3545),
                          confirmTextColor: Colors.white,
                        );
                      }
                    : () => controller.handleCheckIn(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCheckedIn
                      ? const Color(0xFFDC3545)
                      : Colors.white,
                  foregroundColor: isCheckedIn
                      ? Colors.white
                      : const Color(0xFF007BFF),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.02),
                  ),
                ),
                child: Text(
                  isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                  style: TextStyle(
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Log History Card: Check-in, Check-out, Total Hours
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
      elevation: 3,
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
                  ? const Color(0xFF28A745).withOpacity(0.1)
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
                  ? const Color(0xFFDC3545).withOpacity(0.1)
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
                backgroundColor: const Color(0xFF007BFF).withOpacity(0.1),
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
