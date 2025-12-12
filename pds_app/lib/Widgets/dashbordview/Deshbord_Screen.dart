// // Dashbord_Screen.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pds_app/Widgets/Attandence/AttandanceView.dart';

// import 'package:pds_app/Widgets/Attandence/AttandencePastRecord.dart';
// import 'package:pds_app/Widgets/Attandence/attandence.dart';
// import 'package:pds_app/Widgets/user%20profile/profile_c.dart';
// import 'package:pds_app/features/Location_Get&Finde_Mock/map_view.dart';
// import 'package:pds_app/Widgets/dashbordview/drawer.dart';
// import 'package:pds_app/Widgets/Attandence/Attandence_History/attendance_db.dart';
// import 'package:pds_app/Widgets/Attandence/Attandence_History/attendance_history_record.dart';

// class DashboardController extends GetxController {
//   RxDouble deviceWidth = 0.0.obs;
//   RxDouble deviceHeight = 0.0.obs;
//   RxInt totalAttendance = 0.obs;

//   Rx<TimeOfDay> currentTime = TimeOfDay.now().obs;
//   Timer? _timer;

//   void updateSize(BoxConstraints constraints) {
//     deviceWidth.value = constraints.maxWidth;
//     deviceHeight.value = constraints.maxHeight;
//   }

//   Future<void> loadAttendanceStats() async {
//     final records = await AttendanceDb.instance.getAllRecords();

//     final completed = records
//         .where((r) => r.status == RecordStatus.complete)
//         .length;

//     totalAttendance.value = completed;
//   }

//   void _startClock() {
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       currentTime.value = TimeOfDay.now();
//     });
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     _startClock();
//     loadAttendanceStats();
//   }

//   @override
//   void onClose() {
//     _timer?.cancel();
//     super.onClose();
//   }
// }

// /// -------------------- SCREEN -------------------- ///

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(DashboardController());

//     // 👇 Shared AttendanceController instance
//     final AttendanceController attendanceController =
//         Get.isRegistered<AttendanceController>()
//         ? Get.find<AttendanceController>()
//         : Get.put(AttendanceController());

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         controller.updateSize(constraints);

//         final double width = constraints.maxWidth;
//         final bool isMobile = width < 600;
//         final bool isTablet = width >= 600 && width < 1024;

//         final double contentMaxWidth = isMobile
//             ? width
//             : (isTablet ? 700 : 900);

//         final int statsCrossAxisCount = isMobile ? 2 : 4;
//         final int quickActionsPerRow = width < 360 ? 2 : 4;

//         return Obx(
//           () => Scaffold(
//             backgroundColor: const Color(0xFFF5F6FA),
//             drawer: MyDrawer(),
//             drawerEnableOpenDragGesture: true,
//             drawerEdgeDragWidth: MediaQuery.of(context).size.width * 0.5,
//             appBar: AppBar(
//               automaticallyImplyLeading: false,
//               backgroundColor: Colors.white,
//               elevation: 0,
//               titleSpacing: 0,
//               title: Row(
//                 children: [
//                   // open drawer (no back arrow)
//                   Builder(
//                     builder: (ctx) => IconButton(
//                       icon: const Icon(Icons.menu),
//                       onPressed: () => Scaffold.of(ctx).openDrawer(),
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   const Text(
//                     'Dashboard',
//                     style: TextStyle(
//                       color: Colors.black87,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.notifications_none),
//                   onPressed: () {
//                     // TODO: go to notifications if you have a screen
//                   },
//                 ),
//                 const SizedBox(width: 4),
//                 GestureDetector(
//                   onTap: () => Get.to(() => const ProfileScreen()),
//                   child: Padding(
//                     padding: const EdgeInsets.only(right: 16),
//                     child: CircleAvatar(
//                       radius: 16,
//                       backgroundColor: const Color(
//                         0xFF003060,
//                       ).withOpacity(0.15),
//                       child: const Icon(Icons.person, color: Color(0xFF003060)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             body: Center(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(maxWidth: contentMaxWidth),
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isMobile ? 16 : 24,
//                     vertical: 16,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const _HeaderGreeting(),
//                       const SizedBox(height: 16),

//                       // 🔹 Updated StatusCard using AttendanceController
//                       _StatusCard(
//                         dashboardController: controller,
//                         attendanceController: attendanceController,
//                       ),

//                       const SizedBox(height: 24),
//                       const Text(
//                         'Statistics',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       _StatsGrid(
//                         crossAxisCount: statsCrossAxisCount,
//                         totalAttendance: controller.totalAttendance.value,
//                       ),

//                       const SizedBox(height: 24),
//                       const Text(
//                         'Quick Actions',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       _QuickActionsRow(
//                         itemsPerRow: quickActionsPerRow,
//                         attendanceController: attendanceController,
//                       ),

//                       const SizedBox(height: 24),
//                       FooterLocation(isMobile: isMobile),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// /// -------------------- HEADER -------------------- ///

// class _HeaderGreeting extends StatelessWidget {
//   const _HeaderGreeting();

//   @override
//   Widget build(BuildContext context) {
//     return const Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Hello Engineer ',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//         ),
//         SizedBox(height: 4),
//         Text(
//           'Welcome back to your dashboard',
//           style: TextStyle(fontSize: 13, color: Colors.black54),
//         ),
//       ],
//     );
//   }
// }

// /// -------------------- STATUS CARD -------------------- ///

// class _StatusCard extends StatelessWidget {
//   const _StatusCard({
//     super.key,
//     required this.dashboardController,
//     required this.attendanceController,
//   });

//   final DashboardController dashboardController;
//   final AttendanceController attendanceController;

//   String _formatTime(TimeOfDay t) {
//     final hour = t.hourOfPeriod.toString().padLeft(2, '0');
//     final minute = t.minute.toString().padLeft(2, '0');
//     final period = t.period == DayPeriod.am ? 'AM' : 'PM';
//     return '$hour:$minute $period';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final now = dashboardController.currentTime.value;
//       final timeString = _formatTime(now);

//       final record = attendanceController.attendanceRecord.value;
//       final hasCheckedIn = record.checkInTime != null;
//       final hasCheckedOut = record.checkOutTime != null;
//       final bool isCheckedIn = record.isCheckedIn;

//       String mainStatus;
//       String subStatus;

//       if (isCheckedIn) {
//         mainStatus = 'Checked In';
//         subStatus =
//             'Since ${AttendanceRecord.formatTime(record.checkInTime)} • ${attendanceController.elapsedTime.value}';
//       } else if (hasCheckedOut) {
//         mainStatus = 'Checked Out';
//         subStatus = 'At ${AttendanceRecord.formatTime(record.checkOutTime)}';
//       } else {
//         mainStatus = 'Attandence Not Marked';
//         subStatus = 'Tap Check In to mark your attendance';
//       }

//       return Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           gradient: const LinearGradient(
//             colors: [Color(0xFF003060), Color(0xFF003060)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 18,
//               offset: const Offset(0, 8),
//               color: Colors.black26,
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Today',
//               style: TextStyle(color: Colors.white70, fontSize: 12),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               timeString,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white,
//                     ),
//                     child: Icon(
//                       isCheckedIn
//                           ? Icons.check_circle
//                           : (hasCheckedOut ? Icons.logout : Icons.access_time),
//                       size: 18,
//                       color: isCheckedIn
//                           ? const Color(0xFF27AE60)
//                           : Colors.orangeAccent,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Today's Status",
//                           style: TextStyle(fontSize: 12, color: Colors.white70),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           mainStatus,
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           subStatus,
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: Colors.white70,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: const Color(0xFF6C63FF),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 18,
//                         vertical: 8,
//                       ),
//                       textStyle: const TextStyle(fontWeight: FontWeight.w600),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(22),
//                       ),
//                       elevation: 0,
//                     ),
//                     onPressed: () {
//                       Get.to(() => const AttendanceTrackingScreen());
//                     },
//                     child: Text(isCheckedIn ? 'View Details' : 'Check In'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }

// /// -------------------- STATISTICS GRID -------------------- ///

// class _StatsGrid extends StatelessWidget {
//   final int crossAxisCount;
//   final int totalAttendance;

//   const _StatsGrid({
//     super.key,
//     required this.crossAxisCount,
//     required this.totalAttendance,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       StatCardData(
//         title: 'ATTENDANCE',
//         value: totalAttendance.toString(),
//         icon: Icons.trending_up,
//         iconBackground: const Color(0xFFE6F8EF),
//         barColor: const Color(0xFF27AE60),
//         onTap: () => Get.to(() => const PastRecordsScreen()),
//       ),
//       StatCardData(
//         title: 'LEAVE',
//         value: '0',
//         icon: Icons.fiber_manual_record,
//         iconBackground: const Color(0xFFE7F0FF),
//         barColor: const Color(0xFF2D9CDB),
//       ),
//       StatCardData(
//         title: 'ALL TICKETS',
//         value: '0',
//         icon: Icons.confirmation_number_outlined,
//         iconBackground: const Color(0xFFFFF2E5),
//         barColor: const Color(0xFFF2994A),
//       ),
//       StatCardData(
//         title: "TODAY'S TICKETS",
//         value: '0',
//         icon: Icons.calendar_today_outlined,
//         iconBackground: const Color(0xFFEDE7FF),
//         barColor: const Color(0xFF9B51E0),
//         onTap: () => Get.to(() => const PastRecordsScreen()),
//       ),
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       itemCount: items.length,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         childAspectRatio: 1.6,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//       ),
//       itemBuilder: (context, index) {
//         return StatCard(data: items[index]);
//       },
//     );
//   }
// }

// class StatCardData {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color iconBackground;
//   final Color barColor;
//   final bool isTextValue;
//   final VoidCallback? onTap;

//   StatCardData({
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.iconBackground,
//     required this.barColor,
//     this.isTextValue = false,
//     this.onTap,
//   });
// }

// class StatCard extends StatelessWidget {
//   final StatCardData data;

//   const StatCard({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(18),
//       elevation: 3,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(18),
//         onTap: data.onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: data.iconBackground,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(data.icon, size: 18),
//                   ),
//                   const Spacer(),
//                   if (!data.isTextValue)
//                     Text(
//                       data.value,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 data.title,
//                 style: const TextStyle(
//                   fontSize: 11,
//                   letterSpacing: 0.3,
//                   color: Colors.black54,
//                 ),
//               ),
//               const Spacer(),
//               if (data.isTextValue)
//                 Text(
//                   data.value,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               const SizedBox(height: 6),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(999),
//                 child: LinearProgressIndicator(
//                   minHeight: 5,
//                   value: 0.3,
//                   backgroundColor: const Color(0xFFF2F2F2),
//                   valueColor: AlwaysStoppedAnimation<Color>(data.barColor),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// -------------------- QUICK ACTIONS -------------------- ///

// class _QuickActionsRow extends StatelessWidget {
//   final int itemsPerRow;
//   final AttendanceController attendanceController;

//   const _QuickActionsRow({
//     super.key,
//     required this.itemsPerRow,
//     required this.attendanceController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final actions = [
//       QuickActionData(
//         label: 'Check In',
//         icon: Icons.login,
//         onTap: () => Get.to(() => const PastRecordsScreen()),
//       ),
//       QuickActionData(
//         label: 'Check Out',
//         icon: Icons.logout,
//         onTap: () => Get.to(() => const PastRecordsScreen()),
//       ),
//       QuickActionData(
//         label: 'Reports',
//         icon: Icons.insert_chart_outlined,
//         onTap: () {
//           Get.to(() => const PastRecordsScreen());
//         },
//       ),
//       QuickActionData(label: 'Settings', icon: Icons.settings, onTap: () {}),
//     ];

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         const spacing = 10.0;
//         final double itemWidth =
//             (constraints.maxWidth - spacing * (itemsPerRow - 1)) / itemsPerRow;

//         return Wrap(
//           spacing: spacing,
//           runSpacing: spacing,
//           children: actions.map((a) {
//             return SizedBox(
//               width: itemWidth,
//               child: QuickActionButton(data: a),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }

// class QuickActionData {
//   final String label;
//   final IconData icon;
//   final VoidCallback? onTap;

//   QuickActionData({required this.label, required this.icon, this.onTap});
// }

// class QuickActionButton extends StatelessWidget {
//   final QuickActionData data;
//   const QuickActionButton({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(18),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(18),
//         onTap: data.onTap,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircleAvatar(
//                 radius: 18,
//                 backgroundColor: const Color(0xFFF2F2F8),
//                 child: Icon(data.icon, size: 18),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 data.label,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// -------------------- CURRENT LOCATION CARD -------------------- ///

// class FooterLocation extends StatelessWidget {
//   final bool isMobile;
//   const FooterLocation({super.key, required this.isMobile});

//   @override
//   Widget build(BuildContext context) {
//     final double mapHeight = isMobile ? 220 : 260;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Expanded(
//               child: Text(
//                 'Current Location',
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.black87,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {},
//               child: const Text(
//                 'View History',
//                 style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(22),
//             boxShadow: [
//               BoxShadow(
//                 blurRadius: 16,
//                 offset: const Offset(0, 6),
//                 color: Colors.black.withOpacity(0.05),
//               ),
//             ],
//           ),
//           child: SizedBox(
//             height: mapHeight,
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 return Stack(
//                   children: [
//                     Positioned.fill(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(18),
//                         child: const MapView(),
//                       ),
//                     ),
//                     Positioned(
//                       left: 10,
//                       top: 10,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               blurRadius: 8,
//                               offset: const Offset(0, 3),
//                               color: Colors.black.withOpacity(0.05),
//                             ),
//                           ],
//                         ),
//                         child: const Text(
//                           '2.5 km away',
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
